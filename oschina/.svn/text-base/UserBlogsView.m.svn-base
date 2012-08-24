//
//  UserBlogsView.m
//  oschina
//
//  Created by wangjun on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserBlogsView.h"

@interface UserBlogsView ()

@end

@implementation UserBlogsView
@synthesize tableBlogs;
@synthesize authorUID;
@synthesize authorName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableBlogs addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    blogs = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
    
    if (self.authorName.length > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@的博客", self.authorName];
    }
    
    self.tableBlogs.backgroundColor = [Tool getBackgroundColor];
}

- (void)viewDidUnload
{
    [self setTableBlogs:nil];
    [super viewDidUnload];
}

-(void)clear
{
    allCount = 0;
    [blogs removeAllObjects];
    isLoadOver = NO;
}

-(void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if (isLoading || isLoadOver) {
        return;
    }
    if (!noRefresh) {
        allCount = 0;
    }
    int pageIndex = allCount/20;
    NSString *url;
    if (self.authorUID > 0) {
        url = [NSString stringWithFormat:@"%@?authoruid=%d&pageIndex=%d&pageSize=%d&uid=%d", api_userblog_list, self.authorUID, pageIndex, 20, [Config Instance].getUID];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?authorname=%@&pageIndex=%d&pageSize=%d&uid=%d", api_userblog_list, self.authorName, pageIndex, 20, [Config Instance].getUID];
    }

    [[AFOSCClient sharedClient] getPath:url parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    @try {
                                        [Tool getOSCNotice2:operation.responseString];
                                        
                                        isLoading = NO;
                                        if (!noRefresh) {
                                            [self clear];
                                        }
                                        
                                        NSMutableArray *newBlogs = [Tool readStrUserBlogsArray:operation.responseString andOld:blogs];
                                        int count = [Tool isListOver2:operation.responseString];
                                        allCount += count;
                                        if (count < 20)
                                        {
                                            isLoadOver = YES;
                                        }
                                        
                                        [blogs addObjectsFromArray:newBlogs];
                                        [self.tableBlogs reloadData];
                                        [self doneLoadingTableViewData];
                                    }
                                    @catch (NSException *exception) {
                                        [NdUncaughtExceptionHandler TakeException:exception];
                                    }
                                    @finally {
                                        [self doneLoadingTableViewData];
                                    }
                                    
                                   
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                    NSLog(@"个人博客列表获取出错");
                                    
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
        [self.tableBlogs reloadData];
}

#pragma TableView的处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (isLoadOver) {
            return blogs.count == 0 ? 1 : blogs.count;
        }
        else 
            return blogs.count + 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (blogs.count > 0) {
        if (indexPath.row < blogs.count) 
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
            BlogUnit *n = [blogs objectAtIndex:indexPath.row];
            cell.lblTitle.font = [UIFont boldSystemFontOfSize:15.0];
            cell.lblTitle.text = n.title;
            cell.lblAuthor.text = [NSString stringWithFormat:@"%@ %@ %@ (%d评)", n.authorName,n.documentType == 1 ? @"原创":@"转载", n.pubDate, n.commentCount];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //添加长按删除功能 
            [cell initGR];
            [cell setDelegate:self];
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部博客" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部博客" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= [blogs count]) {
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else {
        BlogUnit *n = [blogs objectAtIndex:row];
        if (n) 
        {     
            self.navigationController.title = self.authorName;
            [Tool analysis:n.url andNavController:self.navigationController];
        }
    }
    
}
//显示菜单  
- (void)showMenu:(id)cell
{  
    BlogUnit * t = [blogs objectAtIndex:[tableBlogs indexPathForCell:cell].row];
    if (t) {
        if (t.authorUID != [Config Instance].getUID) {
            return;
        }
    }
    //如果没有登录
    [cell becomeFirstResponder];  
    UIMenuController * menu = [UIMenuController sharedMenuController];  
    CGRect rect = [cell frame];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - tableBlogs.contentOffset.y, rect.size.width, rect.size.height);
    [menu setTargetRect:newRect inView:[self view]];
    [menu setMenuVisible: YES animated: YES];    
}  
- (void)deleteRow:(UITableViewCell *)cell
{
    NSIndexPath *path = [tableBlogs indexPathForCell:cell];
    BlogUnit *c = [blogs objectAtIndex:[path row]];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在删除" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient] getPath:api_userblog_delete
                             parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", c._id],@"id",[NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",[NSString stringWithFormat:@"%d", c.authorUID],@"authoruid", nil] 
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
                                            [Tool ToastNotification:[NSString stringWithFormat:@"错误 %@", error.errorMessage] andView:self.view andLoading:NO andIsBottom:NO];
                                        }
                                            break;
                                    }

                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [hud hide:YES];
                                    [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                                }];
}

#pragma 下提刷新
-(void)reloadTableViewDataSource
{
    _reloading = YES;
}
-(void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableBlogs];
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
    isLoadOver = NO;
    [self reload:NO];
}


@end
