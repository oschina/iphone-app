
#import "ActivesView.h"
#import "MessageSystemView.h"

@implementation ActivesView
@synthesize tableActivies;
//@synthesize imageDownloadsInProgress;
@synthesize catalog;
//@synthesize tweetDownloadsInProgress;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
//    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
//    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
//    NSArray *allTweetImgs = [self.tweetDownloadsInProgress allValues];
//    [allTweetImgs makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (Activity *a in activies) {
        a.imgData = nil;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    allCount = 0;
    [super viewDidLoad];

//    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
//    self.tweetDownloadsInProgress = [NSMutableDictionary dictionary];
    
    activies = [[NSMutableArray alloc] initWithCapacity:20];
    //下拉刷新
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableActivies addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate]; 
    
    self.tableActivies.backgroundColor = [Tool getBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_TabClick object:nil];
    
    _iconCache = [[TQImageCache alloc] initWithCachePath:@"icons" andMaxMemoryCacheNumber:50];
}
- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"3"]) {
            [self.tableActivies setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}
- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableActivies];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableActivies];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (activies.count <= 0 && [Config Instance].isCookie) {
        [self refresh];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
//    if (self.imageDownloadsInProgress != nil) {
//        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
//        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
//    }
//    if(self.tweetDownloadsInProgress != nil)
//    {
//        NSArray *allTweetsimg = [self.tweetDownloadsInProgress allValues];
//        [allTweetsimg makeObjectsPerformSelector:@selector(cancelDownload)];
//    }
}
- (void)viewDidUnload
{
    [self setTableActivies:nil];
//    [imageDownloadsInProgress removeAllObjects];
//    [tweetDownloadsInProgress removeAllObjects];
    [activies removeAllObjects];
    activies = nil;
    _refreshHeaderView = nil;
//    imageDownloadsInProgress = nil;
//    tweetDownloadsInProgress = nil;
    _iconCache = nil;
    [super viewDidUnload];
}
- (void)reloadType:(int)ncatalog
{
    self.catalog = ncatalog;
    [self clear];
    [self.tableActivies reloadData];
    [self reload:NO];
}
- (void)clear
{
    allCount = 0;
    isLoadOver = NO;
    [activies removeAllObjects];
//    [imageDownloadsInProgress removeAllObjects];
//    [tweetDownloadsInProgress removeAllObjects];
}
- (void)reload:(BOOL)noRefresh
{
    if (isLoading || isLoadOver) {
        return;
    }
    if ([Config Instance].isCookie == NO) {
        return;
    }
    if (!noRefresh) {
        allCount = 0;
    }
    int pageIndex = allCount / 20;
    NSString *url = [NSString stringWithFormat:@"%@?catalog=%d&pageIndex=%d&pageSize=%d&uid=%d",api_active_list,self.catalog,pageIndex,20,[Config Instance].getUID];
    
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
                                        TBXMLElement *activelist = [TBXML childElementNamed:@"activies" parentElement:root];
                                        if (activelist == nil) {
                                            
                                            //检测是否未登录
                                            ApiError *error = [Tool getApiError2:operation.responseString];
                                            if (error == nil) {
                                                [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                            }
                                            if (error.errorCode == 0) {
                                                NSLog(error.errorMessage);
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"用户未登录,需要重新登录" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"登录", nil];
                                                [alert show];
                                            }
                                            
                                            return;
                                        }
                                        TBXMLElement *first = [TBXML childElementNamed:@"active" parentElement:activelist];
                                        if (!first) {
                                            [self.tableActivies reloadData];
                                            isLoadOver = YES;
                                            [self doneLoadingTableViewData];
                                            return;
                                        }
                                        NSMutableArray *newActivies = [[NSMutableArray alloc] initWithCapacity:20];
                                        TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
                                        TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                        TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
                                        TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:first];
                                        TBXMLElement *_catalog = [TBXML childElementNamed:@"catalog" parentElement:first];
                                        TBXMLElement *objectID = [TBXML childElementNamed:@"objectID" parentElement:first];
                                        TBXMLElement *message = [TBXML childElementNamed:@"message" parentElement:first];
                                        TBXMLElement *commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
                                        TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                        TBXMLElement *objectType = [TBXML childElementNamed:@"objecttype" parentElement:first];
                                        TBXMLElement *objectCatalog = [TBXML childElementNamed:@"objectcatalog" parentElement:first];
                                        TBXMLElement *objectTitle = [TBXML childElementNamed:@"objecttitle" parentElement:first];
                                        TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:first];
                                        ObjectReply *reply;
                                        TBXMLElement *objectReply = [TBXML childElementNamed:@"objectreply" parentElement:first];
                                        TBXMLElement *objectname;
                                        TBXMLElement *objectbody;
                                        if (objectReply) {
                                            objectname = [TBXML childElementNamed:@"objectname" parentElement:objectReply];
                                            objectbody = [TBXML childElementNamed:@"objectbody" parentElement:objectReply];
                                            reply = [[ObjectReply alloc] initWithParameter:[TBXML textForElement:objectname] andBody:[TBXML textForElement:objectbody]];
                                        }
                                        
                                        TBXMLElement *appClient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                        TBXMLElement *tweetImage = [TBXML childElementNamed:@"tweetimage" parentElement:first];
                                        
                                        Activity *a = [[Activity alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andCatalog:[[TBXML textForElement:_catalog] intValue] andObjectid:[[TBXML textForElement:objectID] intValue] andMessage:[TBXML textForElement:message] andPubDate:appClient ? [NSString stringWithFormat:@"%@ %@",[Tool intervalSinceNow:[TBXML textForElement:pubDate]],[Tool getAppClientString:[[TBXML textForElement:appClient] intValue]]]:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue] andObjectType:[[TBXML textForElement:objectType] intValue] andObjectCatalog:[[TBXML textForElement:objectCatalog] intValue] andObjectTitle:[TBXML textForElement:objectTitle] andForUserView:NO andReply:reply andImgTweet:[TBXML textForElement:tweetImage] andUrl:[TBXML textForElement:url]];
                                        if (![Tool isRepeatActive: activies andActive:a]) {
                                            [newActivies addObject:a];
                                        }
                                        int n = 1;
                                        while (first) {
                                            first = [TBXML nextSiblingNamed:@"active" searchFromElement:first];
                                            if (first) {
                                                n++;
                                                _id = [TBXML childElementNamed:@"id" parentElement:first];
                                                portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                                author = [TBXML childElementNamed:@"author" parentElement:first];
                                                authorid = [TBXML childElementNamed:@"authorid" parentElement:first];
                                                _catalog = [TBXML childElementNamed:@"catalog" parentElement:first];
                                                objectID = [TBXML childElementNamed:@"objectID" parentElement:first];
                                                message = [TBXML childElementNamed:@"message" parentElement:first];
                                                commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
                                                pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                                objectType = [TBXML childElementNamed:@"objecttype" parentElement:first];
                                                objectCatalog = [TBXML childElementNamed:@"objectcatalog" parentElement:first];
                                                objectTitle = [TBXML childElementNamed:@"objecttitle" parentElement:first];
                                                url = [TBXML childElementNamed:@"url" parentElement:first];
                                                reply = nil;
                                                objectReply = [TBXML childElementNamed:@"objectreply" parentElement:first];
                                                if (objectReply) {
                                                    objectname = [TBXML childElementNamed:@"objectname" parentElement:objectReply];
                                                    objectbody = [TBXML childElementNamed:@"objectbody" parentElement:objectReply];
                                                    reply = [[ObjectReply alloc] initWithParameter:[TBXML textForElement:objectname] andBody:[TBXML textForElement:objectbody]];
                                                }
                                                
                                                appClient = nil;
                                                appClient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                                tweetImage = [TBXML childElementNamed:@"tweetimage" parentElement:first];
                                                a = [[Activity alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andCatalog:[[TBXML textForElement:_catalog] intValue] andObjectid:[[TBXML textForElement:objectID] intValue] andMessage:[TBXML textForElement:message]    andPubDate:appClient ? [NSString stringWithFormat:@"%@ %@",[Tool intervalSinceNow:[TBXML textForElement:pubDate]],[Tool getAppClientString:[[TBXML textForElement:appClient] intValue]]]:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue] andObjectType:[[TBXML textForElement:objectType] intValue] andObjectCatalog:[[TBXML textForElement:objectCatalog] intValue] andObjectTitle:[TBXML textForElement:objectTitle] andForUserView:NO andReply:reply andImgTweet:[TBXML textForElement:tweetImage] andUrl:[TBXML textForElement:url]];
                                                if (![Tool isRepeatActive: activies andActive:a]) {
                                                    [newActivies addObject:a];
                                                }
                                            }
                                            else
                                            {
                                                break;
                                            }
                                        }
                                        [activies addObjectsFromArray:newActivies];
                                        [self.tableActivies reloadData];
                                        [self doneLoadingTableViewData];
                                        
                                    }
                                    @catch (NSException *exception) {
                                        [NdUncaughtExceptionHandler TakeException:exception];
                                    }
                                    @finally {
                                        [self doneLoadingTableViewData];
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                    NSLog(@"动态列表获取出错");
                                    
                                    //刷新错误
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
    [self.tableActivies reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        LoginView *loginView = [[LoginView alloc] init];
        loginView.isPopupByNotice = YES;
        [Config Instance].viewBeforeLogin = self;
        [self.parentViewController.navigationController pushViewController:loginView animated:YES];
    }
}
#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return activies.count == 0 ? 1 : activies.count;
    }
    else
        return activies.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    if (index < activies.count) {
        Activity *a = (Activity *)[activies objectAtIndex:index];
        if (a.imgTweet == nil || [a.imgTweet isEqualToString:@""]) {
            return a.height + 17;
        }
        else
        {
            return a.height + 17 + 75;
        }
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
    if ([activies count] > 0) {
        if ([indexPath row]<[activies count]) {
            RTActiveCell * cell;
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RTActiveCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[RTActiveCell class]]) {
                        cell = (RTActiveCell *)o;
                        break;
                    }
                }
                UITap *singleTap = [[UITap alloc] initWithTarget:self action:@selector(clickImg:)];
                [cell.imgPortrait addGestureRecognizer:singleTap];
            //初始化
            [cell initialize];
            Activity *a = [activies objectAtIndex:indexPath.row];
//            cell.imgPortrait.image = [UIImage imageNamed:@"avatar_loading.jpg"];
//            cell.imgPortrait.placeholderImage = [UIImage imageNamed:@"avatar_loading.jpg"];
//            cell.imgPortrait.imageURL = [NSURL URLWithString:a.img];
            if (a.img && ![a.img isEqualToString:@""]) {
                cell.imgPortrait.imageURL = [NSURL URLWithString:a.img];
            }
            else
            {
                cell.imgPortrait.image = [UIImage imageNamed:@"avatar_noimg.jpg"];
            }
//            cell.imgPortrait.placeholderImage = [UIImage imageNamed:@"tweetloading.jpg"];
            if (a.imgTweet && ![a.imgTweet isEqualToString:@""]) {
                cell.imgTweet.imageURL = [NSURL URLWithString:a.imgTweet];
                cell.imgTweet.hidden = NO;
                cell.imgTweet.frame = CGRectMake(49, a.height+15, 68, 68);
            }
            else
            {
                cell.imgTweet.hidden = YES;
            }
            
            if ([cell.imgPortrait.gestureRecognizers count] > 0) {
                UITap *tap = (UITap *)[cell.imgPortrait.gestureRecognizers objectAtIndex:0];
                if (tap) {
                    tap.tag = a.authorid;
                }
            }
            
            [cell.rtLabel setText:a.result];
            if (a.catalog >=1 && a.catalog <= 4) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
//            if (a.imgData) {
//                cell.imgPortrait.image = a.imgData;
//            }
//            //加入下载队列
//            else
//            {
//                if ([a.img isEqualToString:@""]) {
//                    a.imgData = [UIImage imageNamed:@"avatar_noimg.jpg"];
//                }
//                else
//                {
//                    NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:a.img]];
//                    if (imageData) {
//                        a.imgData = [UIImage imageWithData:imageData];
//                        cell.imgPortrait = a.imgData;
//                    } 
//                    else 
//                    {
////                        IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
////                        if (downloader == nil) {
////                            ImgRecord *record = [ImgRecord new];
////                            record.url = a.img;
////                            [self startIconDownload:record forIndexPath:indexPath];
////                        }
//                    }
//                }
//            }
//            //动弹图片
//            if ([a.imgTweet isEqualToString:@""] == NO) {
//                cell.imgTweet.hidden = NO;
//                cell.imgTweet.frame = CGRectMake(49, a.height+15, 68, 68);
//                if (a.imgTweetData == nil) {
////                    IconDownloader *td = [tweetDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
////                    if (td == nil) {
////                        ImgRecord *tr = [ImgRecord new];
////                        tr.url = a.imgTweet;
////                        [self startIconDownload2:tr forIndexPath:indexPath];
////                    }
//                }
//                else
//                {
//                    cell.imgTweet.image = a.imgTweetData;
//                }
//            }
//            else
//            {
//                cell.imgTweet.hidden = YES;
//            }
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
    if (row >= [activies count]) {

        if ([Config Instance].isCookie) {
            if (!isLoading) {
                [self performSelector:@selector(reload:)];
            }
        }
        else {
            LoginView *loginView = [[LoginView alloc] init];
            loginView.isPopupByNotice = YES;
            [Config Instance].viewBeforeLogin = self.parentViewController;
            [Config Instance].viewNameBeforeLogin = @"ProfileBase";
            [self.parentViewController.navigationController pushViewController:loginView animated:YES];
        }
    }
    else {
        switch (self.catalog) {
            case 1:
                self.parentViewController.navigationItem.title = @"所有";
                break;
            case 2:
                self.parentViewController.navigationItem.title = @"@我";
                break;
            case 3:
                self.parentViewController.navigationItem.title = @"评论";
                break;
            case 4:
                self.parentViewController.navigationItem.title = @"我自己";
                break;
        }

        Activity *a = [activies objectAtIndex:row];
        if (a == nil) {
            return;
        }
        if (a.url.length == 0) {
            if (a.catalog <= 0 || a.catalog >= 5) {
                return;
            }
            switch (a.catalog) {
                    case 1:
                    {
                       News *n = [[News alloc] init];
                      n._id = a.objectid;
                       [Tool pushNewsDetail:n andNavController:self.parentViewController.navigationController andIsNextPage:NO];
                   }
                       break;
                   case 2:
                  {
                       Post *p = [[Post alloc] init];
                     p._id = a.objectid;
                      [Tool pushPostDetail:p andNavController:self.parentViewController.navigationController];
                  }
                      break;
                  case 3:
                   {
                      Tweet *t = [[Tweet alloc] init];
                     t._id = a.objectid;
                     [Tool pushTweetDetail:t andNavController:self.parentViewController.navigationController];
                    }
                      break;
                 case 4:
                 {
                      //这是博客分类
                      News *n = [[News alloc] init];
                       n.newsType = 3;
                       n.attachment = [NSString stringWithFormat:@"%d", a.objectid];
                   [Tool pushNewsDetail:n andNavController:self.parentViewController.navigationController andIsNextPage:NO];
                     }
                       break;
            }
        }
        else
        {
            [Tool analysis:a.url andNavController:self.parentViewController.navigationController];
        }
                
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableActivies];
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
    if ([Config Instance].isCookie == NO) {
        [self.tableActivies reloadData];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3];
        return;
    }
    else
    {
        isLoadOver= NO;
        [self reload:NO];
    }
}

#pragma 异步下载图片处理
//下载图片
//- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
//    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:key];
//    if (iconDownloader == nil) {
//        iconDownloader = [[IconDownloader alloc] init];
//        iconDownloader.imgRecord = imgRecord;
//        iconDownloader.index = key;
//        iconDownloader.delegate = self;
//        [imageDownloadsInProgress setObject:iconDownloader forKey:key];
//        [iconDownloader startDownload];
//    }
//}
//- (void)startIconDownload2:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
//    IconDownloader *iconDownloader = [tweetDownloadsInProgress objectForKey:key];
//    if (iconDownloader == nil) {
//        iconDownloader = [[IconDownloader alloc] init];
//        iconDownloader.imgRecord = imgRecord;
//        iconDownloader.index = key;
//        iconDownloader.delegate = self;
//        [tweetDownloadsInProgress setObject:iconDownloader forKey:key];
//        [iconDownloader startDownload];
//    }
//}
//- (void)appImageDidLoad:(NSString *)index
//{
//    int _index = [index intValue];
//    if (_index >= [activies count]) {
//        return;
//    }
//    Activity *a = [activies objectAtIndex:[index intValue]];
//    if (a) {
//        IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
//        if (iconDownloader) {
//            a.imgData = iconDownloader.imgRecord.img;
//        }
//        
//        IconDownloader *iconTweet = [tweetDownloadsInProgress objectForKey:index];
//        if (iconTweet) {
//            a.imgTweetData = iconTweet.imgRecord.img;
//        }
//        // cache it
//        NSData * imageData = UIImagePNGRepresentation(a.imgData);
//        [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:a.img]];
//        
//        [tableActivies reloadData];
//    }
//}

@end
