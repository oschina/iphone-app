//
//  TwitterView.h
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetDetail.h"
#import "TweetCell.h"
#import "MessageSystemView.h"
#import "Tool.h"
#import "TweetBase2.h"
#import "UITap.h"
#import "EGOImageView.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownloader.h"
#import "TQImageCache.h"

@interface TwitterView : UIViewController<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * tweets;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    BOOL isInitialize;
    TQImageCache * _iconCache;
}

//TableView
@property (strong, nonatomic) IBOutlet UITableView *tableTweets;

//异步加载图片
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableDictionary *tweetDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)startIconDownload2:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

//加载不同类型的动弹列表 最新/热门/我的
//如果为0 则加载所有人最新的动弹 否则加载指定uid 的最新动弹
@property int _uid;
- (void)reloadUID:(int)newUID;
- (void)reload:(BOOL)noRefresh;

//清空列表
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
