//
//  HRDTopic.m
//  Herddit
//
//  Created by Daniel Finlay on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDTopic.h"

@implementation HRDTopic

@synthesize title, real_id, poster_name, subreddit, subreddit_id, url, commentArray, commentCount;

-(id)initWithTopic:(NSArray *)topic{
	if ([super init] != nil){
		
		dataDict = [topic valueForKey:@"data"];
		
		title = [dataDict valueForKey:@"title"];
		real_id = [dataDict valueForKey:@"name"];
		poster_name = [dataDict valueForKey:@"author"];
		
		
		url = [NSString stringWithFormat:@"%@%@",[dataDict valueForKey:@"url"], @"?client_id=4c65f6b723a93defa57007fc8d0ebc44"];
		
		
		subreddit = [dataDict valueForKey:@"subreddit"];
		subreddit_id = [dataDict valueForKey:@"subreddit_id"];
		commentCount = [[dataDict valueForKey:@"num_comments"] intValue];
		
		return self;
	}else{
		return nil;
	}
}
-(void)fetchComments{
	commentFetcher = [[HRDCommentArray alloc] initWithPermalink:[dataDict valueForKey:@"permalink"] delegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsFetched:) name:@"commentsFetched" object:nil];
	
	
	
}
-(void)commentsFetched:(NSNotification *)notification{
		[commentArray addObjectsFromArray:[commentFetcher commentArray]];
	NSLog(@"%i comments fetched.", [commentArray count]);
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"topicCommentsReceived" 
	 object:self];

}
-(NSArray *)commentQueue{
	NSMutableArray *buildQueue = [[NSMutableArray alloc] init];
	//Add topic as first of queue:
	HRDBareComment *topicComment = [[HRDBareComment alloc] initWithTopic:self];
	[buildQueue addObject:topicComment];
	
	commentArray = [NSMutableArray arrayWithArray:[commentFetcher commentArray]];
	
	NSLog(@"Building a queue from %i original comments.", [commentArray count]);
	for (int i = 0; i<[commentArray count]; i++){
		
		//Recursively add subsequent generations:
		NSLog(@"Adding comment array bare array results to buildqueue, type %@.", [[commentArray objectAtIndex:i] class]);
		[buildQueue addObjectsFromArray:
		 [[commentArray objectAtIndex:i] bareArray:0]];
		
	}

	return buildQueue;
}
@end
