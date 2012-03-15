//
//  HRDListView.m
//  Herddit5
//
//  Created by Daniel Finlay on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDListView.h"

@implementation HRDListView
@synthesize activityIndicator;
@synthesize tableView;

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
	[self.activityIndicator stopAnimating];
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//If this is the first time loading subreddits, populate the subreddit menu.
	if ([defaults arrayForKey:@"subReddits"] == nil){
		
		//Stock Subreddit Array:
		NSArray *stockSubreddits = [[NSArray alloc]
								initWithObjects:@"herddit", @"funny", @"politics", @"gaming", @"askherddit", @"worldnews", @"audio", @"IAMA", @"TodayILearned", nil];
		
		[defaults setValue:stockSubreddits forKey:@"subReddits"];
		subRedditArray = [[NSMutableArray alloc] initWithArray:stockSubreddits];
	}else{
		subRedditArray = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"subReddits"]];
	}
	
	//If there is a present session cookie.  This code could be used anywhere.
	if ([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] != nil){
		
	}
	
}
-(void)viewWillAppear:(BOOL)animated{
	
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	subRedditArray = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"subReddits"]];
	
	UIBarButtonItem *addSubReddits = [[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:
			UIBarButtonSystemItemAdd
			target:self action:@selector(addSubReddit)];


	[[self navigationItem] setRightBarButtonItem:addSubReddits];
	
	[self setTitle:@"Sub-Herddits"];
	[self.tableView reloadData];
}

- (void)viewDidUnload
{
	[self setActivityIndicator:nil];
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addSubReddit{
	NSLog(@"Add Subreddit clicked");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What to add?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Subreddit", @"New Topic", @"New Subreddit", nil];
	
	[actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	
	if (buttonIndex == 0){
	HRDNewSubReddit *newSubReddit = [[HRDNewSubReddit alloc] init];
	
	[[self navigationController] pushViewController:newSubReddit animated:YES];
	}
	
	
	
}

//UITableViewDataSource methods:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	
	if ([indexPath section] == 0){
		if([indexPath row] == 0){
			viewCell.textLabel.text = @"Front Page";
			viewCell.textLabel.textColor = [UIColor blueColor];
		}else{
			
		viewCell.textLabel.text = [subRedditArray objectAtIndex:[indexPath row]-1];
			
		}
		//Here is where you could write a section 2 part.
	}
	
	return viewCell;
	
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	if (section == 0){
		return ([subRedditArray count] + 1);
	}else{
		return 0;
	}
	
}

//UITableViewDelegate Methods:
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	int x = 44;
	CGFloat m = (CGFloat)x;
	return m;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	

}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	HRDListenViewController *listenViewController =
	[[HRDListenViewController alloc] init];
	
	if (indexPath.row > 0) {
		listenViewController.currentSubreddit =
		[subRedditArray objectAtIndex:indexPath.row -1];
	}
	[self.navigationController pushViewController:listenViewController animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.row == 0){
		return NO;
	}else{
		return YES;
	}
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.row != 0){
		[subRedditArray removeObjectAtIndex:indexPath.row - 1];
		NSArray *array = [[NSArray alloc] initWithArray:subRedditArray];
		[[NSUserDefaults standardUserDefaults] setValue:array forKey:@"subReddits"];
		
		NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	
}


@end
