//
//  HRDRedditVoter.m
//  Herddit
//
//  Created by Daniel Finlay on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDRedditVoter.h"

@implementation HRDRedditVoter
-(id)init{
	if ([super init] != nil){
		
		modhash = [[NSUserDefaults standardUserDefaults] valueForKey:@"modhash"];
		return self;
	}else{
		return nil;
	}
}
-(void)upVote:(HRDBareComment *)comment{
	theComment = comment;
	[self vote:1];
}
-(void)downVote:(HRDBareComment *)comment{
	theComment = comment;
	[self vote:-1];
}
-(void)unVote:(HRDBareComment *)comment{
	theComment = comment;
	[self vote:0];
}
-(void)vote:(int)dir{
	
	NSLog(@"Post streamurl to subreddit");
	modhash = [[NSUserDefaults standardUserDefaults] valueForKey:@"modhash"];
	
	NSString *post = [[NSString alloc] initWithFormat:@"id=%@&dir=%i&uh=%@", theComment.link_id, dir, modhash];
	NSLog(@"Attempting to vote on topic with: %@", post);
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:@"http://www.reddit.com/api/submit/"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(connection){
		receivedData = [NSMutableData data];
	}else{
		//Inform the user connection failed.  For now, just popping.
		NSLog(@"Error with HRDRedditVoter");
	}
	
	
}
-(void)reply:(NSString *) streamUrl toPost:(NSString *)replyTo{
	
	modhash = [[NSUserDefaults standardUserDefaults] valueForKey:@"modhash"];
	
	NSString *post = [[NSString alloc] initWithFormat:@"parent=%@&text=%@&uh=%@",	replyTo, streamUrl, modhash];
	NSLog(@"Attempting to post new reply with data: %@", post);
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:@"http://www.reddit.com/api/comment"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(connection){
		receivedData = [NSMutableData data];
	}else{
		//Inform the user connection failed.  For now, just popping.
		NSLog(@"Error with HRDRedditPoster");
	}
	
}
-(void)setModhash:(NSString*)mod{
	modhash = mod;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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
	
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error = [[NSError alloc] init];
	outData = [deserializer deserialize:receivedData error:&error];
	NSLog(@"Returned vote data: %@", outData);

}
@end
