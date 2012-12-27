//
//  ActivesView.h
//  oschina
//
//  Created by wangjun on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDetail.h"
#import "PostDetail.h"
#import "Activity.h"
//#import "ColorActiveCell.h"
#import "FTCoreTextView.h"
#import "ShareView.h"
#import "News.h"
#import "Post.h"
#import "Tweet.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownloader.h"
#import "ObjectReply.h"
#import "RTActiveCell.h"
#import "TQImageCache.h"

@interface ActivesView : UIViewController<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
{
    NSMutableArray *activies;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    TQImageCache * _iconCache;
}
@property (strong, nonatomic) IBOutlet UITableView *tableActivies;

- (void)reloadType:(int)ncatalog;
@property int catalog;
- (void)reload:(BOOL)noRefresh;

//异步加载图片专用
//@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
//@property (nonatomic, retain) NSMutableDictionary *tweetDownloadsInProgress;
//- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;
//- (void)startIconDownload2:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)clear;
//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
