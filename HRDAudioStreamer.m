//
//  HRDAudioStreamer.m
//  Herddit5
//
//  Created by Daniel Finlay on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDAudioStreamer.h"

@implementation HRDAudioStreamer

-(void)playStream:(NSURL *)streamURL{
	player = [[AVPlayer alloc] initWithURL:streamURL];
	[player play];
}
-(void)pauseStream{
	[player pause];
}
-(void)resumeStream{
	[player play];
}
@end
