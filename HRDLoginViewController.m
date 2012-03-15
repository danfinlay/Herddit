//
//  HRDLoginViewController.m
//  Herddit5
//
//  Created by Daniel Finlay on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRDTextField.h"
#import "HRDLoginViewController.h"

@implementation HRDLoginViewController
@synthesize usernameField;
@synthesize passwordField;
@synthesize statusLabel;
@synthesize goButton;
@synthesize stayLoggedIn;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        	NSLog(@"Login view initialized.");
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
	
	
	NSLog(@"Login view did load");
	activityIndicator.hidesWhenStopped = YES;
	[activityIndicator stopAnimating];
    [super viewDidLoad];
	
	if ([[NSUserDefaults standardUserDefaults] valueForKey: @"stayLoggedOn"] != @"yes"){
		stayLoggedIn.on = YES;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults valueForKey:@"userName"] != nil){
		usernameField.text = [defaults valueForKey:@"userName"];
		passwordField.text = [defaults valueForKey:@"password"];

		
		if (stayLoggedIn.on == YES){
			[self goButton];
		}
	}
	
	
		[[self navigationController] setNavigationBarHidden:YES];
	
}

- (void)viewDidUnload
{
	[self setStatusLabel:nil];
	[self setUsernameField:nil];
	[self setPasswordField:nil];
    [self setGoButton:nil];
	[self setStayLoggedIn:nil];
	[self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//This following method is how I allow hopping between text fields.
//The technique is outlined here, and explains my HRDTextField class:  http://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
	
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
	
    if ([textField isKindOfClass:[HRDTextField class]])
        dispatch_async(dispatch_get_current_queue(), 
					   ^ { [[(HRDTextField*)textField nextField] becomeFirstResponder]; });
	
    return YES;
	
}

- (IBAction)listenOnlyModePressed:(id)sender {
	

	
	HRDListView *listViewController = 
	[[HRDListView alloc] initWithNibName:@"HRDListView" bundle:nil];
	 
		[[self navigationController] pushViewController:listViewController animated:YES];

	
}

- (void) viewWillAppear:(BOOL)animated
{
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"sessionCookie"];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (IBAction)goButtonPressed:(id)sender {
	
	goButton.selected = NO;
	[activityIndicator startAnimating];
	
	NSMutableString *post = [[NSMutableString alloc] initWithString:@"user="];
	[post appendString:usernameField.text];
	[post appendString:@"&passwd="];
	[post appendString:passwordField.text];
	
	if (stayLoggedIn.on){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:usernameField.text forKey:@"userName"];
		[defaults setValue:passwordField.text forKey:@"password"];
		[defaults setValue:@"yes" forKey:@"stayLoggedOn"];
		}
	
	NSLog(@"POST: %@", post);
	
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
        statusLabel.text = @"Login failed.  Try again?";
    }  
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  
{  
    [receivedData setLength:0];  
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    [receivedData appendData:data];  
}  

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  
{  
	goButton.selected = YES;
	[activityIndicator stopAnimating];
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);  
    NSString *aStr = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];  
    NSLog(@"%@", aStr);  
	
	//Check if "wrong password error" is present.
	if ([aStr rangeOfString:@"error.WRONG_PASSWORD.field"].location == NSNotFound) {
		
		//Check if "too many logins" error is present.
		if ([aStr rangeOfString:@"you are doing that too much."].location == NSNotFound) {
			
					//Otherwise, we've logged in!  Send that session to the delegate and let's get rolling!
					NSLog(@"Logged in successfully!");
			
			
			
				//If the user selected stay logged in, store that info for later.
			if (stayLoggedIn.on == YES){
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				
				NSDictionary *userLogin = [[NSDictionary alloc] initWithObjectsAndKeys:usernameField.text, @"redditUser", passwordField.text, @"redditPassword", nil];
				
				[defaults registerDefaults: userLogin];
			}
			

			NSMutableArray *cookies = [[NSMutableArray alloc] initWithArray:[[NSHTTPCookieStorage		sharedHTTPCookieStorage] cookies]];

			
			NSEnumerator *enumerator = [cookies objectEnumerator];
			
			id anObject;
			NSLog(@"Enumerating:");
			int counter = 0;
			
			while (anObject = [enumerator nextObject]){
				
				NSHTTPCookie *enumeratedCookie = anObject;
				
				NSLog(@"%i:\n\n", counter);
				NSLog(@"AnObject:\n%@\n", anObject);
				NSLog(@"EnumeratedCookie:\n%@\n", enumeratedCookie);
				NSLog(@"EnumeratedCookieValue:\n%@\n", [enumeratedCookie value]);
				counter++;
				
				//I know, this is stupid and ugly.  For some reason this enumeration method is the only way I've gotten the right cookie out reliably to provide this session value.  You'd think a simple array objectAtIndex:1 would have done, right?  Maybe my bad luck.
				
					if (counter == 1) {
						[[NSUserDefaults standardUserDefaults] setValue:[enumeratedCookie value] forKey:@"sessionCookie"];
					}}
			

			HRDListView *listViewController = 
			[[HRDListView alloc] initWithNibName:@"HRDListView" bundle:nil];
			
			[[self navigationController] pushViewController:listViewController animated:YES];
			

			
				//In this case, we've logged in too much.  Let's tell the user how long to wait.
			//(This part doesn't work yet)
				}else{

				errorRange = [aStr rangeOfString:@"you are doing that too much."];
					

					NSString *endString = [[NSString alloc] initWithString:@"]], "];
				
					NSString *displayString;
					
					scanner = [[NSScanner alloc] initWithString:aStr];
					
					[scanner setScanLocation:errorRange.location];
					[scanner scanUpToString:endString intoString:&displayString];
					
					errorRange.length = [displayString length] - 1;
					errorRange.location = 0;
					
					NSLog(@"Scanner result: %@", displayString);
					
					NSLog(@"Manual String: %@", [aStr substringWithRange:errorRange]);
					
					NSString *displayString2 = 
					[displayString substringWithRange:errorRange];
					
					//This part makes up for the not-working part, by being unambitious, not telling how long to wait.
					statusLabel.text = displayString2;
					
		}
		
	} else {
		NSLog(@"Wrong Password.");
		statusLabel.text = @"Incorrect Password.";
	}
	
	
    // release the connection, and the data object  
}  



@end
