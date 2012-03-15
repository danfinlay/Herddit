/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
 */

#import "UIView+SoundCloudUI.h"


@implementation UIView (SoundCloudUI)

- (void)resignFirstResponderOfAllSubviews;
{
	[self resignFirstResponder];
	for (UIView *subView in self.subviews) {
		[subView resignFirstResponderOfAllSubviews];
	}
}

- (UIView *)firstResponderFromSubviews;
{
	if ([self isFirstResponder])
		return self;
	for (UIView *subView in self.subviews) {
		UIView *childFirstResponder = [subView firstResponderFromSubviews];
		if (childFirstResponder)
			return childFirstResponder;
	}
	return nil;
}

- (UIScrollView *)enclosingScrollView;
{
	UIView *superView = self.superview;
	if (superView) {
		if ([superView isKindOfClass:[UIScrollView class]]) {
			return (UIScrollView *)superView;
		} else {
			return superView.enclosingScrollView;
		}
	}
	return nil;
}

@end
