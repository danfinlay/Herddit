//
//  HRDTopicArray.h
//  Herddit
//
//  Created by Daniel Finlay on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "HRDTopic.h"

@interface HRDTopicArray : NSObject{
	NSMutableArray *topics;
	NSMutableArray *coordinateArray;
	int currentTopic;
}
-(void)parseData:(NSData *)data;

@property (copy) NSMutableArray *topics;
@property (copy) NSMutableArray *coordinateArray;
@property int currentTopic;
@end
