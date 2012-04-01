//
//  HRDRedditVoter.h
//  Herddit
//
//  Created by Daniel Finlay on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "HRDBareComment.h"

@interface HRDRedditVoter : NSObject<NSURLConnectionDelegate>{
	NSURLConnection *connection;
	NSString *modhash;
	NSMutableData *receivedData;
	NSMutableData *outData;
	HRDBareComment *theComment;
}

-(void)upVote:(HRDBareComment *)comment;
-(void)downVote:(HRDBareComment *)comment;
-(void)unVote:(HRDBareComment *)comment;
-(void)vote:(int)dir;
@end
