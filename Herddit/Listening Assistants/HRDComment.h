//
//  HRDComment.h
//  SoundCloudAPI
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRDBareComment.h"

@interface HRDComment : NSObject{
	
	//Expanded is used to decide whether to collapse and skip this comment branch or not.
	BOOL expanded;
	
	NSDictionary *raw_data;
	NSString *body;
	NSString *link_id;
	NSString *author;
	NSString *name;
	
	//Include a progress bar class here.
	
	NSMutableArray *replies;
	
}
-(id)initWithData:(NSDictionary *)data;
-(NSArray *)bareArray:(int)indent;

@property BOOL expanded;
@property (readonly) NSDictionary *raw_data;
@property (readonly) NSString *link_id;
@property (readonly) NSString * author;
@property (readonly) NSString *name;
@property (readonly) NSString *body;
@property (copy) NSMutableArray *replies;

@end
