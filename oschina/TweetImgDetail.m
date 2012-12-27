//
//  TweetImgDetail.m
//  oschina
//
//  Created by wangjun on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TweetImgDetail.h"

@implementation TweetImgDetail
@synthesize toolBar;
@synthesize webView;
@synthesize imgHref;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Tool clearWebViewBackground:webView];
    
    NSString *img = [NSString stringWithFormat:@"<div style='margin:auto;width:640px;'><img width='640' style='vertical-align:middle' src='%@'/></div>", self.imgHref];
    [self.webView loadHTMLString:img baseURL:nil];
    
    if (IS_IPHONE_5) {
        self.toolBar.frame = CGRectMake(0, -88, 320, 44);
    }
}
- (void)clickCloseThis:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [Tool ReleaseWebView:self.webView];
    [self setWebView:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}


@end
