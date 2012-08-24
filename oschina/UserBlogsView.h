//
//  UserBlogsView.h
//  oschina
//
//  Created by wangjun on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogUnit.h"
#import "Tool.h"

@interface UserBlogsView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
{
    NSMutableArray * blogs;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property int authorUID;
@property (retain,nonatomic) NSString * authorName;

@property (strong, nonatomic) IBOutlet UITableView *tableBlogs;

-(void)reload:(BOOL)noRefresh;
-(void)clear;
//下拉刷新
-(void)refresh;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

@end
