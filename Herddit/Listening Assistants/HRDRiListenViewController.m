//
//  HRDRiListenViewController.m
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDRiListenViewController.h"

@implementation HRDRiListenViewController
@synthesize currentTimeLabel;
@synthesize durationLabel;
@synthesize upVoteButton;
@synthesize downVoteButton;
@synthesize slider;
@synthesize tableView, currentSubreddit;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
		sessionCookie = [[NSUserDefaults standardUserDefaults] valueForKey:@"sessionCookie"];
		self.title = NSLocalizedString(currentSubreddit, @"currentSubreddit");
		
		topicArray = [[HRDTopicArray alloc] initWithSubreddit:currentSubreddit];
		voter = [[HRDRedditVoter alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoading:) name:@"finishedLoading" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentQueueReady:) name:@"commentQueueReady" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingPosted:) name:@"recordingPosted" object:nil];
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

	currentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
	currentTrack = currentSelection.row;

	NSLog(@"Loading completed.  Requesting stream to begin.");
	[self restartStream];
	
}
- (IBAction)sliderChanged:(id)sender {
	if (player != nil){
		
		
		
		[player seekToTime:CMTimeMakeWithSeconds([slider value], 1)];
		 }

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

-(void)recordingPosted:(NSNotification *)notification{
	
	[[topicArray.topics objectAtIndex:topicArray.currentTopic] fetchComments];
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
	upVoteButton = nil;
	[self setUpVoteButton:nil];
	[self setDownVoteButton:nil];
	[self setSlider:nil];
	[self setCurrentTimeLabel:nil];
	[self setDurationLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)downVotePressed:(id)sender {
	if ([[commentQueue objectAtIndex:currentSelection.row] vote] != -1){
		[voter downVote:[commentQueue objectAtIndex:currentSelection.row]];
		UIImage *downVoteImage = [[UIImage alloc] initWithContentsOfFile:@"downvote-blue.png"];
		[downVoteButton setImage:downVoteImage forState:UIControlStateNormal];
		
		UIImage *upVoteImage = [[UIImage alloc] initWithContentsOfFile:@"upvote-grey.png"];
		[upVoteButton setImage:upVoteImage forState:UIControlStateNormal];
	}else {
		[voter unVote:[commentQueue objectAtIndex:currentSelection.row]];
		UIImage *voteImage = [[UIImage alloc] initWithContentsOfFile:@"downvote-grey.png"];
		[downVoteButton setImage:voteImage forState:UIControlStateNormal];
	}
}

- (IBAction)upVotePressed:(id)sender {
	if ([[commentQueue objectAtIndex:currentSelection.row] vote] != 1){
		[voter upVote:[commentQueue objectAtIndex:currentSelection.row]];
		UIImage *upVoteImage = [[UIImage alloc] initWithContentsOfFile:@"upvote-orange.png"];
		[upVoteButton setImage:upVoteImage forState:UIControlStateNormal];
		
		UIImage *downVoteGrey = [[UIImage alloc] initWithContentsOfFile:@"downvote-grey.png"];
		[downVoteButton setImage:downVoteGrey forState:UIControlStateNormal];
	}else {
		[voter unVote:[commentQueue objectAtIndex:currentSelection.row]];
		UIImage *voteImage = [[UIImage alloc] initWithContentsOfFile:@"upvote-grey.png"];
		[upVoteButton setImage:voteImage forState:UIControlStateNormal];
	}
}

- (IBAction)recordPressed:(id)sender {
	
  if (sessionCookie !=nil){
	  
	  if (currentTrack == 0){
		  NSLog(@"Record clicked");
		  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Record" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"New Topic", nil];
		  [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
		  
	  }else{
	  
    NSLog(@"Record clicked");
     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Record" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply to Current", @"Reply to Previous", @"New Topic", nil];
    [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
	  }
  }else{
	  [self mustLoginAlert];
	}
}

- (IBAction)skipPressed:(id)sender {
	[player pause];
	//If there are topics left in this subreddit:
	if (topicArray.currentTopic+1<[topicArray.topics count]){
		topicArray.currentTopic++;
		[topicArray loadComments];
	//If there aren't:	
	}
}

- (IBAction)playPausePressed:(id)sender {
	if (isPlaying){
		[player pause];
		isPlaying = NO;
	}else{
		[player play];
		isPlaying = YES;
	}
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"Index path selected: %i.\nAttempting to play from commentQueue of %i.", indexPath.row, [commentQueue count]);
	currentTrack = indexPath.row;
	[self restartStream];
}
-(void)restartStream{
	
	//Highlight the correct item:
	[tableView selectRowAtIndexPath:currentSelection animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	
	
	NSLog(@"Restart stream called.");
	player = nil;
	NSLog(@"Player cleared.");
	
	
	[slider setValue:0.0 animated:NO];
	
	NSString *originalUrl = [[commentQueue objectAtIndex:currentTrack] body];
	NSString *theLetterS = [[NSString alloc] initWithString:@"s"];
	//Identify if this is an https connection, if it is, we need to cut off the "s" before sending it to the AVPlayer.  This works for SoundCloud, I hope it works in all cases :)
	if([originalUrl characterAtIndex:4] == [theLetterS characterAtIndex:0]){
		//Cut off the s
		NSString *newString = [[NSString alloc] initWithFormat:@"%@%@", [originalUrl substringToIndex:4], [originalUrl substringFromIndex:5]];
		originalUrl = newString;
	}
	
	NSLog(@"Attempting to stream %@", originalUrl);
	player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:originalUrl]];
	
	NSLog(@"Player initialized.  Status: %@", [player status]);
	[player play];
	NSLog(@"Player asked to play.  Status: %@",[player status]);
	isPlaying = YES;
	
	//The following deals with the slider and its time labels:
//	NSString *timeDescription = (__bridge NSString *)CMTimeCopyDescription(NULL, [player currentTime]);
//	durationLabel.text = timeDescription;
	
	duration = CMTimeGetSeconds(player.currentItem.asset.duration);
	slider.maximumValue = duration;
	int minutes = round(duration/60);
	int seconds = round(duration-(minutes * 60));

	NSString *minuteString;
	NSString *secondString;
	if (minutes < 10){
		minuteString = [[NSString alloc] initWithFormat:@"0%i", minutes];
	}else{
		minuteString = [[NSString alloc] initWithFormat:@"%i", minutes];
	}
	if (seconds < 10){
		secondString = [[NSString alloc] initWithFormat:@"0%i", seconds];
	}else{
		secondString = [[NSString alloc] initWithFormat:@"%i", seconds];
	}		
	NSString *currentTimeString = [[NSString alloc] initWithFormat:@"%@:%@",minuteString, secondString];
	durationLabel.text = currentTimeString;

	playerObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1) queue:NULL usingBlock:^(CMTime time){
		
		progress = CMTimeGetSeconds([player currentTime]);
		
		if (progress >= duration){
			if (skippable == YES){
				skippable = NO;
				NSLog(@"Track %i ended.  Calling next.", currentTrack);
				[self nextComment];
			}
		}else{
		skippable = YES;
		progress = CMTimeGetSeconds(time);
		[slider setValue:progress animated:YES];
		int minutes = round(progress/60);
		int seconds = round(progress-(minutes * 60));
		
		NSString *minuteString;
		NSString *secondString;
		if (minutes < 10){
			minuteString = [[NSString alloc] initWithFormat:@"0%i", minutes];
		}else{
			minuteString = [[NSString alloc] initWithFormat:@"%i", minutes];
		}
		if (seconds < 10){
			secondString = [[NSString alloc] initWithFormat:@"0%i", seconds];
		}else{
			secondString = [[NSString alloc] initWithFormat:@"%i", seconds];
		}		
		NSString *currentTimeString = [[NSString alloc] initWithFormat:@"%@:%@",minuteString, secondString];
		currentTimeLabel.text = currentTimeString;
		}
		
	}];
	
//		
//	//Notification for the end of the track:
//	[[NSNotificationCenter defaultCenter] 
//	 addObserver:self
//	 selector:@selector(trackEnded:)
//	 name:AVPlayerItemDidPlayToEndTimeNotification 
//	 object:player];
	
}
-(void)nextComment{
	[tableView deselectRowAtIndexPath:currentSelection animated:YES];
	
	if (currentTrack + 1 < [commentQueue count]){
		currentTrack++;
		NSIndexPath *newPath = [NSIndexPath indexPathForRow:currentSelection.row + 1 inSection:0];
		currentSelection = newPath;
		[self restartStream];
	}else{
		[self skipPressed:nil];
	}
}

-(void)mustLoginAlert{
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not logged in." 
	message:@"You must be logged in to do that." 
	delegate:nil 
	cancelButtonTitle:@"OK"
	otherButtonTitles:nil];
	
[alert show];
 	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	 
	//If track is 0, then no "reply to previous" button was displayed.
	if (currentTrack == 0){
		if (buttonIndex == 0){
			//Reply to Current pressed.
			HRDRecordingViewController *recordingView = [[HRDRecordingViewController alloc] init];
			[recordingView setReplyTo:
			 [[commentQueue objectAtIndex:currentTrack] link_id]];
			[[self navigationController] pushViewController:recordingView animated:YES];
		}else if (buttonIndex == 1){
			//New Topic Pressed.
			HRDRecordingViewController *recordingView = [[HRDRecordingViewController alloc] init];
			[recordingView newPostTo:currentSubreddit];
			[[self navigationController] pushViewController:recordingView animated:YES];
		}
		
		//This represents the regular 3-button option set.
	}else{
	if (buttonIndex == 0){
		//Reply to Current pressed.
		HRDRecordingViewController *recordingView = [[HRDRecordingViewController alloc] init];
		[recordingView setReplyTo:
		 [[commentQueue objectAtIndex:currentTrack] link_id]];
		[[self navigationController] pushViewController:recordingView animated:YES];
		
	}else if (buttonIndex == 1){
		//Reply to Previous pressed.
		HRDRecordingViewController *recordingView = [[HRDRecordingViewController alloc] init];
		if (currentTrack < 0){
		[recordingView setReplyTo:
		 [[commentQueue objectAtIndex:currentTrack-1] link_id]];
			[[self navigationController] pushViewController:recordingView animated:YES];
		}
		
	}else if (buttonIndex == 2){
		//New Topic Pressed.
		HRDRecordingViewController *recordingView = [[HRDRecordingViewController alloc] init];
		[recordingView newPostTo:currentSubreddit];
		[[self navigationController] pushViewController:recordingView animated:YES];
	}
	}
}

@end
