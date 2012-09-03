//
//  NewsView.m
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsView.h"

@implementation NewsView
@synthesize tableNews;
@synthesize catalog;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableNews addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    news = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
    self.tableNews.backgroundColor = [Tool getBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_TabClick object:nil];
}
- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"0"]) {
            [self.tableNews setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}
- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableNews];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableNews];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload
{
    [self setTableNews:nil];
    _refreshHeaderView = nil;
    [news removeAllObjects];
    news = nil;
    [super viewDidUnload];
}

//重新载入类型
- (void)reloadType:(int)ncatalog
{
    self.catalog = ncatalog;
    [self clear];
    [self.tableNews reloadData];
    [self reload:NO];
}
- (void)clear
{
    allCount = 0;
    [news removeAllObjects];
    isLoadOver = NO;
}
- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([Config Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20;
        NSString *url;
        switch (self.catalog) {
            case 1:
                url = [NSString stringWithFormat:@"%@?catalog=%d&pageIndex=%d&pageSize=%d", api_news_list, 1, pageIndex, 20];
                break;
            case 2:
                url = [NSString stringWithFormat:@"%@?type=latest&pageIndex=%d&pageSize=%d", api_blog_list, pageIndex, 20];
                break;
            case 3:
                url = [NSString stringWithFormat:@"%@?type=recommend&pageIndex=%d&pageSize=%d", api_blog_list, pageIndex, 20];
                break;
        }

        [[AFOSCClient sharedClient]getPath:url parameters:Nil 
            
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
            [Tool getOSCNotice2:operation.responseString];
            isLoading = NO;
            if (!noRefresh) {
                [self clear];
            }

            @try {
                NSMutableArray *newNews = self.catalog <= 1 ?
                
                [Tool readStrNewsArray:operation.responseString andOld: news]:
                [Tool readStrUserBlogsArray:operation.responseString andOld: news];
                int count = [Tool isListOver2:operation.responseString];
                allCount += count;
                if (count < 20)
                {
                    isLoadOver = YES;
                }
                [news addObjectsFromArray:newNews];
                [self.tableNews reloadData];
                [self doneLoadingTableViewData];
                
                //如果是第一页 则缓存下来
                if (news.count <= 20) {
                    [Tool saveCache:5 andID:self.catalog andString:operation.responseString];
                }
            }
            @catch (NSException *exception) {
                [NdUncaughtExceptionHandler TakeException:exception];
            }
            @finally {
                [self doneLoadingTableViewData];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"新闻列表获取出错");
            //如果是刷新
            [self doneLoadingTableViewData];
            
            if ([Config Instance].isNetworkRunning == NO) {
                return;
            }
            isLoading = NO;
            if ([Config Instance].isNetworkRunning) {
                [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
            }
        }];
        isLoading = YES;
        [self.tableNews reloadData];
    }
    //如果没有网络连接
    else
    {
        NSString *value = [Tool getCache:5 andID:self.catalog];
        if (value) {
            NSMutableArray *newNews = [Tool readStrNewsArray:value andOld:news];
            [self.tableNews reloadData];
            isLoadOver = YES;
            [news addObjectsFromArray:newNews];
            [self.tableNews reloadData];
            [self doneLoadingTableViewData];
        }
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([Config Instance].isNetworkRunning) {
        if (isLoadOver) {
            return news.count == 0 ? 1 : news.count;
        }
        else 
            return news.count + 1;
    }
    else
        return news.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([news count] > 0) {
        if ([indexPath row] < [news count]) 
        {
            NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NewsCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[NewsCell class]]) {
                        cell = (NewsCell *)o;
                        break;
                    }
                }
            }
            cell.lblTitle.font = [UIFont boldSystemFontOfSize:15.0];
            if (self.catalog <= 1) {
                News *n = [news objectAtIndex:[indexPath row]];
                cell.lblTitle.text = n.title;
                cell.lblAuthor.text = [NSString stringWithFormat:@"%@ 发布于 %@ (%d评)", n.author, n.pubDate, n.commentCount];
            }
            else
            {
                BlogUnit *b = [news objectAtIndex:indexPath.row];
                cell.lblTitle.text = b.title;
                cell.lblAuthor.text = [NSString stringWithFormat:@"%@ %@ %@ (%d评)", b.authorName,b.documentType==1?@"原创":@"转载", b.pubDate, b.commentCount];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部新闻" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部新闻" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= [news count]) {
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else {
        NewsBase *parent = (NewsBase *)self.parentViewController;
        self.parentViewController.title = [parent getSegmentTitle];
        self.parentViewController.tabBarItem.title = @"综合";
        if (self.catalog == 1) {
            News *n = [news objectAtIndex:row];
            if (n) 
            {
                
                if (n.url.length == 0) {
                    [Tool pushNewsDetail:n andNavController:self.parentViewController.navigationController andIsNextPage:NO];
                }
                else
                {
                    [Tool analysis:n.url andNavController:parent.navigationController];
                }            
            }
        }
        else
        {
            BlogUnit *b = [news objectAtIndex:row];
            if (b) {
                [Tool analysis:b.url andNavController:parent.navigationController];
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableNews];
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
    if ([Config Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
    //无网络连接则读取缓存
    else {
        NSString *value = [Tool getCache:5 andID:self.catalog];
        if (value) 
        {
            NSMutableArray *newNews = [Tool readStrNewsArray:value andOld:news];
            if (newNews == nil) {
                [self.tableNews reloadData];
            }
            else if(newNews.count <= 0){
                [self.tableNews reloadData];
                isLoadOver = YES;
            }
            else if(newNews.count < 20){
                isLoadOver = YES;
            }
            [news addObjectsFromArray:newNews];
            [self.tableNews reloadData];
            [self doneLoadingTableViewData];
        }
    }
}

@end
