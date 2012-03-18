//
//  HRDBareComment.h
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRDComment.h"
#import "HRDTopic.h"
@class HRDComment;
@class HRDTopic;

@interface HRDBareComment : NSObject{
	BOOL expanded;
	int indentation;
	
	NSURL *body;
	NSString *link_id;
	NSString *author;
	NSString *name;
	
	//Maybe THIS is where we'll include the progress bar info...
}
-(id)initWithTopic:(HRDTopic *)topic;
-(id)initWithComment:(HRDComment *)original andIndentation:(int)indent;

@property BOOL expanded;
@property int indentation;
@property (readonly) NSString *link_id;
@property (readonly) NSString * author;
@property (readonly) NSString *name;
@property (readonly) NSURL *body;

@end
