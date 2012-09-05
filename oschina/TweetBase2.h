//
//  TweetBase2.h
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterView.h"
#import "PubTweet.h"

@interface TweetBase2 : UIViewController<UIActionSheetDelegate>

@property (strong, nonatomic) UISegmentedControl * segment_title;
@property (strong, nonatomic) TwitterView * twitterView;

- (NSString *)getSegmentTitle;

- (void)myInit;

@end
