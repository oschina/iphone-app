//
//  SearchView.m
//  oschina
//
//  Created by wangjun on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView
@synthesize segmentSearch;
@synthesize tableResult;
@synthesize _searchBar;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    allCount = 0;
    [super viewDidLoad];
    self.navigationItem.title = @"搜索";
    self.view.backgroundColor = [Tool getBackgroundColor];
    self.tableResult.backgroundColor = [Tool getBackgroundColor];
    results = [[NSMutableArray alloc] initWithCapacity:20];
    
    self.navigationItem.titleView = self.segmentSearch;
    
    [_searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setSegmentSearch:nil];
    [self setTableResult:nil];
    self._searchBar = nil;
    [super viewDidUnload];
}

#pragma 搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBar.text.length == 0) {
        return;
    }
    [searchBar resignFirstResponder];
    //清空
    [self clear];
    [self doSearch];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}
- (IBAction)segementChanged:(id)sender 
{
    if (_searchBar.text.length == 0) {
        return;
    }
    //清空
    [self clear];
    [self doSearch];
}

-(void)doSearch
{
    isLoading = YES;
    NSString * catalog;
    switch (self.segmentSearch.selectedSegmentIndex) {
        case 0:
            catalog = @"software";
            break;
        case 1:
            catalog = @"post";
            break;
        case 2:
            catalog = @"blog";
            break;
        case 3:
            catalog = @"news";
            break;
    }
    
    [[AFOSCClient sharedClient] postPath:api_search_list parameters:[NSDictionary dictionaryWithObjectsAndKeys:_searchBar.text,@"content",catalog,@"catalog",[NSString stringWithFormat:@"%d", allCount/20],@"pageIndex",@"20",@"pageSize", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self._searchBar resignFirstResponder];
        self.tableResult.hidden = NO;
        [Tool getOSCNotice2:operation.responseString];
        isLoading = NO;
        int count = [Tool isListOver2:operation.responseString];
        allCount += count;
        NSString *response = operation.responseString;
        @try {
            
            TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
            TBXMLElement *root = xml.rootXMLElement;
            TBXMLElement *_results = [TBXML childElementNamed:@"results" parentElement:root];
            if (!_results) {
                isLoadOver = YES;
                [self.tableResult reloadData];
                return;
            }
            TBXMLElement *first = [TBXML childElementNamed:@"result" parentElement:_results];
            if (!first) {
                isLoadOver = YES;
                [self.tableResult reloadData];
                return;
            }
            NSMutableArray * newResults = [[NSMutableArray alloc] initWithCapacity:20];
            TBXMLElement *objid = [TBXML childElementNamed:@"objid" parentElement:first];
            TBXMLElement *type = [TBXML childElementNamed:@"type" parentElement:first];
            TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:first];
            TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:first];
            TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
            NSString * pubDateStr = [TBXML textForElement:pubDate];
            TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
            SearchResult * s = [[SearchResult alloc] initWithParameters:[[TBXML textForElement:objid] intValue] andType:[[TBXML textForElement:type] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url] andPubDate:[pubDateStr isEqualToString:@""] ? @"" : [Tool intervalSinceNow:pubDateStr] andAuthor:[TBXML textForElement:author]];
            if (![Tool isRepeatSearch:results andResult:s]) {
                [newResults addObject:s];
            }
            while (first) {
                first = [TBXML nextSiblingNamed:@"result" searchFromElement:first];
                if (first) {
                    objid = [TBXML childElementNamed:@"objid" parentElement:first];
                    type = [TBXML childElementNamed:@"type" parentElement:first];
                    title = [TBXML childElementNamed:@"title" parentElement:first];
                    url = [TBXML childElementNamed:@"url" parentElement:first];
                    pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                    author = [TBXML childElementNamed:@"author" parentElement:first];
                    s = [[SearchResult alloc] initWithParameters:[[TBXML textForElement:objid] intValue] andType:[[TBXML textForElement:type] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andAuthor:[TBXML textForElement:author]];
                    if (![Tool isRepeatSearch:results andResult:s]) {
                        [newResults addObject:s];
                    }
                }
                else
                {
                    break;
                }
            }
            if (newResults.count < 20) {
                isLoadOver = YES;
            }
            [results addObjectsFromArray:newResults];
            [self.tableResult reloadData];
            
        }
        @catch (NSException *exception) {
            [NdUncaughtExceptionHandler TakeException:exception];
        }
        @finally {
        
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
    }];
    
    [self.tableResult reloadData];
}
-(void)clear
{
    [results removeAllObjects];
    [self.tableResult reloadData];
    isLoading = NO;
    isLoadOver = NO;
    allCount = 0;
}

#pragma TableView的处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return results.count == 0 ? 1 : results.count;
    }
    else
        return results.count + 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLoadOver) {
        return results.count == 0 ? 62 : 50;
    }
    else
    {
        return indexPath.row < results.count ? 50 : 62;
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (results.count > 0) 
    {
        if (indexPath.row < results.count) 
        {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NormalCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NormalCellIdentifier];
            }
            SearchResult * s = [results objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
            cell.textLabel.text = s.title;
            if (self.segmentSearch.selectedSegmentIndex != 0) 
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 发表于 %@", s.author, s.pubDate];
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"搜索完毕" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"查无结果" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self._searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = indexPath.row;
    if (row >= results.count) 
    {
        if (!isLoading && !isLoadOver) 
        {
            [self performSelector:@selector(doSearch)];
        }
    }
    else
    {
        SearchResult * s = [results objectAtIndex:row];
        if (s) 
        {
            [Tool analysis:s.url andNavController:self.navigationController];
        }
    }
}
@end
