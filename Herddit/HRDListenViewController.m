//
//  HRDListenViewController.m
//  Herddit5
//
//  Created by Daniel Finlay on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDListenViewController.h"

@implementation HRDListenViewController
@synthesize authorData;
@synthesize commentKarma;
@synthesize progressSlider;
@synthesize karmaFraction;
@synthesize postKarmaLabel;
@synthesize hrdTitle;
@synthesize soundLength;
@synthesize currentTimeProgress;
@synthesize activityIndicator;
@synthesize currentSubreddit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        playing = NO;
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

-(void)viewWillAppear:(BOOL)animated{
	
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
	
}
- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	currentPost = 0;
	
	if (sessionCookie == nil){
		sessionCookie = [[NSUserDefaults standardUserDefaults] valueForKey:@"sessionCookie"];
	}
	
    if (currentSubreddit == nil){
		currentSubreddit = @"herddit";
	}
	
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://www.reddit.com/r/HRD"];
	[urlString appendString:currentSubreddit];
	[urlString appendString:@".json"];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSLog(@"%@", urlString);
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(connection){
		receivedData = [NSMutableData data];
	}else{
		//Inform the user connection failed.  For now, just popping.
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDictLoaded:) name:@"dataDict loaded" object:dataDictionary];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{

    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	[[self navigationController] popViewControllerAnimated:YES];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	currentCoordinateArray = nil;
	[activityIndicator stopAnimating];
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error = [[NSError alloc] init];
	outData = [deserializer deserialize:receivedData error:&error];
	
	NSLog(@"Main Subreddit Data: %@", outData);
	[self callForDataDict];
	[self playPost];
}

-(void)playPost{
	
	NSDictionary *currentDict = [self dictionaryForCurrent];
	NSLog(@"Current post's data: %@", currentDict);
	
	[self callForDataDict];
	
	if ([NSMutableArray arrayWithArray:[commentsArray commentArray]] != nil){
	realCommentsArray = [NSMutableArray arrayWithArray:[commentsArray commentArray]];
		NSLog(@"\nCurrent Post's comments:\n %@", realCommentsArray);
	}

	NSString *author = [currentDict valueForKey:@"author"];
	authorData.text = author;
	
	subReddit = [[NSMutableString alloc] init];
	[subReddit appendString: [currentDict valueForKey:@"subreddit"]];
	hrdTitle.text = subReddit;
	
	NSNumber *score = [currentDict valueForKey:@"score"];
	postKarmaLabel.text = [score stringValue];
	
	NSNumber *downVotes =  [currentDict valueForKey:@"downs"];
	
	int upvoteInt, downvoteInt;
	
	downvoteInt = [downVotes intValue];
	upvoteInt = [score intValue] + downvoteInt;
	NSMutableString *karmaFractionString = [[NSMutableString alloc] initWithFormat:@"(%i/%i)", upvoteInt, downvoteInt];
	karmaFraction.text = karmaFractionString;
	

	
}
-(void)playURL:(NSURL *)url{
	
	NSLog(@"Play URL called!");
	audioPlayer = [[AVPlayer alloc] initWithURL:url];
	[audioPlayer play];
	
}


//This is a convenience method for getting info on the current topic.  The integer refers to what object # in the "currentCoordinateArray" will be called down on.
-(NSDictionary *)dictionaryForCurrent{
	
	if ([currentCoordinateArray count] == 0){
	id data1 = [[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:0] valueForKey:@"data"];
		return data1;
	}else{
		return [self returnNode:1 fromDictionary:[realCommentsArray objectAtIndex: [currentCoordinateArray objectAtIndex:0]]]; 
	}
}

-(NSDictionary *)returnNode:(int)number fromDictionary:(NSDictionary *)oldDictionary{
	if (number == [[[[oldDictionary objectForKey:@"replies"] objectForKey:@"data"] objectForKey:@"children"] count]){
		return oldDictionary;
	}else{
		int newNumber = [[currentCoordinateArray objectAtIndex:number] intValue];
		
		[self returnNode:number + 1 fromDictionary:[[[[oldDictionary objectForKey:@"replies"] objectForKey:@"data"] objectForKey:@"children"] objectAtIndex:newNumber]];
	}
}

-(void)callForDataDict{
	
	commentsArray = [[HRDCommentArray alloc] initWithPermalink:[[self dictionaryForCurrent] valueForKey:@"permalink"] delegate:self];
}

-(void)dataDictLoaded:(NSDictionary *)dataDict{
	dataDictionary = dataDict;
	NSLog(@"Data dict loaded method called.  What did we get? %@", dataDictionary);
}

-(void)playPostNumber:(int)postNumber{
	
	NSString *author = [[[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:postNumber] valueForKey:@"data"] valueForKey:@"author"];
	authorData.text = author;
	
	subReddit = [[NSMutableString alloc] init];
	[subReddit appendString: [[[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:postNumber] valueForKey:@"data"] valueForKey:@"subreddit"]];
	hrdTitle.text = subReddit;
	
	NSNumber *score =  [[[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:postNumber] valueForKey:@"data"] valueForKey:@"score"];
	postKarmaLabel.text = [score stringValue];
	
	NSNumber *downVotes =  [[[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:postNumber] valueForKey:@"data"] valueForKey:@"downs"];
	
	//I was really tired when I put this here.  I'm not sure this is where it belongs anymore.  It was accompanied by a [self playURL:streamURL] line at the end of this method.
/**	NSURL *streamURL = [[NSURL alloc] initWithString:
						[[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:postNumber] valueForKey:@"url"]];
**/
	
	int upvoteInt, downvoteInt;
	
	downvoteInt = [downVotes intValue];
	upvoteInt = [score intValue] + downvoteInt;
	NSMutableString *karmaFractionString = [[NSMutableString alloc] initWithFormat:@"(%i/%i)", upvoteInt, downvoteInt];
	karmaFraction.text = karmaFractionString;
	
	id data1 = [[[[outData valueForKey:@"data"] valueForKey:@"children"] objectAtIndex:postNumber] valueForKey:@"data"];

	
	currentFullname = [[self dictionaryForCurrent] valueForKey:@"link_id"];
	
	id data2 = [[outData valueForKey:@"data"] valueForKey:@"children"];
	
	NSLog(@"Current post's children: %@", data1);
	
	/*data1 returns a dictionary with the following keys: (
	 "selftext_html",
	 author,
	 hidden,
	 media,
	 "subreddit_id",
	 "over_18",
	 "is_self",
	 permalink,
	 name,
	 created,
	 url,
	 "created_utc",
	 subreddit,
	 "num_comments",
	 id,
	 thumbnail,
	 levenshtein,
	 likes,
	 score,
	 clicked,
	 "author_flair_css_class",
	 title,
	 selftext,
	 saved,
	 "media_embed",
	 downs,
	 domain,
	 "author_flair_text",
	 ups
	 )
	 */
	NSLog(@"About to load comments for permalink: %@", [data1 valueForKey:@"permalink"]);
	
	commentsArray = [[HRDCommentArray alloc] initWithPermalink:[data1 valueForKey:@"permalink"] delegate:self];
	


}

- (IBAction)getInfo:(id)sender {
}

- (void)viewDidUnload
{
	[connection cancel];
	[self setAuthorData:nil];
	[self setCommentKarma:nil];
	[self setKarmaFraction:nil];
	[self setActivityIndicator:nil];
	[self setProgressSlider:nil];
    [self setCurrentTimeProgress:nil];
    [self setSoundLength:nil];
	[self setPostKarmaLabel:nil];
	[self setHrdTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)back:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)upVote:(id)sender {

	if (upvoted == YES){
		[self rescindVote];
	}else{
	

	if (sessionCookie !=nil){
			upvoted = YES;
	NSMutableString *post = [[NSMutableString alloc] initWithString:@"id="];
	[post appendString:currentFullname];
	[post appendString:@"&dir="];
	[post appendString:@"1"];
	[post appendString:@"&uh="];
	[post appendString:sessionCookie];
	
	NSLog(@"Upvote POST: %@", post);
	
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
	
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];  
    [request setURL:[NSURL URLWithString:@"http://www.reddit.com/api/login"]];  
    [request setHTTPMethod:@"POST"];  
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
    [request setHTTPBody:postData];  
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
    if (conn)   
    {  
        receivedData = [NSMutableData data];
		NSLog(@"Received: %@", receivedData);
		
		if (receivedData != nil){
			
			
			NSLog(@"%@", receivedData.description);
		}
		
    }   
    else   
    {  
        NSLog(@"Login failed.  Try again?");
    } 
	}else{
		[self mustLoginAlert];
	}
	}
	
}

- (IBAction)downVote:(id)sender {
	
	if (downvoted == YES){
		[self rescindVote];
	}else{
	
	if (sessionCookie !=nil){
		
		downvoted = YES;
		NSMutableString *post = [[NSMutableString alloc] initWithString:@"id="];
		[post appendString:currentFullname];
		[post appendString:@"&dir="];
		[post appendString:@"-1"];
		[post appendString:@"&uh="];
		[post appendString:sessionCookie];
		
		NSLog(@"Upvote POST: %@", post);
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];  
		[request setURL:[NSURL URLWithString:@"http://www.reddit.com/api/login"]];  
		[request setHTTPMethod:@"POST"];  
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
		[request setHTTPBody:postData];  
		
		NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
		if (conn)   
		{  
			receivedData = [NSMutableData data];
			NSLog(@"Received: %@", receivedData);
			
			if (receivedData != nil){
				
				
				NSLog(@"%@", receivedData.description);
			}
			
		}   
		else   
		{  
			NSLog(@"Login failed.  Try again?");
		} 
	}else{
		[self mustLoginAlert];
	}
	}
	
}
-(void)rescindVote{
	if (sessionCookie !=nil){
		
		NSMutableString *post = [[NSMutableString alloc] initWithString:@"id="];
		[post appendString:currentFullname];
		[post appendString:@"&dir="];
		[post appendString:@"0"];
		[post appendString:@"&uh="];
		[post appendString:sessionCookie];
		
		NSLog(@"Upvote POST: %@", post);
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];  
		[request setURL:[NSURL URLWithString:@"http://www.reddit.com/api/login"]];  
		[request setHTTPMethod:@"POST"];  
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
		[request setHTTPBody:postData];  
		
		NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
		if (conn)   
		{  
			receivedData = [NSMutableData data];
			NSLog(@"Received: %@", receivedData);
			
			if (receivedData != nil){
				
				
				NSLog(@"%@", receivedData.description);
			}
			
		}   
		else   
		{  
			NSLog(@"Login failed.  Try again?");
		} 
	}else{
		[self mustLoginAlert];
	}
	
}

- (IBAction)lastComment:(id)sender {
}

- (IBAction)nextComment:(id)sender {
	
	if ([previousCoordinateArray count] == 5){
		[previousCoordinateArray removeObjectAtIndex:0];
	}
	[previousCoordinateArray addObject: currentCoordinateArray];
	
	//Check if there are comments to this node, or if we should continue with peers.  We'll increment the coordinateArray, and if it returns nil, we'll remove it, increment the peer, if that returns nil, we'll remove it, increment the parent, etc... Sounds like another job for recursion...
	[currentCoordinateArray addObject:[NSNumber numberWithInt:0]];
	if ([self findNextComment]){
		[self playPost];
	};
	
}
-(BOOL)findNextComment{
	
	//First check if current coordinate is real:
	if ([self dictionaryForCurrent]!= nil){
		NSLog(@"Next comment found! Coordinate: %@", currentCoordinateArray);
		return YES;
	}else{
		NSLog(@"No reply was found.  Trying new comment...");
	//If not, pop off the last object in the coordinate array,
		[currentCoordinateArray removeObjectAtIndex:[currentCoordinateArray count]];
	
	//Increment the new last object,
		int old = [currentCoordinateArray objectAtIndex:[currentCoordinateArray count]];
		int new = old++;
		
		[currentCoordinateArray removeObjectAtIndex:[currentCoordinateArray count]];
		[currentCoordinateArray addObject:[NSNumber numberWithInt:new]];
		NSLog(@"Trying: %@", currentCoordinateArray);

		return [self findNextComment];
	}
}
- (IBAction)lastTopic:(id)sender {	
	previousFullname = currentFullname;
	currentPost -= 1;
	[self playPostNumber:currentPost];
}

- (IBAction)nextTopic:(id)sender {
	previousFullname = currentFullname;
	currentPost += 1;
	[self playPostNumber:currentPost];
}

- (IBAction)record:(id)sender {
		if (sessionCookie !=nil){
			
			NSLog(@"Record clicked");
			
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Record" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply to Current", @"Reply to Previous", @"New Topic", nil];
			
			[actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
			
			
		}else{
			[self mustLoginAlert];
		}
}
//Here are the record actionsheet's responses:
//It does not yet differentiate for whether this is a new post, a reply to previous, or reply to current.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	HRDRecordingViewController *recordingView = [[HRDRecordingViewController alloc] init];
	[recordingView newPostTo:subReddit];
    [[self navigationController] pushViewController:recordingView animated:YES];
}




- (IBAction)playPause:(id)sender {
	
	if (playing){
		[audioPlayer pause];
	}else{
		[audioPlayer play];
	}
	
}

- (IBAction)scrubbing:(id)sender {
	
	
	
}
-(void)mustLoginAlert{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not logged in." 
		message:@"You must be logged in to do that." 
								delegate:nil 
								cancelButtonTitle:@"OK"
								otherButtonTitles:nil];
	[alert show];
}

@end
