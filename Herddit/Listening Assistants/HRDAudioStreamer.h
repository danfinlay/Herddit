//
//  HRDAudioStreamer.h
//  Herddit
//
//  Created by Daniel Finlay on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

@interface HRDAudioStreamer : NSObject<NSURLConnectionDelegate>{
	
	NSURL *stream_url;
	NSURL *mp3_url;
	
	//This is for receiving data:
	NSMutableData *receivedData;
	NSURLConnection *connection;
}
-(id)initWithStream:(NSURL *)url;


@property (copy) NSURL *mp3_url;
@end
