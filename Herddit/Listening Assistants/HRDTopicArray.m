//
//  HRDTopicArray.m
//  Herddit
//
//  Created by Daniel Finlay on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDTopicArray.h"

@implementation HRDTopicArray

@synthesize topics, coordinateArray, currentTopic;

-(id)init{
	if([super init]!=nil){
		topics = [[NSMutableArray alloc] init];
		coordinateArray = [[NSMutableArray alloc] init];
		return self;
	}else{
		return nil;
	}
}

-(void)parseData:(NSData *)data{
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error = [[NSError alloc] init];
	NSMutableData *outData = [deserializer deserialize:data error:&error];
	
	NSLog(@"Main Subreddit Data: %@", outData);
	NSArray *rawTopics = [[outData valueForKey:@"data"] valueForKey:@"children"];

	for (int i = 0; i < [rawTopics count]; i++){
		
		HRDTopic *newTopic = [[HRDTopic alloc] initWithTopic:[rawTopics objectAtIndex:i]];
		
		[topics addObject:newTopic];
	}
}



@end
