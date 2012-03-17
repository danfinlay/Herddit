//
//  HRDAudioRecorder.m
//  Recorder2
//
//  Created by Daniel Finlay on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDAudioRecorder.h"

@implementation HRDAudioRecorder
@synthesize url;

-(id)init{
	self = [super init];
	
	NSError *error;
	
	//First creating AudioSession, then Recorder.
	audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	[audioSession setActive:YES error:&error];
	
	//Creating settings Dict for AVAudioRecorder
	//Parameters defined at:
	//https://developer.apple.com/library/mac/#documentation/AVFoundation/Reference/AVFoundationAudioSettings_Constants/Reference/reference.html#//apple_ref/doc/uid/TP40009937
	
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	
	/**
	 [settings setObject:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:@"AVFormatIDKey"];
	 [settings setObject: [NSNumber numberWithFloat:44100.0] forKey:@"AVSampleRateKey"];
	 [settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	 
	 //Unneccessary encoder settings:
	 [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey]; 
	 [settings setValue:[NSNumber numberWithInt:96] forKey:AVEncoderBitRateKey]; 
	 [settings setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitDepthHintKey];
	 **/
	
	
	[settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
	[settings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey]; 
	[settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	[settings setObject:[NSNumber numberWithInt:AVAudioQualityLow] forKey: AVEncoderAudioQualityKey]; 
	[settings setValue:[NSNumber numberWithInt: 8000] forKey:AVEncoderBitRateKey];
	
	/**Unneccessary encoder settings:
	[settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey]; 
	[settings setValue:[NSNumber numberWithInt:96] forKey:AVEncoderBitRateKey]; 
	[settings setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitDepthHintKey];**/
	
	//Establishing file path:
	//NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"aac"]]];
	NSLog(@"Using File called: %@",url);
				
recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	toggle = YES;
//[recorder setDelegate:self];
	[recorder prepareToRecord];
	return self;
}

-(void)startRecording{
	NSLog(@"HRDAudioRecorder received startRecording.");
	[recorder record];
}
-(void) pauseRecording{
		NSLog(@"HRDAudioRecorder received pauseRecording.");
	[recorder pause];
}
-(void)stopRecording{
		NSLog(@"HRDAudioRecorder received stopRecording.");
	[recorder stop];
}
-(void)startPlaying{
		NSLog(@"HRDAudioRecorder received startPlaying.");
	NSError *error;
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	[player prepareToPlay];
	[player play];
}
-(void)pausePlaying{
		NSLog(@"HRDAudioRecorder received pausePlaying.");
	[player pause];
}
-(void)stopPlaying{
		NSLog(@"HRDAudioRecorder received stopPlaying.");
	[player stop];
}
-(void)upload{
		NSLog(@"HRDAudioRecorder received upload.");
	//This is the method to POST the soundcloud stream to 
	
}

-(void)resumePlaying{
    [player play];
}
-(void)resumeRecording{
    [recorder record];
}

@end
