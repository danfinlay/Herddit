//
//  HRDListView.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRDNewSubReddit.h"
#import "HRDRiListenViewController.h"
#import "HRDAppDelegate.h"

@interface HRDListView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
	NSMutableArray *subRedditArray;
}

-(void)addSubReddit;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;




@end
