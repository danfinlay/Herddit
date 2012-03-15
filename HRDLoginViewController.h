//
//  HRDLoginViewController.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRDListView.h"
#import "CJSONDeserializer.h"


@interface HRDLoginViewController : UIViewController{
	NSMutableData *receivedData;
	NSRange errorRange;
	NSScanner *scanner;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UISwitch *stayLoggedIn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)goButtonPressed:(id)sender;
- (BOOL) textFieldShouldReturn:(UITextField *) textField;
- (IBAction)listenOnlyModePressed:(id)sender;


//NSURLRequest delegate methods:
- (void)didReceiveMemoryWarning;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end
