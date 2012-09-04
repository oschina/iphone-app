//
//  MessageSystemView.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "Tool.h"
#import "ApiError.h"
#import "ReplyMsgView.h"
#import "MsgCell.h"
#import "MessageSystemPub.h"
#import "Notification_CommentCount.h"
#import "IconDownloader.h"
#import "EGORefreshTableHeaderView.h"
#import "CommentRefer.h"

#define FetchCount 10;

@class MessageSystemPub;
@interface MessageSystemView : UIViewController<UITableViewDataSource, UITableViewDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate,UIActionSheetDelegate>
{
    BOOL isLoading;
    BOOL isLoadOver;
    NSMutableArray * comments;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong, nonatomic) IBOutlet UITableView *tableComments;
@property (strong, nonatomic) MessageSystemPub * pubComments;
@property BOOL isDisplayRepostToMyZone;
@property BOOL noSon;
@property (retain,nonatomic) id attachment;
@property BOOL isDisableHit;
@property BOOL isDisableDelete;

/*
 新添加属性
 */
@property int commentType;

//类型 不需要重新改变类型
@property int catalog;
//父控件的id
@property int parentID;

@property int parentAuthorUID;

//四个公开属性
@property (copy,nonatomic) NSString * headTitle;
@property (copy,nonatomic) NSString * tabTitle;
@property (copy,nonatomic) NSString * pubTitle;
@property (copy,nonatomic) NSString * pubButtonTitle;
@property (copy,nonatomic) NSString * replyLabelTitle;
@property (copy,nonatomic) NSString * replyButtonTitle;
//仅仅用于消息中心点击某人后 需要重新给该用户留言的时候专用
@property int receiverid;
@property (copy,nonatomic) NSString * receiver;

//加载
- (void)reload:(BOOL)noRefresh;
- (void)addCommentByLocal:(Comment *)newComment;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

- (void)clear;
//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
