//
//  SinglePost.h
//  oschina
//
//  Created by wangjun on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglePostDetail.h"
#import "Notification_CommentCount.h"
#import "Tool.h"
#import "PubMessage.h"

@interface SinglePost : UIViewController<UIWebViewDelegate,UIActionSheetDelegate>
{
    UIBarButtonItem * btnFavorite;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (void)loadData:(SinglePostDetail *)p;

//帖子id
@property int postID;
@property (retain,nonatomic) SinglePostDetail * singlePost;
- (void)refreshFavorite:(SinglePostDetail *)p;
@end
