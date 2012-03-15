//
//  HRDCommentArray.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


//A new comment array represents a comment, and the replies to it.

//Each new comment array has all the relevant info about itself in its dataDict, whose keys are straight off reddit, but useful to me are:
//body, downs, author, link_id (which is the name), parent_id, likes.

//For replies, I've made an easier to access array of additional HRDCommentArray objects, in the main array (this is a subclass of NSMutableArray)

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

@interface HRDCommentArray : NSObject<NSURLConnectionDelegate>{
	id delegate;
	
	NSDictionary *dataDict;
	
	NSMutableData *receivedData;
	NSURLConnection *connection;
	NSArray *outData;
}
@property (readwrite, retain) NSDictionary *dataDict;

-(id)initWithPermalink:(NSString *)permaLink delegate:(id)delegate;
-(NSArray *)commentArray;

@end
