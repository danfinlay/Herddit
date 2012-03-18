//
//  HRDRiListenViewController.h
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRDTopicArray.h"

@interface HRDRiListenViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	HRDTopicArray *topicArray;
	NSString *currentSubreddit;
	
	NSMutableArray *commentQueue;
}

-(void)finishedLoading:(NSNotification *)notification;
-(void)commentQueueReady:(NSNotification *)notification;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy) NSString *currentSubreddit;

- (IBAction)recordPressed:(id)sender;
- (IBAction)skipPressed:(id)sender;
- (IBAction)playPausePressed:(id)sender;
- (IBAction)backPressed:(id)sender;
@end