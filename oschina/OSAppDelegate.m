//
//  OSAppDelegate.m
//  oschina
//
//  Created by wangjun on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OSAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation OSAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize settingView;
@synthesize newsBase;
@synthesize postBase;
@synthesize tweetBase;
@synthesize profileBase;

#pragma mark 程序生命周期
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    //设置 UserAgent
    [ASIHTTPRequest setDefaultUserAgentString:[NSString stringWithFormat:@"%@/%@", [Tool getOSVersion], [Config Instance].getIOSGuid]];
    
    //显示系统托盘
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    //检查网络是否存在 如果不存在 则弹出提示
    [Config Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];

    //动弹页 
    self.tweetBase = [[TweetBase2 alloc] initWithNibName:@"TweetBase2" bundle:nil];
    UINavigationController * tweetNav = [[UINavigationController alloc] initWithRootViewController:self.tweetBase];
    
    //问答页
    self.postBase = [[PostBase alloc] initWithNibName:@"PostBase" bundle:nil];
    UINavigationController * postNav = [[UINavigationController alloc] initWithRootViewController:self.postBase];
    
    //动态页;
    self.profileBase = [[ProfileBase alloc] initWithNibName:@"ProfileBase" bundle:nil];
    UINavigationController * profileNav = [[UINavigationController alloc] initWithRootViewController:profileBase];
    
    //设置页 
    self.settingView = [[SettingView alloc] initWithNibName:@"SettingView" bundle:nil];
    UINavigationController * settingNav = [[UINavigationController alloc] initWithRootViewController:self.settingView];
    settingNav.navigationBarHidden = NO;
    
    //新闻页
    self.newsBase = [[NewsBase alloc] initWithNibName:@"NewsBase" bundle:nil];
    UINavigationController *newsNav = [[UINavigationController alloc] initWithRootViewController:self.newsBase];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                         newsNav,
                         postNav,
                         tweetNav,
                         profileNav,
                         settingNav,
                         nil];
    //初始化
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    //启动轮询  如果已经登录的话
    if ([Config Instance].isCookie) {
        [[MyThread Instance] startNotice];
        
    }
    
    [MyThread Instance].mainView = self.tabBarController.view;
    //准备未处理的异常
    [NdUncaughtExceptionHandler setDefaultHandler];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
//    NSLog(@"WillEnterForeground");
//    [Config Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [Config Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    if ([Config Instance].isNetworkRunning == NO) {
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"未连接网络,将使用离线模式" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
		[myalert show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark UITab双击事件
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    int newTabIndex = self.tabBarController.selectedIndex;
    if (newTabIndex == m_lastTabIndex) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_TabClick object:[NSString stringWithFormat:@"%d", newTabIndex]];
    }
    else
    {
        m_lastTabIndex = newTabIndex;
    }
}



@end
