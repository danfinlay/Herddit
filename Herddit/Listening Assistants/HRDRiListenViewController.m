//
//  HRDRiListenViewController.m
//  Herddit
//
//  Created by Daniel Finlay on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDRiListenViewController.h"

#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation HRDRiListenViewController
@synthesize tableView, currentSubreddit;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
		currentTrack = 0;
		paused = NO;
		sessionCookie = [[NSUserDefaults standardUserDefaults] valueForKey:@"sessionCookie"];
		self.title = NSLocalizedString(currentSubreddit, @"currentSubreddit");
		
		topicArray = [[HRDTopicArray alloc] initWithSubreddit:currentSubreddit];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoading:) name:@"finishedLoading" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentQueueReady:) name:@"commentQueueReady" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingPosted:) name:@"recordingPosted" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUrlRetrieved:) name:@"streamUrlRetrieved" object:nil];
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
	currentTrack = 0;
	[tableView reloadData];
	[self playTrack];
}

-(void)recordingPosted:(NSNotification *)notification{
	topicArray = nil;
	topicArray = [[HRDTopicArray alloc] initWithSubreddit:currentSubreddit];
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
	topicArray.currentTopic += 1;
	[topicArray buildCommentQueue];
}

- (IBAction)playPausePressed:(id)sender {
	if(paused){
		[streamer start];
	}else{
		[streamer pause];
	}
}

- (IBAction)backPressed:(id)sender {
	if (topicArray.currentTopic != 0){
		topicArray.currentTopic -= 1;
		[topicArray buildCommentQueue];
	}
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
	currentTrack = indexPath.row;
	[self playTrack];
	
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
-(void)playTrack{
	NSLog(@"Playtrack pressed, requesting stream: %@", [[commentQueue objectAtIndex:currentTrack] body]);
	streamFetcher = [[HRDAudioStreamer alloc] initWithStream:[[commentQueue objectAtIndex:currentTrack] body]];
}
-(void)streamUrlRetrieved:(NSNotification *)notification{

	mp3url = [streamFetcher mp3_url];
	NSLog(@"Mp3 url returned: %@", mp3url);
	[self createStreamer];
	[streamer start];
}
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
	
	[self destroyStreamer];
	
	NSString *escapedValue =
	(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
					nil,
					(__bridge CFStringRef)mp3url,
					NULL,
					NULL,
					kCFStringEncodingUTF8);
	
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
	[NSTimer
	 scheduledTimerWithTimeInterval:0.1
	 target:self
	 selector:@selector(updateProgress:)
	 userInfo:nil
	 repeats:YES];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];
}

// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		streamer = nil;
	}
}

// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
				NSLog(@"Playback state changed, streamer was waiting.");
	}
	else if ([streamer isPlaying])
	{
		NSLog(@"Playback state changed, streamer was playing.");
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		NSLog(@"Playback state changed, streamer was idle, and has been destroyed.");
	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
						[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		
	}
}


@end
