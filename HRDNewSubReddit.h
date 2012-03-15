//
//  HRDNewSubReddit.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRDNewSubReddit : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *subredditInput;
- (IBAction)saveButton:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
