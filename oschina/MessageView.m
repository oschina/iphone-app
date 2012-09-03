//
//  MessageView.m
//  oschina
//
//  Created by wangjun on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageView.h"
@implementation MessageView
@synthesize tableMsgs;
@synthesize imageDownloadsInProgress;
@synthesize isLoginJustNow;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"消息中心";
    //异步图片加载器初始化
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view from its nib.
    msgs = [[NSMutableArray alloc] initWithCapacity:20];
    
    [self reload:YES];

    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableMsgs addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    self.tableMsgs.backgroundColor = [Tool getBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_TabClick object:nil];
}
- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"3"]) {
            [self.tableMsgs setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}
- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableMsgs];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableMsgs];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (msgs.count <= 0) {
        [self reload:YES];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}
- (void)viewDidUnload
{
    [self setTableMsgs:nil];
    [msgs removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    msgs = nil;
    _refreshHeaderView = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空 
    for (Message *m in msgs) {
        m.imgData = nil;
    }
}
- (void)reload:(BOOL)noRefresh
{
    if (isLoading || isLoadOver) {
        return;
    }
    if ([Config Instance].isCookie == NO) {
        return;
    }
    int pageIndex = [msgs count] / 20;
    if (!noRefresh) {
        pageIndex = 0;
    }
    NSString *url = [NSString stringWithFormat:@"%@?uid=%d&pageIndex=%d&pageSize=20",api_message_list,[Config Instance].getUID, pageIndex];

    [[AFOSCClient sharedClient] getPath:url parameters:nil
                                
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                    if (!noRefresh) {
                                        [self clear];
                                    }
                                    [Tool getOSCNotice2:operation.responseString];
                                    isLoading = NO;
                                    NSString *response = operation.responseString;
                                    @try {
                                        
                                        TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
                                        TBXMLElement *root = xml.rootXMLElement;
                                        if (!root) {
                                            [self.tableMsgs reloadData];
                                            isLoadOver = YES;
                                            [self doneLoadingTableViewData];
                                            return;
                                        }
                                        TBXMLElement *msglist = [TBXML childElementNamed:@"messages" parentElement:root];
                                        if (!msglist) {
                                            [self.tableMsgs reloadData];
                                            isLoadOver = YES;
                                            [self doneLoadingTableViewData];
                                            return;
                                        }
                                        
                                        TBXMLElement *first = [TBXML childElementNamed:@"message" parentElement:msglist];
                                        if (first == nil) {
                                            [self.tableMsgs reloadData];
                                            isLoadOver = YES;
                                            [self doneLoadingTableViewData];
                                            return;
                                        }
                                        NSMutableArray *newMsgs = [[NSMutableArray alloc] initWithCapacity:20];
                                        TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
                                        TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                        TBXMLElement *friendid = [TBXML childElementNamed:@"friendid" parentElement:first];
                                        TBXMLElement *friendName = [TBXML childElementNamed:@"friendname" parentElement:first];
                                        TBXMLElement *sender = [TBXML childElementNamed:@"sender" parentElement:first];
                                        TBXMLElement *senderID = [TBXML childElementNamed:@"senderid" parentElement:first];
                                        TBXMLElement *content = [TBXML childElementNamed:@"content" parentElement:first];
                                        TBXMLElement *messageCount = [TBXML childElementNamed:@"messageCount" parentElement:first];
                                        TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                        Message *m = [[Message alloc] initWithParameter:[[TBXML textForElement:_id] intValue] andSender:[TBXML textForElement:sender] andSenderID:[[TBXML textForElement:senderID] intValue] andContent:[TBXML textForElement:content] andFromNowOn:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andImg:[TBXML textForElement:portrait] andFriendid:[[TBXML textForElement:friendid] intValue] andFriendName:[TBXML textForElement:friendName] andCount:[[TBXML textForElement:messageCount] intValue]];
                                        int count = 0;
                                        if (![Tool isRepeatMessage: msgs andMessage:m]) {
                                            [newMsgs addObject:m];
                                            count = 1;
                                        }
                                        
                                        while (first != nil) {
                                            first = [TBXML nextSiblingNamed:@"message" searchFromElement:first];
                                            if (first) 
                                            {
                                                _id = [TBXML childElementNamed:@"id" parentElement:first];
                                                portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                                friendid = [TBXML childElementNamed:@"friendid" parentElement:first];
                                                friendName = [TBXML childElementNamed:@"friendname" parentElement:first];
                                                sender = [TBXML childElementNamed:@"sender" parentElement:first];
                                                senderID = [TBXML childElementNamed:@"senderid" parentElement:first];
                                                content = [TBXML childElementNamed:@"content" parentElement:first];
                                                messageCount = [TBXML childElementNamed:@"messageCount" parentElement:first];
                                                pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                                m = [[Message alloc] initWithParameter:[[TBXML textForElement:_id] intValue] andSender:[TBXML textForElement:sender] andSenderID:[[TBXML textForElement:senderID] intValue] andContent:[TBXML textForElement:content] andFromNowOn:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andImg:[TBXML textForElement:portrait] andFriendid:[[TBXML textForElement:friendid] intValue] andFriendName:[TBXML textForElement:friendName] andCount:[[TBXML textForElement:messageCount] intValue]];
                                                if (![Tool isRepeatMessage: msgs andMessage:m]) {
                                                    [newMsgs addObject:m];
                                                    count++;
                                                }
                                            }
                                            else
                                            {
                                                break;
                                            }
                                        }
                                        if (count < 20) {
                                            isLoadOver = YES;
                                        }
                                        [msgs addObjectsFromArray:newMsgs];
                                        [self.tableMsgs reloadData];
                                        [self doneLoadingTableViewData];
                                        
                                    }
                                    @catch (NSException *exception) {
                                        [NdUncaughtExceptionHandler TakeException:exception];
                                    }
                                    @finally {
                                        [self doneLoadingTableViewData];
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                    NSLog(@"留言列表获取出错");
                                    
                                    [self doneLoadingTableViewData];
                                    
                                    isLoading = NO;
                                    if ([Config Instance].isNetworkRunning == NO) {
                                        return;
                                    }
                                    if ([Config Instance].isNetworkRunning) {
                                        [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                    }

                                }];
    
    isLoading = YES;
    [self.tableMsgs reloadData];
}
- (void)clear
{
    [msgs removeAllObjects];
    isLoadOver = NO;
    [imageDownloadsInProgress removeAllObjects];
}
//显示菜单  
- (void)showMenu:(id)cell
{  
    [cell becomeFirstResponder];  
    UIMenuController * menu = [UIMenuController sharedMenuController];  
    CGRect rect = [cell frame];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - tableMsgs.contentOffset.y, rect.size.width, rect.size.height);
    [menu setTargetRect:newRect inView:[self view]];
    [menu setMenuVisible: YES animated: YES];    
}  
- (void)deleteRow:(UITableViewCell *)cell
{
    NSIndexPath *path = [tableMsgs indexPathForCell:cell];
    Message *m = [msgs objectAtIndex:[path row]];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在删除" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient] getPath:api_message_delete parameters:
                                [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", m.friendid],@"friendid",
                                 [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                 nil]
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    [hud hide:YES];
                                    [Tool getOSCNotice2:operation.responseString];

                                    ApiError *error = [Tool getApiError2:operation.responseString];
                                    if (error == nil) {
                                        [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                        return ;
                                    }
                                    switch (error.errorCode) {
                                        case 1:
                                        {
                                            [self refresh];
                                        }
                                            break;
                                        case 0:
                                        case -2:
                                        case -1:
                                        {
                                            [Tool ToastNotification:[NSString stringWithFormat:@"错误 %@",error.errorMessage] andView:self.view andLoading:NO andIsBottom:NO];
                                        }
                                            break;
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [hud hide:YES];
                                    [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                                }];
} 
#pragma TableView处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return msgs.count == 0 ? 1 :msgs.count;
    }
    else
        return msgs.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    if (index < msgs.count) {
        Message *m = (Message *)[msgs objectAtIndex:index];
        return m.height + 17;
    }
    else
        return 62;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([msgs count] > 0) {
        
        if ([indexPath row] < [msgs count]) 
        {
            MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:MsgCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[MessageCell class]]) {
                        cell = (MessageCell *)o;
                        break;
                    }
                }
                UITap *singleTap = [[UITap alloc] initWithTarget:self action:@selector(clickImg:)];
                [cell.img addGestureRecognizer:singleTap];
            }
            cell.img.image = [UIImage imageNamed:@"avatar_loading.jpg"];
            Message * m = [msgs objectAtIndex:indexPath.row];
            if ([cell.img.gestureRecognizers count] > 0) {
                UITap *tap = (UITap *)[cell.img.gestureRecognizers objectAtIndex:0];
                if (tap) 
                {
                    tap.tag = m.friendid;
                }
            }

            //删除元素用  
            [cell initGR];
            [cell setDelegate:self];
            cell.lblFromNowOn.text = m.fromNowOn;
            cell.lblFromNowOn.frame = CGRectMake(48, m.height - 5, 200, 21);
            cell.lblCount.text = [NSString stringWithFormat:@"%d",m.count];
            cell.lblName.text = [NSString stringWithFormat:@"%@ %@",m.senderID == [Config Instance].getUID ? @"发给":@"来自", m.friendName];
            cell.txtContent.font = [UIFont boldSystemFontOfSize:14.0];
            NSString *temp = m.content;
            cell.txtContent.text = temp;
            if (m.imgData)
            {
                cell.img.image = m.imgData;
            }
            //进入下载队列
            else
            {
                if ([m.img isEqualToString:@""]) {
                    m.imgData = [UIImage imageNamed:@"avatar_noimg.jpg"];
                }
                else
                {
                    IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                    if (downloader == nil) {
                        ImgRecord *record = [ImgRecord new];
                        record.url = m.img;
                        [self startIconDownload:record forIndexPath:indexPath];
                    }
                }
            }
            return cell;
        }
        else
        {
            if ([Config Instance].isNetworkRunning) {
                return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:[Config Instance].isCookie ? (isLoading ? loadingTip : loadNext20Tip) : @"您还没有登录,无法查看" andIsLoading:isLoading];
            }
            else {
                return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
            }
        }
    }
    else
    {
        if ([Config Instance].isNetworkRunning) {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:[Config Instance].isCookie ? (isLoading ? loadingTip : loadNext20Tip) : @"您还没有登录,无法查看" andIsLoading:isLoading];
        }
        else {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
        }
    }
}
- (void)clickImg:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        [Tool pushUserDetail:tap.tag andNavController:self.parentViewController.navigationController];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= [msgs count]) 
    {
        if ([Config Instance].isCookie == NO) {
            LoginView *loginView = [[LoginView alloc] init];
            loginView.isPopupByNotice = YES;
            [Config Instance].viewBeforeLogin = self.parentViewController;
            [Config Instance].viewNameBeforeLogin = @"ProfileBase";
            [self.parentViewController.navigationController pushViewController:loginView animated:YES];
        }
        else
        {
            if (!isLoading) {
                [self performSelector:@selector(reload:)];
            }
        }
    }
    else {
        
        Message * m = [msgs objectAtIndex:row];
//        BubbleView * b = [BubbleView new];
//        b.hidesBottomBarWhenPushed = YES;
//        b.friendID = m.friendid;
//        b.friendName = m.friendName;
        
        MyBubbleView * b = [MyBubbleView new];
        b.hidesBottomBarWhenPushed = YES;
        b.friendID = m.friendid;
        b.friendName = m.friendName;
        
        [self.navigationController pushViewController:b animated:YES];

    }
    
}
#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}
- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableMsgs];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    if ([Config Instance].isCookie == NO) {
        return;
    }
    [self reloadTableViewDataSource];
    [self refresh];
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
- (void)refresh
{
    if ([Config Instance].isCookie == NO) {
        [self.tableMsgs reloadData];
        [self doneLoadingTableViewData];
        return;
    }   
    else
    {
        isLoadOver = NO;
        [self reload:NO];
    }
}

#pragma 异步下载图片处理
//下载图片
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:key];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgRecord = imgRecord;
        iconDownloader.index = key;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:key];
        [iconDownloader startDownload];
    }
}
- (void)appImageDidLoad:(NSString *)index
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
    if (iconDownloader) {
        int _index = [index intValue];
        if (_index >= [msgs count]) {
            return;
        }
        Message *m = [msgs objectAtIndex:[index intValue]];
        if (m) {
            m.imgData = iconDownloader.imgRecord.img;
            [self.tableMsgs reloadData];
        }
    }
}
@end
