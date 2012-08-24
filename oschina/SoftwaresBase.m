//
//  SoftwaresBase.m
//  oschina
//
//  Created by wangjun on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoftwaresBase.h"

@implementation SoftwaresBase
@synthesize segment_Title;
@synthesize softwareView;
@synthesize softwareTypeView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *titles = [NSArray arrayWithObjects:
                   @"分类",
                   @"推荐",
                   @"最新",
                   @"热门",
                   @"国产",
                   nil];
    self.segment_Title = [[UISegmentedControl alloc] initWithItems:titles];
    self.segment_Title.selectedSegmentIndex = 0;
    self.segment_Title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segment_Title.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segment_Title.frame = CGRectMake(0, 0, 300, 30);
    [self.segment_Title addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment_Title;
    
    self.softwareTypeView = [[SoftwareTypeView alloc] init];
    self.softwareTypeView.tag = 0;
    self.softwareView = [[SoftwareView alloc] init];
    self.softwareView.isSoftwareTagList = NO;
    self.softwareView.view.hidden = YES;
    [self addChildViewController:self.softwareTypeView];
    [self addChildViewController:self.softwareView];
    [self.view addSubview:self.softwareTypeView.view];
    [self.view addSubview:self.softwareView.view];
}
-(void)segmentAction:(id)sender
{
    switch (self.segment_Title.selectedSegmentIndex) {
        case 0:
        {
            self.softwareTypeView.view.hidden = NO;
            self.softwareView.view.hidden = YES;
        }
            break;
        case 1:
        {
            self.softwareTypeView.view.hidden = YES;
            self.softwareView.view.hidden = NO;
            self.softwareView.searchTag = @"recommend";
            [self.softwareView reloadType];
        }
            break;
        case 2:
        {
            self.softwareTypeView.view.hidden = YES;
            self.softwareView.view.hidden = NO;
            self.softwareView.searchTag = @"time";
            [self.softwareView reloadType];
        }
            break;
        case 3:
        {
            self.softwareTypeView.view.hidden = YES;
            self.softwareView.view.hidden = NO;
            self.softwareView.searchTag = @"view";
            [self.softwareView reloadType];
        }
            break;
        case 4:
        {
            self.softwareTypeView.view.hidden = YES;
            self.softwareView.view.hidden = NO;
            self.softwareView.searchTag = @"list_cn";
            [self.softwareView reloadType];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.segment_Title = nil;
}

@end
