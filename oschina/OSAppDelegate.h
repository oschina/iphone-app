//
//  OSAppDelegate.h
//  oschina
//
//  Created by wangjun on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingView.h"
#import "DataSingleton.h"
#import "CheckNetwork.h"
#import "PostBase.h"
@class PostBase;
#import "ProfileBase.h"
@class ProfileBase;
#import "NewsBase.h"
@class NewsBase;
#import "TweetBase2.h"
@class TweetBase2;
#import "SettingView.h"
@class SettingView;
#import "NdUncaughtExceptionHandler.h"

@interface OSAppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate>
{
    int m_lastTabIndex;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) NewsBase * newsBase;
@property (strong, nonatomic) PostBase * postBase;
@property (strong, nonatomic) TweetBase2 * tweetBase;
@property (strong, nonatomic) ProfileBase * profileBase;
@property (strong, nonatomic) SettingView * settingView;

@end
