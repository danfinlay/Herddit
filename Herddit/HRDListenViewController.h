//
//  HRDListenViewController.h
//  Herddit5
//
//  Created by Daniel Finlay on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJSONDeserializer.h"
#import "HRDCommentArray.h"
#import <AVFoundation/AVFoundation.h>
#import "HRDRecordingViewController.h"
#import "HRDTopicArray.h"

@interface HRDListenViewController : UIViewController <NSURLConnectionDelegate, UIActionSheetDelegate>
{
	//If this subreddit is nil, we load "frontpage"
	//(Doesn't yet exist, just loads HRDreddit by default.)
	NSString *currentSubreddit;
	NSString *subReddit_id;
	
	//This is where received xml data goes:
	NSMutableData *receivedData;
	NSURLConnection *connection;
	
	HRDTopicArray *topicArray;
	
	//Outdata is the result of parsing receivedData w/
	//CJSON Deserializer.
	NSMutableData *outData;
	
	NSString *sessionCookie;
	NSMutableString *subReddit;
	
	//This helps the un-voting clicks work properly.
	BOOL upvoted;
	BOOL downvoted;
	
	//This counts the posts down in the current subReddit.  It is typically referenced in the context of calling "listenToPostNumber:"
	int currentPost;
	
	//These strings are used when replying to a post.  The option is given which to reply to, this data is needed to submit a reply appropriately.
	NSString *currentFullname;
	NSString *previousFullname;
	
	//This is called an array, but really it deals with downloading comment data.  Yeah, I'm an asshole.
	HRDCommentArray *commentsArray;
	
	//Here's that array of comments you probably expected before.
	NSMutableArray *realCommentsArray;
	
	//This array is to keep track of where in the current comment tree we are.  An empty array means listening to the root post.  The count is how many nodes deep we are, each object is an NSNumber of how many comments down each level we are.
	NSMutableArray *currentCoordinateArray;
	
	//This array is of previous "currentCoordinateArray"s, most recent is last.  Pop them off when there's more than 5.  We don't need more than 5.  Save memory.
	NSMutableArray *previousCoordinateArray;
	
	NSDictionary *dataDictionary;
	
	AVPlayer *audioPlayer;
	BOOL playing;
}

@property (weak, nonatomic) IBOutlet UILabel *hrdTitle;
@property (weak, nonatomic) IBOutlet UILabel *soundLength;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) NSString *currentSubreddit;
@property (weak, nonatomic) IBOutlet UILabel *authorData;
@property (weak, nonatomic) IBOutlet UILabel *commentKarma;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *karmaFraction;
@property (weak, nonatomic) IBOutlet UILabel *postKarmaLabel;
- (IBAction)back:(id)sender;
- (IBAction)upVote:(id)sender;
- (IBAction)downVote:(id)sender;
- (IBAction)lastComment:(id)sender;
- (IBAction)nextComment:(id)sender;
- (IBAction)lastTopic:(id)sender;
- (IBAction)nextTopic:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)scrubbing:(id)sender;
-(void)mustLoginAlert;
-(void)rescindVote;
-(void)playPostNumber:(int)postNumber;
- (IBAction)getInfo:(id)sender;
-(void)playPost;
-(void)playURL:(NSURL *)url;
-(NSDictionary *)dictionaryForCurrent;
-(void)callForDataDict;
-(void)dataDictLoaded:(NSDictionary *)dataDict;
-(NSDictionary *)returnNode:(int)number fromDictionary:(NSDictionary *)oldDictionary;
-(BOOL)findNextComment;
@end
