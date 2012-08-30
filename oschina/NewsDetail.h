//
//  NewsDetail.h
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleNews.h"
#import "ShareObject.h"
#import "Notification_CommentCount.h"
#import "Tool.h"
#import "MessageSystemPub.h"
#import "SingleNews.h"
#import "RegexKitLite.h"
#import "MBProgressHUD.h"

@interface NewsDetail : UIViewController<UIWebViewDelegate>
{
    UIBarButtonItem * btnFavorite;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property BOOL isNextPage;
@property int newsID;
@property (retain,nonatomic) SingleNews * singleNews;

- (void)loadData:(SingleNews *)n;
- (void)refreshFavorite:(SingleNews *)n;

@end
