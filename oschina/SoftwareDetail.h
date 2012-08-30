//
//  SoftwareDetail.h
//  oschina
//
//  Created by wangjun on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "EGOImageView.h"
#import "Software.h"

@interface SoftwareDetail : UIViewController<UIWebViewDelegate>
{
    NSString *str_homepage;
    NSString *str_document;
    NSString *str_download;
    
    UIBarButtonItem * btnFavorite;
    
    int objid;
}
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (copy,nonatomic) NSString * softwareName;

- (NSString *)getButtonString:(NSString *)homePage andDocument:(NSString *)document andDownload:(NSString *)download;

- (void)loadData:(Software *)s;
- (void)refreshFavorite:(Software *)s;
@end
