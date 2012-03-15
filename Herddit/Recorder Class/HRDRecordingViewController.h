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

@interface HRDRecordingViewController : UIViewController{
    
    HRDAudioRecorder *recorder;

    NSString *replyTo;
    
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
-(void)replyTo:(NSString *)fullName;

@property (weak, nonatomic) IBOutlet UIButton *stopRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@end
