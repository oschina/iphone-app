//
//  UserActiveView.h
//  oschina
//
//  Created by wangjun on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "QuadCurveMenu.h"
#import "QuadCurveMenuItem.h"
#import "UserView2.h"
#import "UserInfoView.h"

@interface UserActiveView : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *activies;
    BOOL isLoading;
    BOOL isLoadOver;
    int relationShip;
    
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong, nonatomic) IBOutlet UITableView *tableActivies;

@property int hisUID;
@property (nonatomic,retain) NSString * hisName;

-(void)reload:(BOOL)isAllInfo andNoRefresh:(BOOL)noRefresh;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableDictionary *tweetDownloadsInProgress;
-(void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;
-(void)startIconDownload2:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

-(void)clear;
//下拉刷新
-(void)refresh;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

@end
