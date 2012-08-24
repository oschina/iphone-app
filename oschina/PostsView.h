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
@class PostBase;
#import "SinglePost.h"
#import "MessageSystemView.h"
#import "ShareView.h"

#import "UITap.h"

@interface PostsView : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * posts;
    BOOL isLoadOver;
    BOOL isLoading;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

}
@property (strong, nonatomic) IBOutlet UITableView *tablePosts;
//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

-(void)reloadType:(int)ncatalog;
-(void)reload:(BOOL)noRefresh;
@property int catalog;
@property (retain, nonatomic) NSString * tag;

-(void)clear;
//下拉刷新
-(void)refresh;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

@end
