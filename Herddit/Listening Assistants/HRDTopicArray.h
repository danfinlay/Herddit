//
//  HRDTopicArray.h
//  Herddit
//
//  Created by Daniel Finlay on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


//This Object might as well be called "HRDSubreddit" because it contains all the methods necessary to load all the topics of a subreddit, as well as call on individual topics to load themselves and return their information for the Listen View Controller.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "HRDTopic.h"

@interface HRDTopicArray : NSObject <NSURLConnectionDelegate>{
	
	//This is for receiving data:
	NSMutableData *receivedData;
	NSURLConnection *connection;
	
	NSString *sessionCookie;
	NSString *currentSubreddit;
	
	//The actual comments, and where we are:
	NSMutableArray *topics;
	int currentTopic;
	
	NSArray *commentArray;
	NSArray *commentQueue;
}
-(id)initWithSubreddit:(NSString *)subReddit;
-(void)loadComments;
-(void)parseData:(NSData *)data;

@property (copy) NSMutableArray *topics;
@property (copy) NSString *currentSubreddit;
@property (copy) NSArray *commentArray;
@property (copy) NSArray *commentQueue;
@property int currentTopic;
@end
