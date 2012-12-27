//
//  TwitterView.m
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TwitterView.h"

@implementation TwitterView
@synthesize tableTweets;
@synthesize imageDownloadsInProgress;
@synthesize tweetDownloadsInProgress;
@synthesize _uid;

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化
    allCount = 0;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tweetDownloadsInProgress = [NSMutableDictionary dictionary];
    tweets = [[NSMutableArray alloc] initWithCapacity:20];

    //上提刷新初始化
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
    view.delegate = self;
    [self.tableTweets addSubview:view];
    _refreshHeaderView = view;
    [_refreshHeaderView refreshLastUpdatedDate];
    
    //设定背景颜色
    self.tableTweets.backgroundColor = [Tool getBackgroundColor];
    
    //设定Tab双击刷新事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_TabClick object:nil];
    //开始加载
//    [self reload:YES];
    _iconCache = [[TQImageCache alloc] initWithCachePath:@"icons" andMaxMemoryCacheNumber:50];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (isInitialize == NO) {
        [self reload:YES];
        isInitialize = YES;
    }
    
    if ([Config Instance].isNeedReloadTweets && self._uid >= 0) {
        [self clear];
        [self reload:YES];
        [Config Instance].isNeedReloadTweets = NO;
    }
}
- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"2"]) {
            [self.tableTweets setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}
- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableTweets];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableTweets];
}
- (void)didReceiveMemoryWarning
{
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    NSArray *allTweetsimg = [self.tweetDownloadsInProgress allValues];
    [allTweetsimg makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload
{
    [self setTableTweets:nil];
    [tweets removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    [tweetDownloadsInProgress removeAllObjects];
    tweets = nil;
    _refreshHeaderView = nil;
    imageDownloadsInProgress = tweetDownloadsInProgress = nil;
    _iconCache = nil;
    [super viewDidUnload];
}
- (void)reloadUID:(int)newUID
{
    self._uid = newUID;
    [self clear];
    [self.tableTweets reloadData];
    [self reload:NO];
}
- (void)clear
{
    allCount = 0;
    [tweets removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    [tweetDownloadsInProgress removeAllObjects];
    isLoadOver = NO;
}
- (void)reload:(BOOL)noRefresh
{
    if (isLoading || isLoadOver) 
    {
        return;
    }
    if (!noRefresh) {
        allCount = 0;
    }
    int pageIndex = allCount/20;
    NSString *url = [NSString stringWithFormat:@"%@?uid=%d&pageIndex=%d&pageSize=%d",api_tweet_list, self._uid,pageIndex, 20];
    [[AFOSCClient sharedClient] getPath:url parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //如果刷新则清空
        if (!noRefresh) {
            [self clear];
        }
        
        [Tool getOSCNotice2:operation.responseString];
        isLoading = NO;
        NSString *response = operation.responseString;
        @try {
            
            TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
            int count = [Tool isListOver2:response];
            allCount += count;
            if (count < 20) {
                isLoadOver = YES;
            }
            TBXMLElement *root = xml.rootXMLElement;
            //显示
            TBXMLElement *tweetlist = [TBXML childElementNamed:@"tweets" parentElement:root];
            int allCountTweets = [TBXML textForElement:[TBXML childElementNamed:@"tweetCount" parentElement:root]].intValue;
            if (allCountTweets <= allCount) {
                isLoadOver = YES;
            }
            if (!tweetlist) {
                isLoadOver = YES;
                [self.tableTweets reloadData];
                [self doneLoadingTableViewData];
                return;
            }
            TBXMLElement *first = [TBXML childElementNamed:@"tweet" parentElement:tweetlist];
            if (first == nil) {
                [self.tableTweets reloadData];
                isLoadOver = YES;
                [self doneLoadingTableViewData];
                return;
            }
            NSMutableArray *newTweets = [[NSMutableArray alloc] initWithCapacity:20];
            TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
            TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
            TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
            TBXMLElement *authorID = [TBXML childElementNamed:@"authorid" parentElement:first];
            TBXMLElement *words = [TBXML childElementNamed:@"body" parentElement:first];
            TBXMLElement *commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
            TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
            TBXMLElement *imgSmall = [TBXML childElementNamed:@"imgSmall" parentElement:first];
            TBXMLElement *imgBig = [TBXML childElementNamed:@"imgBig" parentElement:first];
            TBXMLElement *appClient = [TBXML childElementNamed:@"appclient" parentElement:first];
            Tweet *t = [[Tweet alloc] initWidthParameters:[[TBXML textForElement:_id] intValue] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorID] intValue] andTweet:[TBXML textForElement:words] andFromNowOn:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andImg:[TBXML textForElement:portrait] andCommentCount:[[TBXML textForElement:commentCount] intValue] andImgTweet:[TBXML textForElement:imgSmall] andImgBig:[TBXML textForElement:imgBig] andAppClient:[[TBXML textForElement:appClient] intValue]];
            if (![Tool isRepeatTweet:tweets andTweet:t]) {
                [newTweets addObject:t];
            }
            
            while (first != nil) 
            {
                first = [TBXML nextSiblingNamed:@"tweet" searchFromElement:first];
                if (first) 
                {
                    _id = [TBXML childElementNamed:@"id" parentElement:first];
                    portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                    author = [TBXML childElementNamed:@"author" parentElement:first];
                    authorID = [TBXML childElementNamed:@"authorid" parentElement:first];
                    words = [TBXML childElementNamed:@"body" parentElement:first];
                    commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
                    pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                    imgSmall = [TBXML childElementNamed:@"imgSmall" parentElement:first];
                    imgBig = [TBXML childElementNamed:@"imgBig" parentElement:first];
                    appClient = [TBXML childElementNamed:@"appclient" parentElement:first];
                    t = [[Tweet alloc] initWidthParameters:[[TBXML textForElement:_id] intValue] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorID] intValue] andTweet:[TBXML textForElement:words] andFromNowOn:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andImg:[TBXML textForElement:portrait] andCommentCount:[[TBXML textForElement:commentCount] intValue] andImgTweet:[TBXML textForElement:imgSmall] andImgBig:[TBXML textForElement:imgBig]
                                              andAppClient:[[TBXML textForElement:appClient] intValue]];
                    if (![Tool isRepeatTweet:tweets andTweet:t]) {
                        [newTweets addObject:t];
                    }
                }
                else
                {
                    break;
                }
            }
            [tweets addObjectsFromArray:newTweets];
            [self.tableTweets reloadData];
            [self doneLoadingTableViewData];
            
        }
        @catch (NSException *exception) {
            [NdUncaughtExceptionHandler TakeException:exception];
        }
        @finally {
            [self doneLoadingTableViewData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"动弹列表下载失败");
        //下拉刷新恢复
        [self doneLoadingTableViewData];
        if ([Config Instance].isNetworkRunning == NO) {
            return;
        }
        if ([Config Instance].isNetworkRunning) {
            [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
        }
    }];
    
    isLoading = YES;
    [self.tableTweets reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
    if(self.tweetDownloadsInProgress != nil)
    {
        NSArray *allTweetsimg = [self.tweetDownloadsInProgress allValues];
        [allTweetsimg makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return tweets.count == 0 ?  1: tweets.count;
    }
    else 
        return tweets.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [tweets count]) {
        Tweet *t = [tweets objectAtIndex:[indexPath row]];
        return [t.imgTweet isEqualToString:@""] ? t.height + 36 : t.height + 124;
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
    if ([tweets count] > 0) 
    {
        if (indexPath.row < [tweets count]) 
        {
            TweetCell *cell = nil;
            cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:TweetCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[TweetCell class]]) {
                        cell = (TweetCell *)o;
                        break;
                    }
                }
                UITap *singleTap = [[UITap alloc] initWithTarget:self action:@selector(clickImg:)];
                [cell.img addGestureRecognizer:singleTap];
                UITap *tweetTap = [[UITap alloc] initWithTarget:self action:@selector(clickTweet:)];
                [cell.imgTweet addGestureRecognizer:tweetTap];
            }
            cell.img.image = [UIImage imageNamed:@"avatar_loading.jpg"];
            Tweet *t = [tweets objectAtIndex:[indexPath row]];
            if (t) 
            {
                if ([cell.img.gestureRecognizers count] > 0) {
                    UITap *tap = (UITap *)[cell.img.gestureRecognizers objectAtIndex:0];
                    if (tap) {
                        tap.tag = t.authorID;
                    }
                }
                //如果微博带图片
                if ([t.imgTweet isEqualToString:@""] == NO) 
                {
                    cell.imgTweet.hidden = NO;
                    cell.lbl_Time.frame = CGRectMake(48, t.height+104, 170, 16);
                    cell.imgTweet.frame = CGRectMake(48, t.height+27, 68, 68);
                    if ([cell.imgTweet.gestureRecognizers count] > 0) {
                        UITap *tap = (UITap *)[cell.imgTweet.gestureRecognizers objectAtIndex:0];
                        if (tap) {
                            tap.tagString = t.imgBig;
                        }
                    }
                    
                    if (t.imgTweetData == nil) 
                    {
                        IconDownloader *d = [tweetDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                        if (d == nil) {
                            ImgRecord *r = [ImgRecord new];
                            r.url = t.imgTweet;
                            [self startIconDownload2:r forIndexPath:indexPath];
                        }
                    }
                    else
                    {
                        cell.imgTweet.image = t.imgTweetData;
                    }
                }
                //如果不带图片
                else
                {
                    cell.lbl_Time.frame = CGRectMake(48, t.height+17, 170, 16);
                    cell.imgTweet.hidden = YES;
                }
                //头像
                if (t.imgData == nil) {
                    if ([t.img isEqualToString:@""]) {
                        t.imgData = [UIImage imageNamed:@"avatar_noimg.jpg"];
                    }
                    else
                    {
                        NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:t.img]];
                        if (imageData) {
                            //                        NSLog(@"load image from cache");
                            t.imgData = [UIImage imageWithData:imageData];
                            cell.img.image = t.imgData;
                        } else {
                            IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                            if (downloader == nil) {
                                ImgRecord *record = [ImgRecord new];
                                record.url = t.img;
                                [self startIconDownload:record forIndexPath:indexPath];
                            }
                        }

                    }
                }
                else
                {
                    cell.img.image = t.imgData;
                }
                cell.lbl_Author.text = [NSString stringWithFormat:@"%@:", t.author];
                cell.txt_Message.font = [UIFont boldSystemFontOfSize:14.0];
                cell.txt_Message.text = t.tweet;
                cell.lbl_Time.text = [NSString stringWithFormat:@"%@ %@", [Tool intervalSinceNow:t.fromNowOn], [Tool getAppClientString:t.appClient]];
                cell.lblCommentCount.text = [NSString stringWithFormat:@"%d", t.commentCount];

                //添加长按删除功能 
                [cell initGR];
                [cell setDelegate:self];
            }
            return cell;
        }
        //如果不是数据条目
        else
        {
            if ([Config Instance].isNetworkRunning) {
                return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
            }
            else {
                return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
            }
        }
    }
    //提示要等待加载新数据
    else
    {
        if ([Config Instance].isNetworkRunning) {
            return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
        else {
            return [DataSingleton.Instance getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
        }
    }
}
//点击头像进入用户专页
- (void)clickImg:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        [Tool pushUserDetail:tap.tag andNavController:self.parentViewController.navigationController];
    }
}
//点击动弹图片事件
- (void)clickTweet:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        [Tool pushTweetImgDetail:tap.tagString andParent:self];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= [tweets count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else {
        Tweet *t = [tweets objectAtIndex:row];
        if (t) {
            
            TweetBase2 * parent = (TweetBase2 *)self.parentViewController;
            self.parentViewController.title = [parent getSegmentTitle];
            self.parentViewController.tabBarItem.title = @"动弹";
            
            [Tool pushTweetDetail:t andNavController:self.parentViewController.navigationController];
        }
    }
}

#pragma mark - 删除某项动弹  
- (void)showMenu:(id)cell
{  
    Tweet * t = [tweets objectAtIndex:[tableTweets indexPathForCell:cell].row];
    if (t) {
        if (t.authorID != [Config Instance].getUID) {
            return;
        }
    }
    //如果没有登录
    [cell becomeFirstResponder];  
    UIMenuController * menu = [UIMenuController sharedMenuController];  
    CGRect rect = [cell frame];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - tableTweets.contentOffset.y, rect.size.width, rect.size.height);
    [menu setTargetRect:newRect inView:[self view]];
    [menu setMenuVisible: YES animated: YES];    
}  
- (void)deleteRow:(UITableViewCell *)cell
{
    NSIndexPath *path = [tableTweets indexPathForCell:cell];
    Tweet *c = [tweets objectAtIndex:[path row]];
    //是否为我发表的
    if (c.authorID != [Config Instance].getUID) 
    {
        [Tool ToastNotification:@"错误 不能删除别人的动弹" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    
    [[AFOSCClient sharedClient] getPath:api_tweet_delete parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", c._id],@"tweetid",[NSString stringWithFormat:@"%d", c.authorID],@"uid", nil]
                                
        success:^(AFHTTPRequestOperation *operation, id responseObject) 
        {
            [Tool getOSCNotice2:operation.responseString];
            ApiError *error = [Tool getApiError2:operation.responseString];
            if (error == nil) {
                [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                return;
            }
            switch (error.errorCode) 
            {
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
        
        } 
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if ([Config Instance].isNetworkRunning == NO) {
                return;
            }
            if ([Config Instance].isNetworkRunning) {
                [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
            }
        }];
}

#pragma mark - 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}
- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableTweets];
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
- (void)startIconDownload2:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
    IconDownloader *iconDownloader = [tweetDownloadsInProgress objectForKey:key];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgRecord = imgRecord;
        iconDownloader.index = key;
        iconDownloader.delegate = self;
        [tweetDownloadsInProgress setObject:iconDownloader forKey:key];
        [iconDownloader startDownload];
    }
}
- (void)appImageDidLoad:(NSString *)index
{
    int _index = [index intValue];
    if (_index >= [tweets count]) {
        return;
    }
    Tweet *t = [tweets objectAtIndex:[index intValue]];
    if (t) {
        IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
        if (iconDownloader) {
            t.imgData = iconDownloader.imgRecord.img;
        }
        
        IconDownloader *iconTweet = [tweetDownloadsInProgress objectForKey:index];
        if (iconTweet) {
            t.imgTweetData = iconTweet.imgRecord.img;
        }
        // cache it
        NSData * imageData = UIImagePNGRepresentation(t.imgData);
        [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:t.img]];
        [tableTweets reloadData];
    }
}

@end
