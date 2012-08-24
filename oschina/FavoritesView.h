//
//  FavoritesView.h
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Favorite.h"
#import "FavoriteCell.h"
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"

@interface FavoritesView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    NSMutableArray * favorites;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentType;
@property (strong, nonatomic) IBOutlet UITableView *tableFavorites;
- (IBAction)segementChanged:(id)sender;

@property int catalog;
-(void)reload:(BOOL)noRefresh;

-(void)clear;
//下拉刷新
-(void)refresh;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

@end
