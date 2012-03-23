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

@interface HRDRiListenViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
	HRDTopicArray *topicArray;
	NSString *currentSubreddit;
	
	NSString *sessionCookie;
	NSMutableArray *commentQueue;
	int currentTrack;
		
	AVPlayer *player;
	BOOL isPlaying;
}

-(void)finishedLoading:(NSNotification *)notification;
-(void)commentQueueReady:(NSNotification *)notification;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (copy) NSString *currentSubreddit;

- (IBAction)recordPressed:(id)sender;
- (IBAction)skipPressed:(id)sender;
- (IBAction)playPausePressed:(id)sender;
- (IBAction)backPressed:(id)sender;
-(void)mustLoginAlert;
-(void)recordingPosted:(NSNotification *)notification;
-(void)restartStream;
@end