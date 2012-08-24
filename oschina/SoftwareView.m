//
//  SoftwareView.m
//  oschina
//
//  Created by wangjun on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoftwareView.h"

@implementation SoftwareView
@synthesize tableSoftwares;
@synthesize searchTag;
@synthesize tag;
@synthesize isSoftwareTagList;
@synthesize headTitle;

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = self.tableSoftwares.backgroundColor = [Tool getBackgroundColor];
    softwares = [[NSMutableArray alloc] initWithCapacity:20];
    
    [self reload];
}
-(void)viewDidUnload
{
    [self setTableSoftwares:nil];
    [softwares removeAllObjects];
    softwares = nil;
    [super viewDidUnload];
}
-(void)reload
{
    [[AFOSCClient sharedClient] postPath:isSoftwareTagList ? api_softwaretag_list : api_software_list 
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:isSoftwareTagList ? [NSString stringWithFormat:@"%d",self.tag] : self.searchTag,@"searchTag",[NSString stringWithFormat:@"%d", softwares.count/20],@"pageIndex",@"20",@"pageSize", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *response = operation.responseString;
                [Tool getOSCNotice2:response];
                isLoading = NO;
                @try {
                    TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
                    TBXMLElement *root = xml.rootXMLElement;
                    TBXMLElement *_results = [TBXML childElementNamed:@"softwares" parentElement:root];
                    if (!_results) {
                        isLoadOver = YES;
                        [tableSoftwares reloadData];
                        return;
                    }
                    TBXMLElement *first = [TBXML childElementNamed:@"software" parentElement:_results];
                    if (!first) {
                        isLoadOver = YES;
                        [self.tableSoftwares reloadData];
                        return;
                    }
                    NSMutableArray * newResults = [[NSMutableArray alloc] initWithCapacity:20];
                    TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:first];
                    TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:first];
                    TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:first];
                    SoftwareUnit *s = [[SoftwareUnit alloc] initWithParameters:[TBXML textForElement:name] andDescription:[TBXML textForElement:description] andUrl:[TBXML textForElement:url]];
                    if (![Tool isRepeatSoftware:softwares andSoftware:s]) {
                        [newResults addObject:s];
                    }
                    while (first) {
                        first = [TBXML nextSiblingNamed:@"software" searchFromElement:first];
                        if (first) {
                            name = [TBXML childElementNamed:@"name" parentElement:first];
                            description = [TBXML childElementNamed:@"description" parentElement:first];
                            url = [TBXML childElementNamed:@"url" parentElement:first];
                            s = [[SoftwareUnit alloc] initWithParameters:[TBXML textForElement:name] andDescription:[TBXML textForElement:description] andUrl:[TBXML textForElement:url]];
                            if (![Tool isRepeatSoftware:softwares andSoftware:s]) {
                                [newResults addObject:s];
                            }
                        }
                        else
                            break;
                    }
                    if (newResults.count < 20) {
                        isLoadOver = YES;
                    }
                    [softwares addObjectsFromArray:newResults];
                    [self.tableSoftwares reloadData];
                    
                }
                @catch (NSException *exception) {
                    [NdUncaughtExceptionHandler TakeException:exception];
                }
                @finally {
                    
                }

                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                return ;
            }];
    isLoading = YES;
    [self.tableSoftwares reloadData];
}
-(void)reloadType
{
    [self clear];
    [self reload];
}
-(void)clear
{
    [softwares removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return softwares.count == 0 ? 1 : softwares.count;
    }
    else 
        return softwares.count + 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLoadOver) {
        return softwares.count == 0 ? 62 : 56;
    }
    else
    {
        return indexPath.row < softwares.count ? 56 : 62;
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (softwares.count > 0) {
        if (indexPath.row < softwares.count) {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SoftwareCellIdentifier];
            if (!cell) 
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SoftwareCellIdentifier];
            }
            SoftwareUnit * s = [softwares objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.text = s.name;
            cell.detailTextLabel.text = s.description;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"加载完毕" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"加载完毕" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = indexPath.row;
    if (row >= softwares.count) {
        if (!isLoading && !isLoadOver) {
            [self performSelector:@selector(reload)];
        }
    }
    else
    {
        SoftwareUnit * s = [softwares objectAtIndex:row];
        if (s) {
            [Tool analysis:s.url andNavController:self.navigationController];
        }
    }
}

@end
