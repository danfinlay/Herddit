//
//  HRDAppDelegate.m
//  Herddit5
//
//  Created by Daniel Finlay on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDAppDelegate.h"
#import "HRDParentViewController.h"

@implementation HRDAppDelegate

@synthesize window = _window, listenViewController, player;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	//Creating the login view.
	HRDLoginViewController *loginViewController = [[HRDLoginViewController alloc] initWithNibName:@"HRDLoginViewController" bundle:nil];
	NSLog(@"Login view created.");
	
	//Creating & setting up the navigation controller.
	HRDParentViewController *parentViewController = [[HRDParentViewController alloc] initWithRootViewController:loginViewController];
	parentViewController.toolbarHidden = YES;
	parentViewController.navigationBarHidden = YES;
	
		[[self window] setRootViewController: parentViewController];
	
	
	//If login credentials are stored, log in with those here, and push the logged in list screen to the top of the parentViewController here.
	if ([[NSUserDefaults standardUserDefaults] 
		 
		 //First we'll plug the data into the login screen
		 objectForKey:@"redditUser"] != nil){
		loginViewController.usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"redditUser"];
		loginViewController.passwordField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"redditPassword"];
		
		listenViewController = [[HRDRiListenViewController alloc] init];
	}
	
	
	NSLog(@"Login view presented...");
	
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}
 
- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

+ (void)initialize;
{
	[super initialize];
    [SCSoundCloud  setClientID:@"4c65f6b723a93defa57007fc8d0ebc44"
                        secret:@"e1f6e9fb10edc8ba1176e630c50456d0"
                   redirectURL:[NSURL URLWithString:@"herdit://url"]];
}


-(void)bootListen{
	listenViewController = [[HRDRiListenViewController alloc] init];
}

-(void)initPlayerWithUrl:(NSURL *)url{
	player = [[AVPlayer alloc] initWithURL:url];
}
-(void)killPlayer{
	player = nil;
}
@end
