//
//  MessageSystemView.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageSystemView.h"

@implementation MessageSystemView
@synthesize tableComments;
@synthesize pubComments;
@synthesize imageDownloadsInProgress;
@synthesize isDisplayRepostToMyZone;
@synthesize noSon;
@synthesize catalog;
@synthesize parentID;
@synthesize headTitle;
@synthesize tabTitle;
@synthesize pubTitle;
@synthesize pubButtonTitle;
@synthesize replyLabelTitle;
@synthesize replyButtonTitle;
@synthesize attachment;
@synthesize isDisableHit;
@synthesize isDisableDelete;
@synthesize receiver;
@synthesize receiverid;
@synthesize commentType;
@synthesize parentAuthorUID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //订阅评论数获取后的通知事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAttachmentCommentCount:) name:Notification_DetailCommentCount object:nil];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (Comment *c in comments) {
        c.imgData = nil;
    }
}
#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.title = @"评论列表";
    self.parentViewController.navigationItem.title = catalog == 2 ? @"回帖列表" : @"评论列表";
    //将右边按钮设定为 发表评论
    UIBarButtonItem *btnPubComment = [[UIBarButtonItem alloc]
                                      initWithTitle:self.pubTitle ? self.pubTitle : @"发表评论" 
                                      style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.rightBarButtonItem = btnPubComment;
    self.parentViewController.navigationItem.rightBarButtonItem = btnPubComment;
    [btnPubComment setAction:@selector(clickPubComment:)];
    
    //判断是否该插入数据到末尾或者修改数据
    if ([Config Instance].tempComment) {
        [self addCommentByLocal:[Config Instance].tempComment];
    }
    //头部文字
    if (self.headTitle) {
        self.navigationItem.title = self.headTitle;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}
- (void)viewDidLoad
{
    allCount = 0;
    [super viewDidLoad];
    
    if (self.tabTitle) {
        self.tabBarItem.title = self.tabTitle;
    }
    
    //加载固定数据
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    comments = [[NSMutableArray alloc] initWithCapacity:10];
    [self reload:YES];
    
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableComments addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    self.tableComments.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
}
- (void)viewDidUnload
{
    [self setTableComments:nil];
    [comments removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    imageDownloadsInProgress = nil;
    comments = nil;
    _refreshHeaderView = nil;
    pubComments = nil;
    attachment = nil;
    [super viewDidUnload];
}
- (void)getAttachmentCommentCount:(NSNotification *)notification
{
    if (notification.object) 
    {
        Notification_CommentCount *nc = (Notification_CommentCount *)notification.object;
        if (nc) 
        {
            //如果引用匹配
            if (self.attachment == nc.attachment) 
            {
                self.tabBarItem.title = [NSString stringWithFormat:@"%@ (%d)", self.tabBarItem.title, nc.commentCount];
            }
        }
    }
}
//点击弹出发表评论页
- (void)clickPubComment:(id)sender
{
    //判断是否应该登入  当类型不是新闻的话则强制登录才能评论
    if (self.catalog != 1 && [Config Instance].isLogin == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:[Tool getCommentLoginNoticeByCatalog:self.catalog]];
        return;
    }
    if ([self.pubTitle isEqualToString:@"给Ta留言"])
    {
        PubMessage *pubMessage = [[PubMessage alloc] init];
        pubMessage.receiverid = receiverid;
        pubMessage.receiver = receiver;
        [self.navigationController pushViewController:pubMessage animated:YES];
    }
    else
    {
        self.pubComments = [[MessageSystemPub alloc] init];
        self.pubComments.catalog = self.catalog;
        self.pubComments.parent = self;
        self.pubComments.parentID = self.parentID;
        self.pubComments.isListIn = YES;
        if (self.pubButtonTitle) {
            self.pubComments.btnPubTitle = self.pubButtonTitle;
        }
        [self.navigationController pushViewController:self.pubComments animated:YES];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.parentViewController.navigationController andParent:self];
}
- (void)reload:(BOOL)noRefresh
{
    if (isLoading || isLoadOver) {
        return;
    }
    if (!noRefresh) {
        allCount = 0;
    }
    int pageIndex = allCount/20;
    NSString *url;
    switch (self.commentType) {
        case 5:
            url = [NSString stringWithFormat:@"%@?id=%d&pageIndex=%d&pageSize=%d", api_blogcomment_list, self.parentID, pageIndex, 20];
            break;
        default:
            url = [NSString stringWithFormat:@"%@?catalog=%d&id=%d&pageIndex=%d&pageSize=%d",api_comment_list,self.catalog,self.parentID,pageIndex, 20];
            break;
    } 
    
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
                                        int count = [Tool isListOver2:operation.responseString];
                                        allCount += count;
                                        if (count < 20) {
                                            isLoadOver = YES;
                                        }
                                        TBXMLElement *root = xml.rootXMLElement;
                                        TBXMLElement *commentlist = [TBXML childElementNamed:@"comments" parentElement:root];
                                        TBXMLElement *first = [TBXML childElementNamed:@"comment" parentElement:commentlist];
                                        if (!first) {
                                            [self.tableComments reloadData];
                                            isLoadOver = YES;
                                            [self doneLoadingTableViewData];
                                            return;
                                        }
                                        
                                        NSMutableArray *newComments = [[NSMutableArray alloc] initWithCapacity:20];
                                        TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
                                        TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                        TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
                                        TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:first];
                                        TBXMLElement *content = [TBXML childElementNamed:@"content" parentElement:first];
                                        TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                        TBXMLElement *appclient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                        NSMutableArray *replies = [Tool getReplies:first];
                                        NSMutableArray *refers = [Tool getRefers:first];
                                        
                                        Comment *c = [[Comment alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andContent:[TBXML textForElement:content]  andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andReplies:replies andRefers:refers andAppClient:appclient == nil ? 1 : [TBXML textForElement:appclient].intValue];
                                        //判断是否
                                        if (![Tool isRepeatComment: comments andComment:c]) {
                                            [newComments addObject:c];
                                        }
                                        
                                        while (first) {
                                            replies = refers = nil;
                                            first = [TBXML nextSiblingNamed:@"comment" searchFromElement:first];
                                            if (first) {
                                                _id = [TBXML childElementNamed:@"id" parentElement:first];
                                                portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                                author = [TBXML childElementNamed:@"author" parentElement:first];
                                                authorid = [TBXML childElementNamed:@"authorid" parentElement:first];
                                                content = [TBXML childElementNamed:@"content" parentElement:first];
                                                pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                                replies = [Tool getReplies:first];
                                                refers = [Tool getRefers:first];
                                                appclient = nil;
                                                appclient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                                c = [[Comment alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andContent:[TBXML textForElement:content]  andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andReplies:replies andRefers:refers andAppClient:appclient == nil ? 1 :[TBXML textForElement:appclient].intValue];
                                                if (![Tool isRepeatComment:  comments andComment:c]) {
                                                    [newComments addObject:c];
                                                }
                                            }
                                            else
                                            {
                                                break;
                                            }
                                        }
                                        [comments addObjectsFromArray:newComments];
                                        [self.tableComments reloadData];
                                        [self doneLoadingTableViewData];
                                    }
                                    @catch (NSException *exception) {
                                        [NdUncaughtExceptionHandler TakeException:exception];
                                    }
                                    @finally {
                                        [self doneLoadingTableViewData];
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                    NSLog(@"评论列表获取出错");
                                    
                                    [self doneLoadingTableViewData];
                                    isLoading = NO;
                                    if ([Config Instance].isNetworkRunning) {
                                        [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                    }
                                }];
    
    isLoading = YES;
    [self.tableComments reloadData];
}
- (void)clear
{
    allCount = 0;
    isLoadOver = NO;
    [comments removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    [tableComments reloadData];
}
- (void)addCommentByLocal:(Comment *)newComment
{
    //如果评论不属于此评论列表 则不考虑添加
    if (newComment.catalog != self.catalog) {
        return;
    }
    if (newComment.catalog != 4) {
        if (newComment.parentID != self.parentID) {
            return;
        }
    }
    
    //如果时消息中心的 需要重刷新 而不是添加
    if (self.catalog == 4) 
    {
        [self refresh];
        /*
         剩下一个问题就是发表留言后 没有上升到顶部
         */
        [Tool toTableViewBottom:self.tableComments isBottom:NO];
    }
    //如果是新闻 帖子 或者动弹的
    else 
    {
        //判断是否重复
        BOOL isRepeatComment = NO;
        int i=0;
        for (i=0; i<comments.count; i++) {
            Comment *c = (Comment *)[comments objectAtIndex:i];
            if (c._id == newComment._id) {
                isRepeatComment = YES;
                break;
            }
        }
        //如果没有重复  则插入到最前排 非问答的评论
        if (isRepeatComment == NO) 
        {
            [comments insertObject:newComment atIndex:0];
            [imageDownloadsInProgress removeAllObjects];
            [self.tableComments reloadData];
            [Tool toTableViewBottom:self.tableComments isBottom:NO];
        }
        //也可能是 问答的某帖子回复 需要被替代
        else 
        {
            [comments replaceObjectAtIndex:i withObject:newComment];
            [self.tableComments reloadData];
        }
    }
}


//显示菜单  
- (void)showMenu:(id)cell
{  
    //如果不是博客评论
    if (self.commentType != 5) {
        Comment * c = [comments objectAtIndex:[tableComments indexPathForCell:cell].row];
        if (c) {
            if (c.authorid != [Config Instance].getUID) {
                return;
            }
        }
    }
    //如果是博客评论
    else
    {
    }
    //如果没有登录
    [cell becomeFirstResponder];  
    UIMenuController * menu = [UIMenuController sharedMenuController];  
    CGRect rect = [cell frame];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - tableComments.contentOffset.y, rect.size.width, rect.size.height);
    [menu setTargetRect:newRect inView:[self view]];
    [menu setMenuVisible: YES animated: YES];    
}  
- (void)deleteRow:(UITableViewCell *)cell
{
    NSIndexPath *path = [tableComments indexPathForCell:cell];
    Comment *c = [comments objectAtIndex:[path row]];
    //验证登录
    
    //是否为我发表的
    if (self.commentType != 5 && isDisableDelete == NO && c.authorid != [Config Instance].getUID) {
        [Tool ToastNotification:@"错误 不能删除别人的评论" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在删除" andView:self.view andHUD:hud];
    
    if (commentType != 5) {
        [[AFOSCClient sharedClient] getPath:api_comment_delete
                                 parameters:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSString stringWithFormat:@"%d", self.parentID],@"id",
          [NSString stringWithFormat:@"%d", self.catalog],@"catalog",
          [NSString stringWithFormat:@"%d", c._id],@"replyid",
          [NSString stringWithFormat:@"%d", c.authorid],@"authorid",
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
    else {
        [[AFOSCClient sharedClient] getPath:api_blogcomment_delete
                                 parameters:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.parentID],@"blogid",
          [NSString stringWithFormat:@"%d", c._id],@"replyid",
          [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
          [NSString stringWithFormat:@"%d", c.authorid],@"authorid",
          [NSString stringWithFormat:@"%d", self.parentAuthorUID],@"owneruid",
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
} 
#pragma TableView处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return comments.count == 0 ? 1 : comments.count;
    }
    else
        return comments.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [comments count]) {
        //老式
        Comment *c = [comments objectAtIndex:row];
        return c.height + c.height_reference + 10;
    }
    else
    {
        return 62;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getColorForCell:indexPath.row];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int commentCount = [comments count];
    int row = [indexPath row];
    if (commentCount > 0) 
    {
        if (row < commentCount) 
        {
            Comment *m = [comments objectAtIndex:row];
            //可能需要更改 Cell
            MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:MsgUnitCellIdentifier];
            if (!cell )
            {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MsgCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[MsgCell class]]) {
                        cell = (MsgCell *)o;
                        break;
                    }
                }
                UITap *singleTap = [[UITap alloc] initWithTarget:self action:@selector(clickImg:)];
                [cell.img addGestureRecognizer:singleTap];
            }
            cell.img.image = [UIImage imageNamed:@"avatar_loading.jpg"];
            if (m) {
                if ([cell.img.gestureRecognizers count] > 0) {
                    UITap *tap = (UITap *)[cell.img.gestureRecognizers objectAtIndex:0];
                    if (tap) {
                        tap.tag = m.authorid;
                    }
                }
                //头像处理
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
                cell.lbl_Title.text = [NSString stringWithFormat:@"%@ 发表于%@ %@", m.author, m.pubDate, [Tool getAppClientString:m.appClient]];
                cell.txt_Content.font = [UIFont boldSystemFontOfSize:14.0];
                cell.txt_Content.text = m.content;
                
                UIColor *color = [Tool getColorForCell:row];
                
                if (self.catalog == 2 && cell.myView == nil) {
                    cell.myView = [[UIView alloc] init];
                    [cell addSubview:cell.myView];
                }
                
                
                //添加顶部 引用筐
                if (cell.referView) {
                    [cell.referView removeFromSuperview];
                 }
                
                if (m.refers && m.refers.count > 0) {
                    cell.referView = [Tool getReferView:m.refers];
                    [cell addSubview:cell.referView];
                    cell.txt_Content.frame = CGRectMake(40, 14+m.height_reference, 270, 50000);
                }
                else {
                    cell.txt_Content.frame = CGRectMake(40, 14, 270, 50000);
                }
                
                //添加底部筐
                if (m.replies && [m.replies count] > 0) 
                {
                    cell.myView.frame = CGRectMake(48, m.height + m.height_reference - 19 - [m.replies count]*35, 260, 14+m.replies.count*35);
                    cell.myView.hidden = NO;
                    //去除内部控件
                    for (UIView *v in cell.myView.subviews) {
                        [v removeFromSuperview];
                    }
                    
                    UILabel *lblCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 16)];
                    lblCount.font = [UIFont boldSystemFontOfSize:13.0];
                    lblCount.backgroundColor = color;
                    lblCount.text = [NSString stringWithFormat:@"--- 共有 %d 条评论 ---",[m.replies count]];
                    [cell.myView addSubview:lblCount];
                    UIColor *_color = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
                    for (int i=0; i<[m.replies count]; i++) 
                    {
                        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 14+i*35, 260, 38)];
                        lbl.numberOfLines = 2;
                        lbl.backgroundColor = color;
                        lbl.font = [UIFont boldSystemFontOfSize:13.0];
                        lbl.text = [m.replies objectAtIndex:i];
                        lbl.textColor = _color;
                        [cell.myView addSubview:lbl];
                    }
                }
                else
                {
                    cell.myView.hidden = YES;
                }
                //添加长按删除功能 
                [cell initGR];
                [cell setDelegate:self];
            }
            return cell;
        }
        else
        {
            if ([Config Instance].isNetworkRunning) {
                return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString: @"加载完毕" andLoadingString:isLoading ? loadingTip : loadNext20Tip andIsLoading:isLoading];
            }
            else {
                return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString: noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
            }
        }
    }
    else
    {
        if ([Config Instance].isNetworkRunning) {
            return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString: self.catalog != 4 ? @"没有评论或回复" : @"没有留言" andLoadingString:isLoading ? loadingTip : loadNext20Tip andIsLoading:isLoading];
        }
        else {
            return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString: noNetworkTip andLoadingString:noNetworkTip  andIsLoading:isLoading];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.catalog == 4 && self.isDisableHit) {
        return;
    }
    //如果没登录
    if (indexPath.row < comments.count && self.catalog != 1 && [Config Instance].isLogin == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:[Tool getCommentLoginNoticeByCatalog:self.catalog]];
        return;
    }
    
    int row = [indexPath row];
    if (row >= [comments count]) {
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else {
        //开始
        ReplyMsgView *reply = [[ReplyMsgView alloc] init];
        Comment *c = [comments objectAtIndex:[indexPath row]];
        reply.catalog = self.catalog;
        reply.parentCommentID = self.parentID;
        reply.replyID = c._id;
        reply.authorID = c.authorid; 
        reply.parentComment = c;
        reply.parent = self;
        if (replyLabelTitle) {
            reply.lblTitle = replyLabelTitle;
        }
        if (replyButtonTitle) {
            reply.btnTitle = replyButtonTitle;
        }
        //写入参数
        [self.navigationController pushViewController:reply animated:YES];
    }
}
- (void)clickImg:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        [Tool pushUserDetail:tap.tag andNavController:self.parentViewController.navigationController];
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableComments];
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
    isLoadOver = NO;
    [self reload:NO];
}
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
    if (iconDownloader) 
    {
        int _index = [index intValue];
        if (_index >= [comments count]) {
            return;
        }
        Comment *m = [comments objectAtIndex:[index intValue]];
        if (m) {
            m.imgData = iconDownloader.imgRecord.img;
            [self.tableComments reloadData];
        }
    }
}
@end
