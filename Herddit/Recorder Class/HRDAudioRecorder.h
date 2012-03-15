//
//  HRDAudioRecorder.h
//  Recorder2
//
//  Created by Daniel Finlay on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CoreAudio/CoreAudioTypes.h"

@interface HRDAudioRecorder : NSObject{
	AVAudioRecorder *recorder;
	AVAudioSession *audioSession;
	NSURL *url;
	AVAudioPlayer *player;
	BOOL toggle;
}

-(void)startRecording;
-(void)pauseRecording;
-(void)stopRecording;
-(void)startPlaying;
-(void)pausePlaying;
-(void)stopPlaying;
-(void)upload;
-(void)resumePlaying;
-(void)resumeRecording;

@property (readwrite, copy) NSURL *url;

@end
