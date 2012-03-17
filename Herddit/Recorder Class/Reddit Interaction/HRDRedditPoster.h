//
//  HRDRedditPoster.h
//  Herddit
//
//  Created by Daniel Finlay on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CJSONDeserializer.h"

@interface HRDRedditPoster : NSObject <NSURLConnectionDelegate>{
	NSURLConnection *connection;
	NSString *modhash;
	NSMutableData *receivedData;
	NSMutableData *outData;
}
-(void)post:(NSString *) streamUrl toSub:(NSString *)subId;
-(void)reply:(NSString *) streamUrl toPost:(NSString *)replyTo;
-(void)setModhash:(NSString*)mod;
-(void)newPostTo:(NSString *)subReddit;
@end
