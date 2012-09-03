//
//  FriendsView.m
//  oschina
//
//  Created by wangjun on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FriendsView.h"

@implementation FriendsView
@synthesize tableFriends;
@synthesize segement;
@synthesize imageDownloadsInProgress;
@synthesize isFansType;
@synthesize fansCount;
@synthesize followersCount;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSArray *allDownloads = self.imageDownloadsInProgress.allValues;
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空 
    for (Friend *f in friends) {
        f.imgData = nil;
    }
    [friends removeAllObjects];
}

#pragma mark - View lifecycle
-(void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"好友列表";
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    friends = [[NSMutableArray alloc] initWithCapacity:0];
    
    //下拉刷新
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableFriends addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    self.tableFriends.backgroundColor = [Tool getBackgroundColor];
    
    //类型
    if (isFansType) {
        self.segement.selectedSegmentIndex = 1;
    }
    [self reload:YES];
    
    [self.segement setTitle:[NSString stringWithFormat:@"我关注的 %d",self.followersCount] forSegmentAtIndex:0];
    [self.segement setTitle:[NSString stringWithFormat:@"所有粉丝 %d",self.fansCount] forSegmentAtIndex:1];
}
- (void)viewDidUnload
{
    [self setSegement:nil];
    [self setTableFriends:nil];
    _refreshHeaderView = nil;
    [friends removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    friends = nil;
    [super viewDidUnload];
}

-(void)reload:(BOOL)noRefresh
{
    if (isLoadOver) {
        [self doneLoadingTableViewData];
        return;
    }
    
    [[AFOSCClient sharedClient] postPath:api_friends_list 
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:segement.selectedSegmentIndex == 0 ? @"1" : @"0",@"relation",
                        [NSString stringWithFormat:@"%d", friends.count/20],@"pageIndex",
                        @"20",@"pageSize",
                        [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (!noRefresh) {
                    [self clear];
                }
                
                [self doneLoadingTableViewData];
                isLoading = NO;
                NSString *response = operation.responseString;
                [Tool getOSCNotice2:response];
                @try {
                    
                    TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
                    TBXMLElement *root = xml.rootXMLElement;
                    //显示
                    TBXMLElement *_friends = [TBXML childElementNamed:@"friends" parentElement:root];
                    if (!_friends) {
                        isLoadOver = YES;
                        [self.tableFriends reloadData];
                        return;
                    }
                    TBXMLElement *first = [TBXML childElementNamed:@"friend" parentElement:_friends];
                    if (first == nil) {
                        [self.tableFriends reloadData];
                        isLoadOver = YES;
                        return;
                    }
                    NSMutableArray *newFriends = [[NSMutableArray alloc] initWithCapacity:20];
                    TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:first];
                    TBXMLElement *userid = [TBXML childElementNamed:@"userid" parentElement:first];
                    TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                    TBXMLElement *expertise = [TBXML childElementNamed:@"expertise" parentElement:first];
                    TBXMLElement *gender = [TBXML childElementNamed:@"gender" parentElement:first];
                    Friend *f = [[Friend alloc] initWithParameters:[TBXML textForElement:name] andUID:[[TBXML textForElement:userid] intValue] andPortrait:[TBXML textForElement:portrait] andExpertise:[TBXML textForElement:expertise] andMale:[[TBXML textForElement:gender] intValue] == 1];
                    if (![Tool isRepeatFriend: friends andFriend:f]) {
                        [newFriends addObject:f];
                    }
                    while (first) {
                        first = [TBXML nextSiblingNamed:@"friend" searchFromElement:first];
                        if (first) {
                            name = [TBXML childElementNamed:@"name" parentElement:first];
                            userid = [TBXML childElementNamed:@"userid" parentElement:first];
                            portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                            expertise = [TBXML childElementNamed:@"expertise" parentElement:first];
                            gender = [TBXML childElementNamed:@"gender" parentElement:first];
                            f = [[Friend alloc] initWithParameters:[TBXML textForElement:name] andUID:[[TBXML textForElement:userid] intValue] andPortrait:[TBXML textForElement:portrait] andExpertise:[TBXML textForElement:expertise] andMale:[[TBXML textForElement:gender] intValue] == 1];
                            if (![Tool isRepeatFriend:friends andFriend:f]) {
                                [newFriends addObject:f];
                            }
                        }
                        else
                            break;
                    }
                    if (newFriends.count < 20) {
                        isLoadOver = YES;
                    }
                    
                    [friends addObjectsFromArray:newFriends];
                    [self.tableFriends reloadData];
                    
                }
                @catch (NSException *exception) {
                    [NdUncaughtExceptionHandler TakeException:exception];
                }
                @finally {
                    [self doneLoadingTableViewData];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
                NSLog(@"好友列表获取出错");
                
                [self doneLoadingTableViewData];
                isLoading = NO;
                if ([Config Instance].isNetworkRunning) {
                    [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                }
                
            }];
    
    isLoading = YES;
    [self.tableFriends reloadData];
}
-(void)reloadType
{
    [self clear];
    [self reload:NO];
}
-(void)clear
{
    [friends removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    isLoadOver = NO;
}
- (IBAction)segementChanged:(id)sender {
    
    [self reloadType];
}

#pragma TableView处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return friends.count == 0 ? 1 : friends.count;
    }
    else
        return friends.count + 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (friends.count > 0) {
        if (indexPath.row < friends.count) 
        {
            FriendCell * cell = (FriendCell *)[tableFriends dequeueReusableCellWithIdentifier:FriendCellIdentifier];
            if (!cell) {
                NSArray * objects = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[FriendCell class]]) {
                        cell = (FriendCell *)o;
                        break;
                    }
                }
            }
            cell.txtExpertise.font = [UIFont boldSystemFontOfSize:13.0];
            cell.txtExpertise.text = @"";
            cell.imgPortrait.image = [UIImage imageNamed:@"avatar_loading.jpg"];
            Friend * f = [friends objectAtIndex:indexPath.row];
            cell.imgGender.image = [UIImage imageNamed:f.isMale ? @"man.png" : @"woman.png"];
            cell.lblName.text = f.name;
            cell.txtExpertise.text = f.expertise;
            if (f.imgData) {
                cell.imgPortrait.image = f.imgData;
            }
            else
            {
                if ([f.portrait isEqualToString:@""]) {
                    f.imgData = [UIImage imageNamed:@"avatar_noimg.jpg"];
                }
                else
                {
                    IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                    if (downloader == nil) {
                        ImgRecord *record = [ImgRecord new];
                        record.url = f.portrait;
                        [self startIconDownload:record forIndexPath:indexPath];
                    }
                }
            }
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"加载完毕" andLoadingString:(isLoading ? loadingTip : loadNext20Tip)  andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"加载完毕" andLoadingString:(isLoading ? loadingTip : loadNext20Tip)  andIsLoading:isLoading];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= friends.count) {
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
        
    }
    else {
        Friend * f = [friends objectAtIndex:row];
        if (f) {
            [Tool pushUserDetail:f.userID andNavController:self.navigationController];
        }
    }
}
#pragma 下提刷新
-(void)reloadTableViewDataSource
{
    _reloading = YES;
}
-(void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableFriends];
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
}
//下载图片
-(void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:key];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgRecord = imgRecord;
        iconDownloader.index = key;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:key];
        [iconDownloader startDownload];
    }
}
-(void)appImageDidLoad:(NSString *)index
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
    if (iconDownloader) {
        int _index = index.intValue;
        if (_index >= friends.count) {
            return;
        }
        Friend *f = [friends objectAtIndex:_index];
        if (f) {
            f.imgData = iconDownloader.imgRecord.img;
            [self.tableFriends reloadData];
        }
    }
}

@end
