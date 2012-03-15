//
//  HRDNewSubReddit.m
//  Herddit5
//
//  Created by Daniel Finlay on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDNewSubReddit.h"

@implementation HRDNewSubReddit
@synthesize subredditInput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"New SubHerddit";
}

- (void)viewDidUnload
{
    [self setSubredditInput:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveButton:(id)sender {
	
	NSMutableArray *array = [[NSMutableArray alloc] initWithArray: [[NSUserDefaults standardUserDefaults] arrayForKey:@"subReddits"]];
	
	[array addObject:subredditInput.text];
	
	NSArray *array2 = [[NSArray alloc] initWithArray:array];
	
	[[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"subReddits"];

	[[self navigationController] popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self saveButton:nil];
	return YES;
}
@end
