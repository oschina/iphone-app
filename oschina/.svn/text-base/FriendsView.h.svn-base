//
//  FriendsView.h
//  oschina
//
//  Created by wangjun on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "MBProgressHUD.h"
#import "FriendCell.h"

@interface FriendsView : UIViewController<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * friends;
    BOOL isLoading;
    BOOL isLoadOver;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property int fansCount;
@property int followersCount;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segement;
- (IBAction)segementChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableFriends;
@property BOOL isFansType;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
-(void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;
-(void)reloadType;
-(void)reload:(BOOL)noRefresh;
-(void)clear;

//下拉刷新
-(void)refresh;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;
@end
