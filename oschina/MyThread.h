//
//  MyThread.h
//  oschina
//
//  Created by wangjun on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCNotice.h"
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "TweetPubCache.h"

@interface MyThread : NSObject
{
    //明天用 NSTimer 控件
    NSTimer * timer;
    
    BOOL isRunning;
}

- (void)startNotice;
- (void)startPubTweet:(NSString *)msg andImg:(NSData *)imgData;
- (void)startUpdatePortrait:(NSData *)imgData;

@property (strong, nonatomic) UIView * mainView;

+(MyThread *)Instance;
+(id)allocWithZone:(NSZone *)zone;

@end
