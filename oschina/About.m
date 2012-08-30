//
//  About.m
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "About.h"

@implementation About
@synthesize lblVersion;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *btnWeb = [[UIBarButtonItem alloc] initWithTitle:@"访问手机版" style:UIBarButtonItemStyleBordered target:self action:@selector(clickWeb:)];
    self.navigationItem.rightBarButtonItem = btnWeb;
    
    self.lblVersion.text = [NSString stringWithFormat:@"版本: %@", AppVersion];
    
    self.navigationItem.title = @"关于我们";
}
- (void)clickWeb:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://m.oschina.net"]];
}
- (void)viewDidUnload
{
    [self setLblVersion:nil];
    [super viewDidUnload];
}

@end
