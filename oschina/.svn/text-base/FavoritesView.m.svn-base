//
//  FavoritesView.m
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FavoritesView.h"

@implementation FavoritesView
@synthesize segmentType;
@synthesize tableFavorites;
@synthesize catalog;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"我的收藏夹";
    self.catalog = 1;

    allCount = 1;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableFavorites addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    favorites = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
    self.tableFavorites.backgroundColor = [Tool getBackgroundColor];
}
- (void)viewDidUnload
{
    [self setSegmentType:nil];
    [self setTableFavorites:nil];
    _refreshHeaderView = nil;
    [favorites removeAllObjects];
    favorites = nil;
    [super viewDidUnload];
}
-(void)clear
{
    allCount = 0;
    [favorites removeAllObjects];
    isLoadOver = NO;
}
-(void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([Config Instance].isNetworkRunning) 
    {
        if (isLoading || isLoadOver) 
        {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20;
        NSString *url = [NSString stringWithFormat:@"%@?uid=%d&type=%d&pageIndex=%d&pageSize=%d", api_favorite_list, [Config Instance].getUID,self.catalog, pageIndex, 20];
        
        [[AFOSCClient sharedClient]getPath:url parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {

                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       [self doneLoadingTableViewData];
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
                                           TBXMLElement *favs = [TBXML childElementNamed:@"favorites" parentElement:root];
                                           if (!favs) {
                                               isLoadOver = YES;
                                               [self.tableFavorites reloadData];
                                               [self doneLoadingTableViewData];
                                               return;
                                           }
                                           TBXMLElement *first = [TBXML childElementNamed:@"favorite" parentElement:favs];
                                           if (!first) {
                                               isLoadOver = YES;
                                               [self.tableFavorites reloadData];
                                               [self doneLoadingTableViewData];
                                               return;
                                           }
                                           NSMutableArray * newFavs = [[NSMutableArray alloc] initWithCapacity:20];
                                           TBXMLElement *objid = [TBXML childElementNamed:@"objid" parentElement:first];
                                           TBXMLElement *type = [TBXML childElementNamed:@"type" parentElement:first];
                                           TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:first];
                                           TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:first];
                                           Favorite *f = [[Favorite alloc] initWithParameters:[[TBXML textForElement:objid] intValue] andType:[[TBXML textForElement:type] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url]];
                                           if (![Tool isRepeatFavorite:favorites andFav:f]) {
                                               [newFavs addObject:f];
                                           }
                                           while (first) {
                                               first = [TBXML nextSiblingNamed:@"favorite" searchFromElement:first];
                                               if (first) {
                                                   objid = [TBXML childElementNamed:@"objid" parentElement:first];
                                                   type = [TBXML childElementNamed:@"type" parentElement:first];
                                                   title = [TBXML childElementNamed:@"title" parentElement:first];
                                                   url = [TBXML childElementNamed:@"url" parentElement:first];
                                                   f = [[Favorite alloc] initWithParameters:[[TBXML textForElement:objid] intValue] andType:[[TBXML textForElement:type] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url]];
                                                   if (![Tool isRepeatFavorite:favorites andFav:f]) {
                                                       [newFavs addObject:f];
                                                   }
                                               }
                                               else
                                               {
                                                   break;
                                               }
                                           }
                                           [favorites addObjectsFromArray:newFavs];
                                           [self.tableFavorites reloadData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           [self doneLoadingTableViewData];
                                       }
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       
                                       NSLog(@"获取收藏列表出错");
                                       
                                       //如果是刷新
                                       [self doneLoadingTableViewData];
                                       
                                       isLoading = NO;
                                       if ([Config Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                       
                                   }];
        
        isLoading = YES;
        [self.tableFavorites reloadData];
    }
    //如果没有网络连接
}
- (IBAction)segementChanged:(id)sender 
{
    switch (self.segmentType.selectedSegmentIndex) {
        case 0:
            self.catalog = 1;
            break;
        case 1:
            self.catalog = 2;
            break;
        case 2:
            self.catalog = 5;
            break;
        case 3:
            self.catalog = 3;
            break;
        case 4:
            self.catalog = 4;
            break;
    }
    [self clear];
    [self.tableFavorites reloadData];
    [self reload:NO];
}
#pragma TableView的处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return favorites.count == 0 ? 1 : favorites.count;
    }
    else 
        return favorites.count + 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLoadOver) {
        return favorites.count == 0 ? 62 : 40;
    }
    else
        return indexPath.row < favorites.count ? 40 : 62;
        
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (favorites.count > 0) {
        if (indexPath.row < favorites.count) {
            FavoriteCell * cell = [tableView dequeueReusableCellWithIdentifier:FavoriteCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[FavoriteCell class]]) {
                        cell = (FavoriteCell *)o;
                        break;
                    }
                }
            }
            Favorite * f = [favorites objectAtIndex:indexPath.row];
            cell.lblTitle.font = [UIFont boldSystemFontOfSize:16.0];
            cell.lblTitle.text = f.title;
            if (self.catalog != 5) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            //添加长按删除功能 
            [cell initGR];
            [cell setDelegate:self];
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已加载全部收藏" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已加载全部收藏" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading]; 
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = indexPath.row;
    if (row >= favorites.count) {
        if (!isLoading && !isLoadOver) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Favorite * f = [favorites objectAtIndex:row];
        if (f) 
        {
            //根据url处理
            [Tool analysis:f.url andNavController:self.navigationController];
        }
    }
}
//显示菜单  
- (void)showMenu:(id)cell
{  
    [cell becomeFirstResponder];  
    UIMenuController * menu = [UIMenuController sharedMenuController];  

    CGRect rect = [cell frame];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - tableFavorites.contentOffset.y + 46, rect.size.width, rect.size.height);
    [menu setTargetRect:newRect inView:[self view]];
    [menu setMenuVisible: YES animated: YES];    
}  
- (void)deleteRow:(UITableViewCell *)cell
{
    NSIndexPath *path = [tableFavorites indexPathForCell:cell];
    Favorite * c = [favorites objectAtIndex:path.row];
    //验证登录
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在取消收藏" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient] getPath:api_favorite_delete parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[Config Instance].getUID],@"uid",[NSString stringWithFormat:@"%d", c.objid],@"objid",[NSString stringWithFormat:@"%d", c.type],@"type", nil] 
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
                                    [hud hide:YES];
                                    [Tool getOSCNotice2:operation.responseString];
                                    ApiError *error = [Tool getApiError2:operation.responseString];
                                    if (error == nil) {
                                        [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                        return;
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
        [Tool ToastNotification:@"取消收藏失败" andView:self.view andLoading:NO andIsBottom:NO];
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableFavorites];
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
    if ([Config Instance].isNetworkRunning) 
    {
        isLoadOver = NO;
        [self reload:NO];
    }
    else
    {
        [self doneLoadingTableViewData];
    }
}
@end
