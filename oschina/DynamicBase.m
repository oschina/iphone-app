//
//  DynamicBase.m
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DynamicBase.h"

@implementation DynamicBase
@synthesize segment_title;
@synthesize atme;
@synthesize friends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.tabBarItem.title = @"最新动态";
        
        NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                       @"@我",
                                       @"我关注的",
                                       nil];
        self.segment_title = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
        self.segment_title.selectedSegmentIndex = 0;
        self.segment_title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segment_title.segmentedControlStyle = UISegmentedControlStyleBar;
        self.segment_title.frame = CGRectMake(0, 0, 300, 30);
        [self.segment_title addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = self.segment_title;
        //下属控件初始化
        self.atme = [[ActivesView alloc] init];
        self.friends = [[ActivesView alloc] init];
        self.friends.view.hidden = YES;
        [self addChildViewController:self.atme];
        [self addChildViewController:self.friends];
        [self.view addSubview:self.atme.view];
        [self.view addSubview:self.friends.view];
        
        //添加消息中心
        UIBarButtonItem *btnMessage = [[UIBarButtonItem alloc] initWithTitle:@"消息中心" style:UIBarButtonItemStyleBordered target:self action:nil];
        [btnMessage setAction:@selector(pubMessageSystem:)];
        self.navigationItem.rightBarButtonItem = btnMessage;
    }
    return self;
}
-(void)pubMessageSystem:(id)sender
{
    //个人消息中心弹出
    MessageView *msgView = [[MessageView alloc] init];
    [self.navigationController pushViewController:msgView animated:YES];
//    self.title = @"";
//    self.tabBarItem.title = @"最新动态";
    self.title = @"最新动态";
}
-(void)segmentAction:(id)sender
{
    switch (self.segment_title.selectedSegmentIndex)
    {
        case 0:
        {
            self.atme.view.hidden = NO;
            self.friends.view.hidden = YES;
        }
            break;
        case 1:
        {
            self.atme.view.hidden = YES;
            self.friends.view.hidden = NO;
        }
            break;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
@end
