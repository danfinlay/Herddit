//
//  HRDAudioStreamer.m
//  Herddit
//
//  Created by Daniel Finlay on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDAudioStreamer.h"

@implementation HRDAudioStreamer
@synthesize mp3_url;

-(id)initWithStream:(NSURL *)url{
	if ([super init]!= nil){
		/**
		NSMutableString *urlString = [[NSMutableString alloc] initWithString:[url absoluteString]];
		[urlString appendString:@".json"];
		
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		NSLog(@"%@", urlString);
		 **/
		NSURL *urlStream = [[NSURL alloc] initWithString:url];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:urlStream];
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
	NSLog(@"mp3 stream url request of type '%@' returned, %@", [receivedData class], receivedData);
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"streamUrlRetrieved" 
	 object:self];
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error = [[NSError alloc] init];
	NSMutableData *outData = [deserializer deserialize:receivedData error:&error];
	
	NSLog(@"Returned mp3 stream data: %@", outData);
}
@end
