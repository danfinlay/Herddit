# How to use the SoundCloud API directly

## Authentication 

### Using the SCLoginViewController (iOS only)

Assuming your app isn't authenticated (`[SCSoundCloud account] == nil`) or you want to relogin you can use the following example to present a login screen.

    @implementation YourViewController
    
    // ...
    
    - (void)login;
    {
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
            
            SCLoginViewController *loginViewController;
            loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                          completionHandler:^(NSError *error){
                                            
                                            if (SC_CANCELED(error)) {
                                                NSLog(@"Canceled!");
                                            } else if (error) {
                                                NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                            } else {
                                                NSLog(@"Done!");
                                            }
            }];
            
            [self presentModalViewController:loginViewController
                                    animated:YES];
            
        }];
    }
    
    @end

### The more complicated way (a.k.a. Mac OS X)

To request access for a certain user, you have to call the class method `+[SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:]`. With this call you trigger an authentication process. In this process a web page has to be opened where the user can sign in to SoundCloud and give your App access to it's account.

    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        // Load the URL in a web view or open it in an external browser
        [[NSWorkspace sharedWorkspace] openURL:preparedURL];
    }];
    
If you open the URL in an external browser, your app delegate has to handel the redirect URL.

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
    {
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                           andSelector:@selector(handleURLEvent:withReplyEvent:)
                                                         forEventClass:kInternetEventClass
                                                            andEventID:kAEGetURL];
    }
    
    - (void)handleURLEvent:(NSAppleEventDescriptor*)event
            withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
    {
        NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
        
        BOOL handled = [SCSoundCloud handleRedirectURL:[NSURL URLWithString:url]];
        if (!handled) {
            NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
        }
    }

### The Authenticated Account

After a successful authentication, you have access to that account via the class method `[SCSoundCloud account]`. You should never keep a reference to this account. Always access the account with this method.

### Removen Access

To log out the authenticated user, you have to call the method `[SCSoundCloud removeAccess]`.

## Invoking Requests on the API

The best way to invoke a request on the API is by calling the class method (see below) on `SCRequest`. You can call this method without an account (nil) for anonymous requests or with the account you get from `[SCSoundCloud account]`. The response is handled in the block you have to pass in the call. There you get the underlying `NSURLResponse` (e.g., to access the status code), the body of the response or (if something went wrong) an error.

    SCAccount *account = [SCSoundCLoud account];
    
    id obj = [SCRequest performMethod:SCRequestMethodGET
                           onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
                      usingParameters:nil
                          withAccount:account
               sendingProgressHandler:nil
                      responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                            // Handle the response
                            if (error) {
                                NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                            } else {
                                // Check the statuscode and parse the data
                            }
              }];
    
In case you would like to cancel the request, you need to keep a reference of the opaque object returned by that method call. Then you can cancel the request with `[SCRequest cancelRequest:obj]`.

### Providing Parameters

If you have to provide parameters, you must create a NSDictionary containing the key value pairs. If a value is a NSURL it is automatically treated as a multipart data.


### Sending Progress

On long running request (e.g., if you upload a track), it is wise to provide the user a feedback how fare the upload is gone. Therefor you can pass a sending progress handler on invocation. This handler is called occasionally with the total and already sent bytes.

     [SCRequest performMethod:SCRequestMethodPOST
                            onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks"]
                       usingParameters:parameters
                           withAccount:account
                sendingProgressHandler:^(unsigned long long bytesSent, unsigned long long bytesTotal){
                                            self.progressView.progress = (float)bytesSent / bytesTotal;
                                       }
                       responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                            // Handle the response
                                       }];


## Listening for Notifications

There are to types of notifications which you might have interest in:

 - SCSoundCloudAccountDidChangeNotification
 - SCSoundCloudDidFailToRequestAccessNotification

### SCSoundCloudAccountDidChangeNotification

This notification is send each time after the account did change. You could use this notification to update the user info.
    
    @implementation MyClass
    
    - (id)init;
    {
        self = [super init];
        if (self) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(accountDidChange:)
                                                         name:SCSoundCloudAccountDidChangeNotification
                                                       object:nil];
        }
        return self;
    }
    
    - (void)dealloc;
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [super dealloc];
    }
    
    - (void)accountDidChange:(NSNotification *)aNotification;
    {
        SCAccount *account = [SCSoundCloud account];
        
        if (account) {
            [SCRequest performMethod:SCRequestMethodGET
                                   onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
                              usingParameters:nil
                                  withAccount:account
                       sendingProgressHandler:nil
                              responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                    // Update the user info
            }];
        } else {
            // Maybe you would like to update your user interface to show that ther is no account.
        }
    }
    
    @end

### SCSoundCloudDidFailToRequestAccessNotification

If something went wrong while requesting access to SoundCloud, the notification `SCSoundCloudDidFailToRequestAccessNotification` is send. To get more details about what, a NSError is provided in the userInfo.

    - (id)init;
    {
        // ...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFailToRequestAccess:)
                                                     name:SCSoundCloudDidFailToRequestAccessNotification
                                                   object:nil];
        // ...
    }
    
    - (void)didFailToRequestAccess:(NSNotification *)aNotification;
    {
        NSError *error = [[aNotification userInfo] objectForKey:kNXOAuth2AccountStoreError];
        NSLog(@"Requesting access to SoundCloud did fail with error: %@", [error localizedDescription]);
    }

## Thats it!

If you haven't had a look at the [documentation of the SoundCloud API](http://developers.soundcloud.com/docs) you should continue there.
