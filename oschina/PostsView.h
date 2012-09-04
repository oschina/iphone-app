//
//  PostsView.h
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "PostCell.h"
#import "PostBase.h"
#import "SinglePost.h"
#import "MessageSystemView.h"
#import "ShareView.h"

#import "UITap.h"
#import "TQImageCache.h"

@interface PostsView : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * posts;
    BOOL isLoadOver;
    BOOL isLoading;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

    BOOL isInitialize;
    TQImageCache * _iconCache;
}
@property (strong, nonatomic) IBOutlet UITableView *tablePosts;
//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

//重新加载
- (void)reloadType:(int)ncatalog;
- (void)reload:(BOOL)noRefresh;
@property int catalog;
@property (copy, nonatomic) NSString * tag;

//下拉刷新
- (void)clear;
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
