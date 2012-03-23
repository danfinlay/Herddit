//
//  HRDAudioStreamer.h
//  Herddit5
//
//  Created by Daniel Finlay on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface HRDAudioStreamer : NSObject{
	
	AVPlayer *player;
	
}

-(void)playStream:(NSURL *)streamURL;
-(void)pauseStream;
-(void)resumeStream;

@end
