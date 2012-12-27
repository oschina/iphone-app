//
//  ShareView.m
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareView.h"

@implementation ShareView
@synthesize imgSina;
@synthesize imgQQ;
@synthesize url;
@synthesize content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.tabBarItem.title = @"分享";
    self.tabBarItem.image = [UIImage imageNamed:@"share"];
    self.title = @"分享";
    self.navigationController.title = @"分享";
    self.parentViewController.navigationController.title = @"分享";
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title = @"分享到微博";
    
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabBarItem.title = @"分享";
    self.tabBarItem.image = [UIImage imageNamed:@"share"];
    self.title = @"分享";
    self.navigationController.title = @"分享";
    self.parentViewController.navigationController.title = @"分享";
    
    tapSina = [[UITap alloc] initWithTarget:self action:@selector(click_weibo:)];
    [imgSina addGestureRecognizer:tapSina];
    
    tapQQ = [[UITap alloc] initWithTarget:self action:@selector(click_qqshare:)];
    [imgQQ addGestureRecognizer:tapQQ];
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    
    if (IS_IPHONE_5) {
        self.imgSina.frame = CGRectMake(40, 137, 240, 44);
        self.imgQQ.frame = CGRectMake(40, 260, 240, 44);
    }
}

- (void)viewDidUnload
{
    [self setImgSina:nil];
    [self setImgQQ:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)click_qqshare:(id)sender {
    
    NSString *share_url = @"http://share.v.t.qq.com/index.php?c=share&a=index";
    NSString *share_Source = @"OSChina";
    NSString *share_Site = @"OSChina.NET";
    NSString *share_AppKey = @"96f54f97c4de46e393c4835a266207f4";
    
    if ([Config Instance].shareObject) {
        NSString *all = [NSString stringWithFormat:@"%@&title=%@&url=%@&appkey=%@&source=%@&site=%@", 
                         share_url,
                         [[Config Instance].shareObject.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[Config Instance].shareObject.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         share_AppKey,
                         share_Source,
                         share_Site];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:all]];
    }
}

- (IBAction)click_weibo:(id)sender {
    
    NSString *share_url = @"http://v.t.sina.com.cn/share/share.php";
    if ([Config Instance].shareObject) {
        NSString *all = [NSString stringWithFormat:@"%@?appkey=%@&title=%@&url=%@",
                         
                         share_url,
                         SinaAppKey,
                         [[Config Instance].shareObject.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[Config Instance].shareObject.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:all]];
    }
}

@end
