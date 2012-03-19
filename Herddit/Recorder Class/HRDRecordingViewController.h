//
//  HRDRecordingViewController.h
//  Herddit
//
//  Created by Daniel Finlay on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCUI.h"
#import "HRDAudioRecorder.h"
#import "HRDRedditPoster.h"

@interface HRDRecordingViewController : UIViewController{
    
    HRDAudioRecorder *recorder;

	//If it's a reply, this string contains the parent's fullname:
    NSString *replyTo;
	
	//If it's a new post, this is the subreddit to post to:
	NSString *subReddit_name;
	
	HRDRedditPoster *redditPoster;
	NSString *modhash;
	NSString *sub_id;

    
    BOOL recording;
    BOOL recorded;
    BOOL playing;
    BOOL paused;
    

    NSString *streamURL;
    NSString *downloadURL;
    
}
- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)postButtonPressed:(id)sender;
- (IBAction)stopRecordingPressed:(id)sender;
-(void)newPostTo:(NSString *)subReddit;
-(void)setSubRedditId:(NSString *)subRedditId;
-(void)postRecording:(NSString *)stream_url;
-(void)setModhash:(NSString*)mod;
-(void)recordingPosted:(NSNotification *)notification;
-(void)setReplyTo:(NSString *)fullName;

@property (weak, nonatomic) IBOutlet UIButton *stopRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@end
