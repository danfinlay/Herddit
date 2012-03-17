//
//  HRDComment.m
//  SoundCloudAPI
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDComment.h"

@implementation HRDComment

@synthesize expanded, raw_data, link_id, author, name, body, replies;

-(id)initWithData:(NSDictionary *)data{
	if([super init] != nil){
		
		raw_data = [data valueForKey:@"data"];
		
		expanded = YES;
		body = [data valueForKey:@"body"];
		author = [data valueForKey:@"author"];
		link_id = [data valueForKey:@"id"];
		name = [data valueForKey:@"name"];
		
		NSArray *raw_replies = [[[data valueForKey:@"replies"] valueForKey:@"data"] valueForKey:@"children"];
		
		replies = [[NSMutableArray alloc] init];
		for (int i = 0; i < [raw_replies count]; i++){
			HRDComment *newComment = [[HRDComment alloc] initWithData:[raw_replies objectAtIndex:i]];
			[replies addObject:newComment];
		}
		return self;
	}else{
		return nil;
	}
}
-(NSArray *)bareArray:(int)indent{
	NSMutableArray *bareArray = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [replies count]; i ++){
		
		HRDBareComment *newComment = [[HRDBareComment alloc] initWithComment:[replies objectAtIndex:i] andIndentation:indent + 1];
		[bareArray addObject:newComment];
		
		[bareArray addObjectsFromArray:[[replies objectAtIndex:i] bareArray:indent + 1]];
	}
	
	return bareArray;
}
@end
