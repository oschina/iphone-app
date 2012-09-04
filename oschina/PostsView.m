//
//  PostsView.m
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostsView.h"


@implementation PostsView

@synthesize tablePosts;
@synthesize imageDownloadsInProgress;
@synthesize catalog;
@synthesize tag;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    allCount = 0;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    posts = [[NSMutableArray alloc] initWithCapacity:20];

//    [self reload:YES];
    
    //下拉刷新
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tablePosts addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    //设置颜色
    self.tablePosts.backgroundColor = [Tool getBackgroundColor];
    //双击Tab更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_TabClick object:nil];
    
    //如果是Tag类型的
    if (self.tag != nil) {
        UIBarButtonItem *btnHome = [[UIBarButtonItem alloc] initWithTitle:@"问答首页" style:UIBarButtonItemStyleBordered target:self action:@selector(clickHome:)];
        //这种情况下 没有Tab
        self.navigationItem.rightBarButtonItem = btnHome;
    }
    _iconCache = [[TQImageCache alloc] initWithCachePath:@"icons" andMaxMemoryCacheNumber:50];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isInitialize == NO) {
        isInitialize = YES;
        [self reload:YES];
    }
}

//回到问答首页
- (void)clickHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma 双击Tab刷新
- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"1"]) {
            [self.tablePosts setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}
- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tablePosts];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tablePosts];
}

#pragma 生命周期
- (void)viewDidUnload
{
    [self setTablePosts:nil];
    _refreshHeaderView = nil;
    [posts removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    posts = nil;
    _iconCache = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空 
    for (Post *p in posts) {
        p.imgData = nil;
    }
}
- (void)reloadType:(int)ncatalog
{
    self.catalog = ncatalog;
    [self clear];
    [self.tablePosts reloadData];
    [self reload:NO];
}
- (void)clear
{
    allCount = 0;
    [posts removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    isLoadOver = NO;
}
- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}
- (void)reload:(BOOL)noRefresh
{
    if ([Config Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount / 20;
        NSString *url;
        NSMutableDictionary *dict = nil;
        if (self.tag == nil) {
            url = [NSString stringWithFormat:@"%@?catalog=%d&pageIndex=%d&pageSize=20", api_post_list, self.catalog, pageIndex];
        }
        else
        {
//            NSLog(@"搜索tag: %@",self.tag);
//            url = [NSString stringWithFormat:@"%@?tag=%@&pageIndex=%d&pageSize=20", api_post_list, self.tag, pageIndex];
            url = api_post_list;
            dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.tag,@"tag",@"20",@"pageSize",[NSString stringWithFormat:@"%d",pageIndex], @"pageIndex", nil];
        }
        [[AFOSCClient sharedClient] getPath:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            @try {
                [Tool getOSCNotice2:operation.responseString];
                isLoading = NO;
                if (!noRefresh) {
                    [self clear];
                }
                NSMutableArray * newPosts = [Tool readStrPostArray:operation.responseString andOld: posts];
                int count = [Tool isListOver2:operation.responseString];
                allCount += count;
                if (count < 20) {
                    isLoadOver = YES;
                }
                [posts addObjectsFromArray:newPosts];
                [self.tablePosts reloadData];
                [self doneLoadingTableViewData];
                
                //如果是第一页 则缓存下来
                if (posts.count <= 20) 
                {
                    [Tool saveCache:6 andID:self.catalog andString:operation.responseString];
                }
            }
            @catch (NSException *exception) {
                [NdUncaughtExceptionHandler TakeException:exception];
            }
            @finally {
                [self doneLoadingTableViewData];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"问答列表获取出错");
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
        [self.tablePosts reloadData];
    }
    else
    {
        NSString *value = [Tool getCache:6 andID:self.catalog];
        if (value) {
            NSMutableArray * newPosts = [Tool readStrPostArray:value andOld:posts];
            [self.tablePosts reloadData];
            isLoadOver = YES;
            [posts addObjectsFromArray:newPosts];
            [self.tablePosts reloadData];
            [self doneLoadingTableViewData];
        }
    }
}

#pragma TableView处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([Config Instance].isNetworkRunning) {
        if (isLoadOver) {
            return posts.count == 0 ? 1 : posts.count;
        }
        else
            return posts.count + 1;
    }
    else 
        return posts.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < posts.count) {
        return 69;
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
    if ([posts count] > 0) 
    {
        if (indexPath.row < [posts count]) 
        {
            PostCell *cell = (PostCell *)[tableView dequeueReusableCellWithIdentifier:PostCellIdentifier];
            if (!cell) 
            {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if([o isKindOfClass:[PostCell class]]){
                        cell = (PostCell *)o;
                        break;
                    }
                }
                UITap *singleTap = [[UITap alloc] initWithTarget:self action:@selector(clickImg:)];
                [cell.img addGestureRecognizer:singleTap];
            }
            cell.img.image = [UIImage imageNamed:@"avatar_loading.jpg"];
            Post *p = [posts objectAtIndex:indexPath.row];
            if ([cell.img.gestureRecognizers count] > 0) {
                UITap *tap = (UITap *)[cell.img.gestureRecognizers objectAtIndex:0];
                if (tap) {
                    tap.tag = p.authorid;
                }
            }
            cell.lbl_answer_chinese.text = self.catalog <= 1 ? @"回答" : @"回帖";
            cell.txt_Title.text = p.title;
            cell.txt_Title.font = [UIFont boldSystemFontOfSize:14.0];
            cell.lbl_AnswerCount.text = [NSString stringWithFormat:@"%d", p.answerCount];
            cell.lblAuthor.text = [NSString stringWithFormat:@"%@ 发布于%@", p.author, p.fromNowOn];
            if (p.imgData) {
                cell.img.image = p.imgData;
            }
            else
            {
                if ([p.img isEqualToString:@""]) {
                    p.imgData = [UIImage imageNamed:@"avatar_noimg.jpg"];
                }
                else
                {
                    NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:p.img]];
                    if (imageData) {
                        p.imgData = [UIImage imageWithData:imageData];
                        cell.img.image = p.imgData;
                    } 
                    else 
                    {
                        IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                        if (downloader == nil) {
                            ImgRecord *record = [ImgRecord new];
                            record.url = p.img;
                            [self startIconDownload:record forIndexPath:indexPath];
                        }
                    }
                }
            }
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部帖子" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部帖子" andLoadingString:(isLoading ? loadingTip : loadNext20Tip)  andIsLoading:isLoading];
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
    if (row >= [posts count]) {
        if (!isLoading) 
        {
            [self performSelector:@selector(reload:)];
        }
    }
    else 
    {
        Post *p = [posts objectAtIndex:row];
        if (p) 
        {
            PostBase * parent = (PostBase *)self.parentViewController;     
            if (self.tag != nil) {
                self.navigationController.title = self.tag;
                [Tool pushPostDetail:p andNavController:self.navigationController];
            }
            else
            {
                self.parentViewController.title = [parent getSegmentTitle];
                self.parentViewController.tabBarItem.title = @"问答";
                [Tool pushPostDetail:p andNavController:self.parentViewController.navigationController];
            }
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tablePosts];
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
    return NSDate.date;
}
- (void)refresh
{
    if ([Config Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }    
    else
    {
        NSString *value = [Tool getCache:6 andID:self.catalog];
        if (value) {
            NSMutableArray * newPosts = [Tool readStrPostArray:value andOld:posts];
            if (newPosts == nil) {
                [self.tablePosts reloadData];
                isLoadOver = YES;
            }
            else if(newPosts.count < 20){
                isLoadOver = YES;
            }
            [posts addObjectsFromArray:newPosts];
            [self.tablePosts reloadData];
            [self doneLoadingTableViewData];
        }
    }
}

#pragma 下载图片
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
        if (_index >= [posts count]) {
            return;
        }
        Post *p = [posts objectAtIndex:[index intValue]];
        if (p) {
            p.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(p.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:p.img]];
            [self.tablePosts reloadData];
        }
    }
}

@end
