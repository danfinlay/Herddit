//
//  HRDCommentArray.m
//  Herddit5
//
//  Created by Daniel Finlay on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDCommentArray.h"

@implementation HRDCommentArray
@synthesize dataDict;

-(id)initWithPermalink:(NSString *)permaLink delegate:(id)delegate{
	self = [super init];
		
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://www.reddit.com"];
	[urlString appendString:permaLink];
	[urlString appendString:@".json"];
	NSLog(@"Loading comments from %@", urlString);
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSLog(@"NSURL created.");
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(connection){
		receivedData = [NSMutableData data];
	}else{
		NSLog(@"Comment thread load failed for: %@", permaLink);
	}
	
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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
    NSLog(@"Comment load succeeded! Received %d bytes of data",[receivedData length]);
	
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error = [[NSError alloc] init];
	outData = [deserializer deserialize:receivedData error:&error];
	
	NSLog(@"Comments loaded.  Comment response is a %@, contents: %@", [outData class], outData);
	
	dataDict = [[[[[outData objectAtIndex:0] valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:0] valueForKey:@"data"];
	/*
	NSNotification *notification = [NSNotification notificationWithName:@"dataDict loaded" object:dataDict];

	[[NSNotificationCenter defaultCenter] postNotification:notification];
	 */
}

-(NSUInteger)count{
	return [outData count];
}
-(NSArray *)commentArray{
	if (outData == nil){
		return nil;
	}else{
		return outData;
	}
}

@end
