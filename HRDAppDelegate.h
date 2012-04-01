//
//  HRDAppDelegate.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRDParentViewController.h"
#import "HRDLoginViewController.h"
#import "SCUI.h"
#import <AVFoundation/AVFoundation.h>
#import "HRDRiListenViewController.h"


@class HRDRiListenViewController;

@interface HRDAppDelegate : UIResponder <UIApplicationDelegate>{
	HRDRiListenViewController *listenViewController;
	AVPlayer *player;
}

-(void)bootListen;
-(void)initPlayerWithUrl:(NSURL *)url;
-(void)killPlayer;
@property (readwrite, retain) AVPlayer *player;
@property (readwrite, retain) HRDRiListenViewController *listenViewController;
@property (strong, nonatomic) UIWindow *window;


@end
