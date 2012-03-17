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
		url = [dataDict valueForKey:@"url"];
		subreddit = [dataDict valueForKey:@"subreddit"];
		subreddit_id = [dataDict valueForKey:@"subreddit_id"];
		commentCount = [[dataDict valueForKey:@"num_comments"] intValue];
		
		[self fetchComments];
		
		return self;
	}else{
		return nil;
	}
}
-(void)fetchComments{
	HRDCommentArray *commentFetcher = [[HRDCommentArray alloc] initWithPermalink:[dataDict valueForKey:@"permalink"] delegate:self];
	
	[commentArray addObjectsFromArray:[commentFetcher commentArray]];
	
/**
I was considering using a "displayPrepArray" to dump all the comments in a linear order, but now I'm getting too tired to do that.  I might find a different way to solve this problem in the morning.
 
	displayPrepArray = [[NSMutableArray alloc] init];
	for (int i = 0; i<[commentArray count]; i++){
		[displayPrepArray addObjectsFromArray:[[commentArray objectAtIndex:i] commentDump]];
	}
 **/
}
-(NSArray *)commentQueue{
	NSMutableArray *buildQueue = [[NSMutableArray alloc] init];
	
	for (int i = 0; i<[commentArray count]; i++){
		
		HRDBareComment *newComment = [[HRDBareComment alloc] initWithComment:[commentArray objectAtIndex:i] andIndentation:0];
		[buildQueue addObject:newComment];
		[buildQueue addObjectsFromArray:
		 [[commentArray objectAtIndex:i] bareArray:0]];
		
	}
	return buildQueue;
}
@end
