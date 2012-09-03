//
//  UserActiveView.m
//  oschina
//
//  Created by wangjun on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserActiveView.h"

@implementation UserActiveView
@synthesize tableActivies;
@synthesize hisUID;
@synthesize hisName;
@synthesize imageDownloadsInProgress;
@synthesize tweetDownloadsInProgress;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    NSArray *allTweetImgs = [self.tweetDownloadsInProgress allValues];
    [allTweetImgs makeObjectsPerformSelector:@selector(cancelDownload)];
    for (Activity *a in activies) {
        a.imgData = nil;
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    allCount = 0;
    [super viewDidLoad];
    //头像
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tweetDownloadsInProgress = [NSMutableDictionary dictionary];
    
    activies = [[NSMutableArray alloc] initWithCapacity:20];
    
    //添加留言按钮
    UIToolbar *customToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 158, 44.01)];
    NSMutableArray *rightBarButtonArray = [[NSMutableArray alloc] initWithCapacity:2];

    UIBarButtonItem *interact = [[UIBarButtonItem alloc] initWithTitle:@"与Ta互动" style:UIBarButtonItemStyleBordered target:self action:@selector(clickInteract:)];
    [rightBarButtonArray addObject:interact];
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"Ta的资料/互动" style:UIBarButtonItemStyleBordered target:self action:@selector(clickInfo:)];
    info.enabled = NO;
    [rightBarButtonArray addObject:info];
    [customToolbar setItems:rightBarButtonArray animated:NO];

    self.parentViewController.navigationItem.rightBarButtonItem = info;
    
    self.tableActivies.backgroundColor = [Tool getBackgroundColor];

    [self reload:YES andNoRefresh:YES];
    //下拉刷新
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableActivies addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}
-(void)viewDidDisappear:(BOOL)animated
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
- (void)viewDidUnload
{
    [self setTableActivies:nil];
    
    _refreshHeaderView = nil;
    [activies removeAllObjects];
    activies = nil;
    hisName = nil;
    [self.imageDownloadsInProgress removeAllObjects];
    [self.tweetDownloadsInProgress removeAllObjects];
    self.imageDownloadsInProgress = nil;
    self.tweetDownloadsInProgress = nil;
    
    [super viewDidUnload];
}
-(void)clickInfo:(id)sender
{
    UserView2 *uv = [[UserView2 alloc] init];
    uv.hisUID = self.hisUID;
    [self.parentViewController.navigationController pushViewController:uv animated:YES];
}
-(void)clear
{
    allCount = 0;
    isLoadOver = NO;
    [activies removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    [tweetDownloadsInProgress removeAllObjects];
}
-(void)reload:(BOOL)isAllInfo andNoRefresh:(BOOL)noRefresh
{
    if (isLoading || isLoadOver) {
        return;
    }
    if (!noRefresh) {
        allCount = 0;
    }
    int pageIndex = allCount / 20;
    NSString *url;
    if (hisUID != 0) {
        url = [NSString stringWithFormat:@"%@?uid=%d&hisuid=%d&pageIndex=%d&pageSize=%d",api_user_information,[Config Instance].getUID,self.hisUID,pageIndex,20];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?uid=%d&hisname=%@&pageIndex=%d&pageSize=%d",api_user_information,[Config Instance].getUID,self.hisName,pageIndex,20];
    }
    
    [[AFOSCClient sharedClient] getPath:url parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    if (!noRefresh) {
                                        [self clear];
                                    }
                                    
                                    self.parentViewController.navigationItem.rightBarButtonItem.enabled = YES;
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
                                        TBXMLElement *user = [TBXML childElementNamed:@"user" parentElement:root];
                                        TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:user];
                                        TBXMLElement *uid = [TBXML childElementNamed:@"uid" parentElement:user];
                                        
                                        hisUID = [TBXML textForElement:uid].intValue;
                                        hisName = [TBXML textForElement:name];
                                        self.parentViewController.navigationItem.title = hisName;
                                        
                                        TBXMLElement *activelist = [TBXML childElementNamed:@"activies" parentElement:root];
                                        TBXMLElement *first = [TBXML childElementNamed:@"active" parentElement:activelist];
                                        if (!first) {
                                            isLoadOver = YES;
                                            [self.tableActivies reloadData];
                                            [self doneLoadingTableViewData];
                                            return;
                                        }
                                        NSMutableArray * newActivies = [[NSMutableArray alloc] initWithCapacity:20];
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
                                        TBXMLElement *appClient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                        
                                        ObjectReply *reply;
                                        TBXMLElement *objectReply = [TBXML childElementNamed:@"objectreply" parentElement:first];
                                        TBXMLElement *objectname;
                                        TBXMLElement *objectbody;
                                        if (objectReply) {
                                            objectname = [TBXML childElementNamed:@"objectname" parentElement:objectReply];
                                            objectbody = [TBXML childElementNamed:@"objectbody" parentElement:objectReply];
                                            reply = [[ObjectReply alloc] initWithParameter:[TBXML textForElement:objectname] andBody:[TBXML textForElement:objectbody]];
                                        }
                                        TBXMLElement *tweetImage = [TBXML childElementNamed:@"tweetimage" parentElement:first];
                                        Activity *a = [[Activity alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andCatalog:[[TBXML textForElement:_catalog] intValue] andObjectid:[[TBXML textForElement:objectID] intValue] andMessage:[TBXML textForElement:message] andPubDate:appClient ? [NSString stringWithFormat:@"%@ %@",[Tool intervalSinceNow:[TBXML textForElement:pubDate]],[Tool getAppClientString:[[TBXML textForElement:appClient] intValue]]]:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue] andObjectType:[[TBXML textForElement:objectType] intValue] andObjectCatalog:[[TBXML textForElement:objectCatalog] intValue] andObjectTitle:[TBXML textForElement:objectTitle] andForUserView:NO andReply:reply andImgTweet:[TBXML textForElement:tweetImage] andUrl:[TBXML textForElement:url]];
                                        if (![Tool isRepeatActive: activies andActive:a]) {
                                            [newActivies addObject:a];
                                        }
                                        while (first) {
                                            first = [TBXML nextSiblingNamed:@"active" searchFromElement:first];
                                            if (first) {
                                                
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
                                                appClient = nil;
                                                appClient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                                tweetImage = [TBXML childElementNamed:@"tweetimage" parentElement:first];
                                                reply = nil;
                                                objectReply = [TBXML childElementNamed:@"objectreply" parentElement:first];
                                                if (objectReply) {
                                                    objectname = [TBXML childElementNamed:@"objectname" parentElement:objectReply];
                                                    objectbody = [TBXML childElementNamed:@"objectbody" parentElement:objectReply];
                                                    reply = [[ObjectReply alloc] initWithParameter:[TBXML textForElement:objectname] andBody:[TBXML textForElement:objectbody]];
                                                }
                                                
                                                a = [[Activity alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andCatalog:[[TBXML textForElement:_catalog] intValue] andObjectid:[[TBXML textForElement:objectID] intValue] andMessage:[TBXML textForElement:message]   andPubDate:appClient ? [NSString stringWithFormat:@"%@ %@",[Tool intervalSinceNow:[TBXML textForElement:pubDate]],[Tool getAppClientString:[[TBXML textForElement:appClient] intValue]]]:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue] andObjectType:[[TBXML textForElement:objectType] intValue] andObjectCatalog:[[TBXML textForElement:objectCatalog] intValue] andObjectTitle:[TBXML textForElement:objectTitle] andForUserView:NO andReply:reply andImgTweet:[TBXML textForElement:tweetImage] andUrl:[TBXML textForElement:url]];
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
                                    
                                    NSLog(@"个人动态列表获取出错");
                                    
                                    [self doneLoadingTableViewData];
                                    isLoading = NO;
                                }];
    
    isLoading = YES;
    [self.tableActivies reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
            
            //初始化
            [cell initialize];
            
            cell.imgPortrait.image = [UIImage imageNamed:@"avatar_loading.jpg"];
            Activity *a = [activies objectAtIndex:indexPath.row];
            
            [cell.rtLabel setText:a.result];
            
            if (a.catalog >=1 && a.catalog <= 4) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            if (a.imgData) {
                cell.imgPortrait.image = a.imgData;
            }
            //加入下载队列
            else
            {
                if ([a.img isEqualToString:@""]) {
                    a.imgData = [UIImage imageNamed:@"avatar_noimg.jpg"];
                }
                else
                {
                    IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                    if (downloader == nil) {
                        ImgRecord *record = [ImgRecord new];
                        record.url = a.img;
                        [self startIconDownload:record forIndexPath:indexPath];
                    }
                }
            }
            //动弹图片
            if ([a.imgTweet isEqualToString:@""] == NO) {
                cell.imgTweet.hidden = NO;
                cell.imgTweet.frame = CGRectMake(49, a.height+15, 68, 68);
                if (a.imgTweetData == nil) {
                    IconDownloader *td = [tweetDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                    if (td == nil) {
                        ImgRecord *tr = [ImgRecord new];
                        tr.url = a.imgTweet;
                        [self startIconDownload2:tr forIndexPath:indexPath];
                    }
                }
                else
                {
                    cell.imgTweet.image = a.imgTweetData;
                }
            }
            else
            {
                cell.imgTweet.hidden = YES;
            }
            return cell;
        }
        else
        {
            if ([Config Instance].isNetworkRunning) {
                return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
            }
            else {
                return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
            }
        }
    }
    else
    {
        if ([Config Instance].isNetworkRunning) {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
        else {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= [activies count])
    {
        if (!isLoading) {
            [self reload:NO andNoRefresh:YES];
        }
    }
    else 
    {
        Activity *a = [activies objectAtIndex:row];
        if (a == nil) {
            return;
        }
        if (a.url.length > 0) {
            [Tool analysis:a.url andNavController:self.navigationController];
        }
        else
        {
            if (a.catalog <= 0 || a.catalog >= 5) {
                return;
            }
            
            switch (a.catalog) {
                case 1:
                {
                    News *n = [[News alloc] init];
                    n._id = a.objectid;
                    [Tool pushNewsDetail:n andNavController:self.navigationController andIsNextPage:NO];
                }
                    break;
                case 2:
                {
                    Post *p = [[Post alloc] init];
                    p._id = a.objectid;
                    [Tool pushPostDetail:p andNavController:self.navigationController]; 
                }
                    break;
                case 3:
                {
                    Tweet *t = [[Tweet alloc] init];
                    t._id = a.objectid;
                    [Tool pushTweetDetail:t andNavController:self.navigationController];
                }
                    break;
                case 4:
                {
                    //这是博客分类
                    News *n = [[News alloc] init];
                    n.newsType = 3;
                    n.attachment = [NSString stringWithFormat:@"%d", a.objectid];
                    [Tool pushNewsDetail:n andNavController:self.navigationController andIsNextPage:NO];
                }
                    break;
            }
        }
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return activies.count == 0 ? 1 : activies.count;
    }
    else
        return activies.count + 1;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
#pragma 下提刷新
-(void)reloadTableViewDataSource
{
    _reloading = YES;
}
-(void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableActivies];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
-(void)refresh
{
    if ([Config Instance].isCookie == NO) {
        [self.tableActivies reloadData];
        [self doneLoadingTableViewData];
        return;
    }
    else
    {
        isLoadOver = NO;
        [self reload:NO andNoRefresh:NO];
    }
}


#pragma 异步下载图片处理
//下载图片
-(void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
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
-(void)startIconDownload2:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
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
-(void)appImageDidLoad:(NSString *)index
{
    int _index = [index intValue];
    if (_index >= [activies count]) {
        return;
    }
    Activity *a = [activies objectAtIndex:[index intValue]];
    if (a) {
        IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
        if (iconDownloader) {
            a.imgData = iconDownloader.imgRecord.img;
        }
        
        IconDownloader *iconTweet = [tweetDownloadsInProgress objectForKey:index];
        if (iconTweet) {
            a.imgTweetData = iconTweet.imgRecord.img;
        }
        [self.tableActivies reloadData];
    }
}
@end
