//
//  HRDTopicArray.m
//  Herddit
//
//  Created by Daniel Finlay on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDTopicArray.h"

@implementation HRDTopicArray

@synthesize topics, currentTopic, currentSubreddit, commentArray, commentQueue;

-(id)initWithSubreddit:(NSString *)subReddit{
	if([super init]!=nil){
		currentTopic = 0;
		currentSubreddit = subReddit;
		NSLog(@"Initializing HRDTopicArray");
		
		if (sessionCookie == nil){
			sessionCookie = [[NSUserDefaults standardUserDefaults] valueForKey:@"sessionCookie"];
		}
		
		if (currentSubreddit == nil){
			currentSubreddit = @"herddit";
		}
		
		NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://www.reddit.com/r/HRD"];
		[urlString appendString:currentSubreddit];
		[urlString appendString:@".json"];
		
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		NSLog(@"%@", urlString);
		
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		if(connection){
			receivedData = [NSMutableData data];
		}else{
			//Inform the user connection failed.  For now, just popping.
			NSLog(@"Connection failed!  Find a way to inform?");
		}
		
		return self;
	}else{
		return nil;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Received data...");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Topic Array received all subreddit data!  Parsing...");
	[self parseData:receivedData];
}

-(void)parseData:(NSData *)data{
	NSLog(@"Topic Array Parsing Data...");
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error = [[NSError alloc] init];
	NSMutableData *outData = [deserializer deserialize:data error:&error];
	
	NSLog(@"Main Subreddit Data: %@", outData);
	NSArray *rawTopics = [[outData valueForKey:@"data"] valueForKey:@"children"];
	topics = [[NSMutableArray alloc] init];
	
	[[NSUserDefaults standardUserDefaults] setValue:
	 [[outData valueForKey:@"data"] valueForKey:@"modhash"]
				forKey:@"modhash"];
	
	NSLog(@"Converting topics:");
	for (int i = 0; i < [rawTopics count]; i++){
		
		HRDTopic *newTopic = [[HRDTopic alloc] initWithTopic:[rawTopics objectAtIndex:i]];
		
		[topics addObject:newTopic];
	}

	NSLog(@"Number of topics: %i", [topics count]);
	[[topics objectAtIndex:currentTopic] fetchComments];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topicCommentsReceived:) name:@"topicCommentsReceived" object:nil];

}
-(void)topicCommentsReceived:(NSNotification *)notification{
	if ([notification name] == @"topicCommentsReceived"){
		
	commentQueue = [[topics objectAtIndex:currentTopic] commentQueue];
	NSLog(@"Topic's comment array made, %i members.", [commentQueue count]);
	[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"commentQueueReady" 
		 object:self];
	}
}

-(void)loadComments{
	[[topics objectAtIndex:currentTopic] fetchComments];
}
@end
