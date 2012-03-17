//
//  HRDTopic.h
//  Herddit
//
//  Created by Daniel Finlay on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRDCommentArray.h"
#import "HRDBareComment.h"

@interface HRDTopic : NSObject{
	
	//The raw JSON returned by reddit of this topic's page:
	NSDictionary *dataDict;
	
	//My own extracted details from the reddit's JSON info, to be used as synthetic properties.
	NSString *title;
	NSString *real_id;
	NSString *poster_name;
	NSString *subreddit;
	NSString *subreddit_id;
	NSURL *url;
	int commentCount;
	
	//These classes are related to keeping track of what is playing or being played.
	NSMutableArray *commentArray;
	BOOL playingTopic;
	BOOL playingComment;
	int playingCommentNumber;
}
-(id)initWithTopic:(NSArray *)topic;
-(void)fetchComments;
-(NSArray *)commentQueue;

@property (readonly) NSString *title;
@property (readonly) NSString *real_id;
@property (readonly) NSString *poster_name;
@property (readonly) NSString *subreddit;
@property (readonly) NSString *subreddit_id;
@property (readonly) NSURL *url;
@property (readonly) int commentCount;
@property (copy) NSMutableArray *commentArray;
@end
