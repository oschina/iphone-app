//
//  MessageView.h
//  oschina
//
//  Created by wangjun on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessageSystemView.h"
#import "MessageCell.h"
#import "PubMessage.h"
#import "Tool.h"
#import "ApiError.h"
#import "MyBubbleView.h"

#define FetchCount 10;

@interface MessageView : UIViewController<UITableViewDataSource,UITableViewDelegate, IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * msgs;
    BOOL isLoading;
    BOOL isLoadOver;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong, nonatomic) IBOutlet UITableView *tableMsgs;
- (void)reload:(BOOL)noRefresh;

@property BOOL isLoginJustNow;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

//下拉刷新
- (void)clear;
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
