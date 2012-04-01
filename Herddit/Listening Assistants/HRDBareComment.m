//
//  HRDBareComment.m
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDBareComment.h"

@implementation HRDBareComment

@synthesize expanded, indentation, link_id, author, name, body, vote;

-(id)initWithComment:(HRDComment *)original andIndentation:(int)indent{
	if ([super init]!=nil){
		vote = 0;
		body = [NSString stringWithFormat:@"%@%@",original.body, @"?client_id=4c65f6b723a93defa57007fc8d0ebc44"];		
		link_id = [original link_id];
		author = [original author];
		name = [original name];
		indentation = indent;
		NSLog(@"Creating Bare Comment w/ indentation of: %i", indentation);
		return self;
	}else{
		return nil;
	}
}
-(id)initWithTopic:(HRDTopic *)topic{
	expanded = YES;
	body = topic.url;
	NSLog(@"Body: %@", body);
	author = topic.poster_name;
	link_id = topic.real_id;
	name = topic.subreddit_id;
	
	return self;
}

@end
