//
//  NewsView.h
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "News.h"
#import "NewsDetail.h"
#import "ShareView.h"
#import "MessageSystemView.h"
#import "NewsCell.h"
#import "NewsBase.h"
#import "ASIProgressDelegate.h"
#import "MBProgressHUD.h"
#import "BlogUnit.h"

//下拉刷新的委托
@interface NewsView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate, UITabBarControllerDelegate,UIAlertViewDelegate>
{
    NSMutableArray * news;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong, nonatomic) IBOutlet UITableView *tableNews;
@property int catalog;
- (void)reloadType:(int)ncatalog;
- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
