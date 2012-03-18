//
//  HRDRiListenViewController.m
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDRiListenViewController.h"

@implementation HRDRiListenViewController
@synthesize tableView, currentSubreddit;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		topicArray = [[HRDTopicArray alloc] initWithSubreddit:currentSubreddit];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoading:) name:@"finishedLoading" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentQueueReady:) name:@"commentQueueReady" object:nil];
    }
    return self;
}
-(void)commentQueueReady:(NSNotification *)notification{
	

	NSArray *tempArray = [topicArray commentQueue];
	commentQueue = [[NSMutableArray alloc] initWithArray:tempArray];
	
	NSLog(@"RiListenViewController, commentQueueReady:  We may have our comment queue of %i comments.  Enumerating:", [commentQueue count]);
	
	for(int i = 0; i < [commentQueue count]; i++)
		NSLog(@"Comment author: %@", [[commentQueue objectAtIndex:i] author]);
	
	
	[tableView reloadData];

	
}
-(void)finishedLoading:(NSNotification *)notification{
	NSLog(@"Finished loading received.  Trying to parse topic array.");
	
	NSArray *tempArray = [topicArray commentQueue];
	commentQueue = [[NSMutableArray alloc] initWithArray:tempArray];
	
	NSLog(@"We may have our comment queue of %i comments.  Enumerating:", [commentQueue count]);
	for(int i = 0; i < [commentQueue count]; i++)
		NSLog(@"Comment author: %@, type: %@, indentation: %@.", [[commentQueue objectAtIndex:i] author], [[commentQueue objectAtIndex:i] class], 
			  [[commentQueue objectAtIndex:i] indentation]);
	
	
	[tableView reloadData];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
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

- (IBAction)recordPressed:(id)sender {
}

- (IBAction)skipPressed:(id)sender {
}

- (IBAction)playPausePressed:(id)sender {
}

- (IBAction)backPressed:(id)sender {
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%@", indexPath]];
	
	[viewCell.textLabel setText:[[commentQueue objectAtIndex:indexPath.row] author]];
	[[viewCell detailTextLabel] setText:@"Subtitle can go here"];

	
	NSLog(@"Error object's class, for sure: %@", [[commentQueue objectAtIndex:indexPath.row] class]);
	viewCell.indentationLevel=
	 [[commentQueue objectAtIndex:indexPath.row] indentation];
	viewCell.indentationWidth = 20.0;
	
	//Set a max indentation of 5.
	if ([[commentQueue objectAtIndex:indexPath.row] indentation] > 5)
		[viewCell setIndentationLevel:5];
	
	return viewCell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [commentQueue count];
}
@end
