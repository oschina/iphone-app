//
//  ProfileBase.m
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ProfileBase.h"

@implementation ProfileBase
@synthesize segment_Title;
@synthesize activesView;
@synthesize msgView;
@synthesize titles;
@synthesize isLoginJustNow;

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
    self.tabBarItem.image = [UIImage imageNamed:@"active"];
    self.tabBarItem.title = @"我的";
    self.titles = [NSArray arrayWithObjects:
                   @"所有",
                   @"@我",
                   @"评论",
                   @"我自己",
                   @"留言",
                   nil];
    self.segment_Title = [[UISegmentedControl alloc] initWithItems:self.titles];
    self.segment_Title.selectedSegmentIndex = 0;
    self.segment_Title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segment_Title.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segment_Title.frame = CGRectMake(0, 0, 300, 30);
    [self.segment_Title addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment_Title;
    
    //下属控件初始化
    self.activesView = [[ActivesView alloc] init];
    self.activesView.catalog = 1;
    self.msgView = [[MessageView alloc] init];
    self.msgView.view.hidden = YES;
    [self addChildViewController:self.activesView];
    [self addChildViewController:self.msgView];
    [self.view addSubview:self.activesView.view];
    [self.view addSubview:self.msgView.view];
}
- (void)viewDidLoad
{
    nextTabIndexByNotice = -1;
    [super viewDidLoad];
    //消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeUpdateHandler:) name:Notification_NoticeUpdate object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    //改变 tabIndex
    if (nextTabIndexByNotice != -1) {
        self.segment_Title.selectedSegmentIndex = nextTabIndexByNotice;
        //可能需要后续处理
        nextTabIndexByNotice = -1;
        if (self.segment_Title.selectedSegmentIndex == 4) {
            [self.msgView refresh];
        }
        [self segmentAction:nil];
    }
    
    if (self.segment_Title == nil || self.activesView == nil) {
        [self myInit];
    }
    //登录判断
    if ([Config Instance].isCookie == NO) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请登录后查看信息" delegate:self cancelButtonTitle:@"返回" destructiveButtonTitle:nil otherButtonTitles:@"登录", nil];
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    //如果已经登录 则判断是否是刚刚登录  如果是  则刷新
    else if(self.isLoginJustNow)
    {
        self.isLoginJustNow = NO;
        [Config Instance].viewBeforeLogin = nil;
        [Config Instance].viewNameBeforeLogin = nil;
        if (self.activesView) {
            //显示变化
            switch (self.segment_Title.selectedSegmentIndex) 
            {
                case 0:
                case 1:
                case 2:
                case 3:
                {
                    self.activesView.view.hidden = NO;
                    self.msgView.view.hidden = YES;
                    [self.activesView reloadType:self.segment_Title.selectedSegmentIndex+1];
                }
                    return;
            }
        }
        if (self.msgView) {
            switch (self.segment_Title.selectedSegmentIndex) {
                case 4:
                {
                    self.activesView.view.hidden = YES;
                    self.msgView.view.hidden = NO;
                    [self.msgView reload:YES];
                }
                    return;
            }
        }
    }
   }
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"登录"]) {
        LoginView *loginView = [[LoginView alloc] init];
        loginView.isPopupByNotice = YES;
        [Config Instance].viewBeforeLogin = self;
        [Config Instance].viewNameBeforeLogin = @"ProfileBase";
        [self.navigationController pushViewController:loginView animated:YES];
        return;
    }
}

- (void)noticeUpdateHandler:(NSNotification *)notification
{
    OSCNotice *notice = (OSCNotice *)[notification object];
    if (notice) {
        int all = notice.atmeCount + notice.msgCount + notice.reviewCount + notice.newFansCount;
        if (all) {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", notice.atmeCount + notice.msgCount + notice.reviewCount + notice.newFansCount];
        }
        else
        {
            self.tabBarItem.badgeValue = nil;
        }
        [self.segment_Title setTitle:notice.atmeCount ? [NSString stringWithFormat:@"@我(%d)", notice.atmeCount] : @"@我" forSegmentAtIndex:1];
        [self.segment_Title setTitle:notice.reviewCount ? [NSString stringWithFormat:@"评论(%d)", notice.reviewCount] : @"评论" forSegmentAtIndex:2];
        [self.segment_Title setTitle:notice.msgCount ? [NSString stringWithFormat:@"留言(%d)", notice.msgCount] : @"留言" forSegmentAtIndex:4];
        
        //优先级获取
        if (notice.atmeCount > 0) {
            nextTabIndexByNotice = 1;
        }
        else if(notice.reviewCount > 0){
            nextTabIndexByNotice = 2;
        }
        else if(notice.msgCount > 0){
            nextTabIndexByNotice = 4;
        }
        else{
            nextTabIndexByNotice = -1;
        }
    }
    else
    {
        self.tabBarItem.badgeValue = nil;
    }
}
- (void)segmentAction:(id)sender
{
    if ([Config Instance].isCookie == NO) {
        return;
    }
    int noticeClearType = -1;
    switch (self.segment_Title.selectedSegmentIndex) {
        case 1:
            noticeClearType = 1;
            break;
        case 2:
            noticeClearType = 3;
            break;
        case 4:
            noticeClearType = 2;
            break;
    }
    //显示变化
    switch (self.segment_Title.selectedSegmentIndex) 
    {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            self.activesView.view.hidden = NO;
            self.msgView.view.hidden = YES;
            [self.activesView reloadType:self.segment_Title.selectedSegmentIndex+1];
        }
            break;
        case 4:
        {
            self.activesView.view.hidden = YES;
            self.msgView.view.hidden = NO;
            if (self.isLoginJustNow) {
                [self.msgView reload:NO];
                self.isLoginJustNow = NO;
            }
        }
            break;
    }

        [self clearOSCNotice:noticeClearType];
}
- (void)clearOSCNotice:(int)type
{
    //写入Notice_Clear
    NSString *url = [NSString stringWithFormat:@"%@?uid=%d&type=%d", api_notice_clear, [Config Instance].getUID, type];
    [[AFOSCClient sharedClient] getPath:url parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    [Tool getOSCNotice2:operation.responseString];
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                }];
}
- (NSString *)getSegmentTitle
{
    switch (self.segment_Title.selectedSegmentIndex) {
        case 0:
            return @"所有";
        case 1:
            return @"@我";
        case 2:
            return @"评论";
        case 3:
            return @"我自己";
        case 4:
            return @"留言";
    }
    return @"";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.msgView = nil;
    self.activesView = nil;
    self.segment_Title = nil;
}

@end
