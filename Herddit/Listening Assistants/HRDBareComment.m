//
//  HRDBareComment.m
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDBareComment.h"

@implementation HRDBareComment

@synthesize expanded, indentation, link_id, author, name, body;

-(id)initWithComment:(HRDComment *)original andIndentation:(int)indent{
	if ([super init]!=nil){
		
		body = [original body];
		link_id = [original link_id];
		author = [original author];
		name = [original name];
		indentation = indent;
		
		return self;
	}else{
		return nil;
	}
}

@end
