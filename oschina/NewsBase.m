//
//  NewsBase.m
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsBase.h"

@implementation NewsBase
@synthesize segment_title;
@synthesize newsView;

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
    self.tabBarItem.image = [UIImage imageNamed:@"info"];
    self.tabBarItem.title = @"综合";

    NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                   @"资讯",
                                   @"博客",
                                   @"推荐阅读",
                                   nil];
    self.segment_title = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
    self.segment_title.selectedSegmentIndex = 0;
    self.segment_title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segment_title.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segment_title.frame = CGRectMake(0, 0, 300, 30);
    [self.segment_title addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment_title;
    
    //子页面初始化
    self.newsView = [[NewsView alloc] init];
    self.newsView.catalog = 1;
    [self addChildViewController:self.newsView];
    [self.view addSubview:self.newsView.view];
    
    //添加发布动弹的按钮
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    btnSearch.image = [UIImage imageNamed:@"searchWhite"];
    [btnSearch setAction:@selector(clickSearch:)];
    self.navigationItem.rightBarButtonItem = btnSearch;
}
- (void)clickSearch:(id)sender
{
    SearchView * sView = [[SearchView alloc] init];
    sView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sView animated:YES];
}
- (void)segmentAction:(id)sender
{
    [self.newsView reloadType:self.segment_title.selectedSegmentIndex+1];
}
- (NSString *)getSegmentTitle
{
    switch (self.segment_title.selectedSegmentIndex) {
        case 0:
            return @"资讯";
        case 1:
            return @"博客";
        case 2:
            return @"推荐阅读";
    }
    return @"";
}

#pragma mark - View lifecycle
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.segment_title = nil;
    self.newsView = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (self.newsView == nil || self.segment_title == nil) 
    {
        [self myInit];
    }
}

@end
