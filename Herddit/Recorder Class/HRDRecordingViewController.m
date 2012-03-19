//
//  HRDRecordingViewController.m
//  Herddit
//
//  Created by Daniel Finlay on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HRDRecordingViewController.h"

@implementation HRDRecordingViewController
@synthesize recordButton;
@synthesize stopRecordingButton;
@synthesize playButton;
@synthesize postButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        recorder = [[HRDAudioRecorder alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingPosted:) name:@"recordingPosted" object:nil];
    }
    return self;
}
-(void)recordingPosted:(NSNotification *)notification{
	
	[[self navigationController] popViewControllerAnimated:YES];
	
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
    [self setRecordButton:nil];
    [self setPlayButton:nil];
    [self setPostButton:nil];
    [self setStopRecordingButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)recordButtonPressed:(id)sender {
    if (recording == NO){
    [recorder startRecording];
        recording = YES;
    }else{
        if (paused == YES){
            [recorder resumeRecording];
        }else{
        [recorder pauseRecording];
        paused = YES;
        }
    }
}
- (IBAction)playButtonPressed:(id)sender {
    if (playing == NO){
        [recorder startPlaying];
        playing = YES;
    }else{
        if (paused == NO){
        [recorder pausePlaying];
        paused = YES;
        }else{
            [recorder resumePlaying];
        }
    }
}

- (IBAction)postButtonPressed:(id)sender {
    
    NSURL *trackURL = recorder.url;
    
    SCShareViewController *shareViewController;
    shareViewController = [SCShareViewController shareViewControllerWithFileURL:trackURL completionHandler:^(NSDictionary *trackInfo, NSError *error){
                                                                  
            if (SC_CANCELED(error)) {
                NSLog(@"Canceled!");
            } else if (error) {
                NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
            } else {
                // If you want to do something with the uploaded
                // track this is the right place for that.
                NSLog(@"Uploaded track: %@", trackInfo);
                                                                      
               streamURL = [[NSString alloc] initWithString:
                            [trackInfo valueForKey:@"stream_url"]];
                downloadURL = [[NSString alloc] initWithString:
                               [trackInfo valueForKey:@"download_url"]];
                
                NSLog(@"Stream URL: %@, Download URL: %@", streamURL, downloadURL);
                [self postRecording:streamURL];                                                    
            }
            }];
    /**
    // If your app is a registered foursquare app, you can set the client id and secret.
    // The user will then see a place picker where a location can be selected.
    // If you don't set them, the user sees a plain plain text filed for the place.
    [shareViewController setFoursquareClientID:@"<foursquare client id>"
                                  clientSecret:@"<foursquare client secret>"];
     **/
    
    // We can preset the title ...
    [shareViewController setTitle:@"Herddit Post"];
    
    // ... and other options like the private flag.
    [shareViewController setPrivate:NO];
    
    // Now present the share view controller.
    [self presentModalViewController:shareViewController animated:YES];
    
}
- (IBAction)stopRecordingPressed:(id)sender {
    [recorder stopRecording];
}

-(void)setReplyTo:(NSString *)fullName{
    replyTo = fullName;
    NSLog(@"Recording view replying to: %@", replyTo);
}
-(void)setModhash:(NSString*)mod{
	modhash = mod;
}
-(void)postRecording:(NSString *)stream_url{
	NSLog(@"Post recording called...");
	redditPoster = [[HRDRedditPoster alloc] init];
	[redditPoster setModhash:modhash];
	
	//If there is no reply string, this is a new post, and so post it:
	if (replyTo == nil){
		//For now we're appending HRD to the subreddit name.  I hope I don't go to hell for this.  It's just easier than figuring out where I started that whole thing in the first place!
		NSString *subR = [[NSString alloc] initWithFormat:@"HRD%@", subReddit_name];
		[redditPoster post:stream_url toSub:subR];
		//Otherwise this is a reply, so post it:
	}else{	
		[redditPoster reply:stream_url toPost:replyTo];
	}
	
}
-(void)newPostTo:(NSString *)subReddit{
	subReddit_name = subReddit;
}

@end
