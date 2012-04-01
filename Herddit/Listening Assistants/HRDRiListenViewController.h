//
//  HRDRiListenViewController.h
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRDTopicArray.h"
#import "HRDRecordingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HRDAppDelegate.h"
#import "HRDRedditVoter.h"


@interface HRDRiListenViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
	HRDTopicArray *topicArray;
	NSString *currentSubreddit;
	
	NSString *sessionCookie;
	NSMutableArray *commentQueue;
	int currentTrack;
	NSIndexPath *currentSelection;
		
	AVPlayer *player;
	BOOL isPlaying;
	id playerObserver;
		
	Float64 progress;
	Float64 duration;
	BOOL skippable;
		
	HRDRedditVoter *voter;
}

@property (weak, nonatomic) IBOutlet UIButton *upVoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downVoteButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (copy) NSString *currentSubreddit;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

- (IBAction)downVotePressed:(id)sender;
- (IBAction)upVotePressed:(id)sender;
- (IBAction)recordPressed:(id)sender;
- (IBAction)skipPressed:(id)sender;
- (IBAction)playPausePressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)sliderChanged:(id)sender;

-(void)finishedLoading:(NSNotification *)notification;
-(void)commentQueueReady:(NSNotification *)notification;
-(void)mustLoginAlert;
-(void)recordingPosted:(NSNotification *)notification;
-(void)restartStream;
-(void)nextComment;



@end