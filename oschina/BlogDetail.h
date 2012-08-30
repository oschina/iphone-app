//
//  BlogDetail.h
//  oschina
//
//  Created by wangjun on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "Blog.h"

@interface BlogDetail : UIViewController<UIWebViewDelegate>
{
    UIBarButtonItem * btnFavorite;
}
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) Blog * singleBlog;
@property int blogID;

- (void)loadData:(Blog *)b;
- (void)refreshFavorite:(Blog *)b;
@end
