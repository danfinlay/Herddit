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

-(id)initWithTopic:(HRDTopic *)topic{
	expanded = YES;
	body = topic.url;
	NSLog(@"Body: %@", body);
	author = topic.poster_name;
	link_id = topic.real_id;
	name = topic.subreddit_id;

	return self;
}
-(id)initWithData:(NSDictionary *)data{
	if([super init] != nil){
		
		raw_data = [data valueForKey:@"data"];
		NSLog(@"Creating HRDComment from raw_data: %@", raw_data);
		expanded = YES;
		body = [raw_data valueForKey:@"body"];
		NSLog(@"Body: %@", body);
		author = [raw_data valueForKey:@"author"];
		link_id = [raw_data valueForKey:@"id"];
		name = [raw_data valueForKey:@"name"];
		
		//checking if there are any replies, before parsing them:
		NSString *test = [raw_data valueForKey:@"replies"];
		NSLog(@"Test string: %@", test);
		if([test class] == [raw_data class])
		{
			
			NSLog(@"Replies detected!");
		//Always end with children.
		NSArray *raw_replies = [[[raw_data valueForKey:@"replies"]valueForKey:@"data"] valueForKey:@"children"];
		replies = [[NSMutableArray alloc] init];
			
			for (int i = 0; i < [raw_replies count]; i++)
			{
				HRDComment *newComment = [[HRDComment alloc] initWithData:[raw_replies objectAtIndex:i]];
				[replies addObject:newComment];
			}
			
		}
		
		
		
		return self;
	}else{
		return nil;
	}
}
-(NSArray *)bareArray:(int)indent{
	NSMutableArray *bareArray = [[NSMutableArray alloc] init];
	
	HRDBareComment *bareParent = [[HRDBareComment alloc] initWithComment:self andIndentation:indent + 1];
	[bareArray addObject:bareParent];
	
	for (int i = 0; i < [replies count]; i ++){
		
		
		[bareArray addObjectsFromArray:
		 [[replies objectAtIndex:i] 
		  bareArray:indent + 1]];
		
		
				/**Pretty sure this is wrong, since we want each member to invite its children, but not THEIR children.
		
		HRDBareComment *newComment = [[HRDBareComment alloc] initWithComment:[replies objectAtIndex:i] andIndentation:indent + 1];
		[bareArray addObject:newComment];
		

		 
		[bareArray addObjectsFromArray:[[replies objectAtIndex:i] bareArray:indent + 1]];
		 **/
	}
	
	return bareArray;
}
@end
