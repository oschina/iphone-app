//
//  TweetBase2.m
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TweetBase2.h"

@implementation TweetBase2
@synthesize segment_title;
@synthesize twitterView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self myInit];
    }
    return self;
}
- (void)myInit
{
    self.navigationController.view.backgroundColor = [UIColor grayColor];
    self.tabBarItem.image = [UIImage imageNamed:@"tweet"];
    self.title = @"动弹";
    self.tabBarItem.title = @"动弹";
    NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                   @"最新动弹",
                                   @"热门动弹",
                                   @"我的动弹",
                                   nil];
    self.segment_title = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
    self.segment_title.selectedSegmentIndex = 0;
    self.segment_title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segment_title.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segment_title.frame = CGRectMake(0, 0, 300, 30);
    [self.segment_title addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment_title;
    //子页面初始化
    self.twitterView = [[TwitterView alloc] init];
    [self addChildViewController:self.twitterView];
    [self.view addSubview:self.twitterView.view];
    //添加发布动弹的按钮
    UIBarButtonItem *btnPubTweet = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    btnPubTweet.image = [UIImage imageNamed:@"tweet24"];
    [btnPubTweet setAction:@selector(clickPubTweet:)];
    self.navigationItem.rightBarButtonItem = btnPubTweet;
}
- (void)clickPubTweet:(id)sender
{
    if ([Config Instance].isLogin == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@"请先登录后再发表动弹"];
        return;
    }
    PubTweet * pubTweet = [[PubTweet alloc] init];
    pubTweet.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pubTweet animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.navigationController andParent:self];
}
- (void)segmentAction:(id)sender
{
    switch (self.segment_title.selectedSegmentIndex) {
        case 0:
        {
           [self.twitterView reloadUID:0];            
        }
            break;
        case 1:
        {
           [self.twitterView reloadUID:-1];
        }
            break;
        case 2:
        {
            int myUID = [Config Instance].getUID;
            if (myUID == 0 || [Config Instance].isCookie == NO) {
                [self.twitterView reloadUID:0];
                [Tool ToastNotification:@"错误 你还未登录,将显示最新动弹" andView:self.view andLoading:NO andIsBottom:NO];
            }
            else
            {
                [self.twitterView reloadUID:myUID];
            }
        }
            break;
    }
}
- (NSString *)getSegmentTitle
{
    switch (self.segment_title.selectedSegmentIndex) {
        case 0:
            return @"最新动弹";
        case 1:
            return @"热门动弹";
        case 2:
            return @"我的";
    }
    return @"";
}

#pragma mark - View lifecycle
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.twitterView = nil;
    self.segment_title = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:[Config Instance].isCookie ? @"1" : @"0"];
    if (self.segment_title == nil || self.twitterView == nil) {
        [self myInit];
    }
}

@end
