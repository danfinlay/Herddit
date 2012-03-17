//
//  HRDCommentArray.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


//As of version 1.1, this array does not represent a comment, but instead is used to fetch the comment JSON, and then return it to be parsed by a topic object.

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "HRDComment.h"

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
