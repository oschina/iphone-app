//
//  SoftwareTypeView.m
//  oschina
//
//  Created by wangjun on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoftwareTypeView.h"

@implementation SoftwareTypeView
@synthesize tableSoftwareCatalogs;
@synthesize tag;
@synthesize headTitle;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [Tool getBackgroundColor];
    self.tableSoftwareCatalogs.backgroundColor = [Tool getBackgroundColor];
    softwareCatalogs = [[NSMutableArray alloc] initWithCapacity:20];
    
    [self reload];
}
-(void)viewDidAppear:(BOOL)animated
{
    if (self.headTitle == nil) 
    {
        self.navigationItem.title = @"软件分类";
    }
    else
    {
        self.navigationItem.title = self.headTitle;
    }
}
- (void)viewDidUnload
{
    self.tableSoftwareCatalogs = nil;
    [softwareCatalogs removeAllObjects];
    softwareCatalogs = nil;
    [super viewDidUnload];
}
-(void)reload
{
    NSString * url = [NSString stringWithFormat:@"%@?tag=%d",api_softwarecatalog_list,self.tag];
    
    [[AFOSCClient sharedClient]getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = operation.responseString;
        [Tool getOSCNotice2:response];
        isLoading = NO;
        @try {
            
            TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
            TBXMLElement *root = xml.rootXMLElement;
            TBXMLElement *_results = [TBXML childElementNamed:@"softwareTypes" parentElement:root];
            if (!_results) {
                isLoadOver = YES;
                [tableSoftwareCatalogs reloadData];
                return;
            }
            TBXMLElement *first = [TBXML childElementNamed:@"softwareType" parentElement:_results];
            if (!first) {
                isLoadOver = YES;
                [tableSoftwareCatalogs reloadData];
                return;
            }
            NSMutableArray * newResults = [[NSMutableArray alloc] initWithCapacity:20];
            TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:first];
            TBXMLElement *_tag = [TBXML childElementNamed:@"tag" parentElement:first];
            SoftwareCatalog * s = [[SoftwareCatalog alloc] initWithParameters:[TBXML textForElement:name] andTag:[[TBXML textForElement:_tag] intValue]];
            if (![Tool isRepeatSoftwareCatalog:softwareCatalogs andSoftwareCatalog:s]) {
                [newResults addObject:s];
            }
            while (first) {
                first = [TBXML nextSiblingNamed:@"softwareType" searchFromElement:first];
                if (first) {
                    name = [TBXML childElementNamed:@"name" parentElement:first];
                    _tag = [TBXML childElementNamed:@"tag" parentElement:first];
                    s = [[SoftwareCatalog alloc] initWithParameters:[TBXML textForElement:name] andTag:[[TBXML textForElement:_tag] intValue]];
                    if (![Tool isRepeatSoftwareCatalog:softwareCatalogs andSoftwareCatalog:s]) {
                        [newResults addObject:s];
                    }
                }
                else
                    break;
            }
            if (newResults.count < 20) {
                isLoadOver = YES;
            }
            [softwareCatalogs addObjectsFromArray:newResults];
            [self.tableSoftwareCatalogs reloadData];
        }
        @catch (NSException *exception) {
            [NdUncaughtExceptionHandler TakeException:exception];
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Tool ToastNotification:@"网络连接错误" andView:self.view andLoading:NO andIsBottom:NO];
        return ;
    }];
    
    isLoading = YES;
    [self.tableSoftwareCatalogs reloadData];
}
-(void)clear
{
    [softwareCatalogs removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return softwareCatalogs.count == 0 ? 1 : softwareCatalogs.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (softwareCatalogs.count == 0) {
        return 62;
    }
    else
        return 40;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getCellBackgroundColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (softwareCatalogs.count > 0) {
        if (indexPath.row < softwareCatalogs.count) {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SoftwareCatalogIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SoftwareCatalogIdentifier];
            }
            SoftwareCatalog * s = [softwareCatalogs objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
            cell.textLabel.text = s.name;
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
    if (row >= softwareCatalogs.count) {
        if (!isLoading && !isLoadOver) {
            [self performSelector:@selector(reload)];
        }
    }
    else
    {
        SoftwareCatalog * s = [softwareCatalogs objectAtIndex:row];
        if (s) {
            //进入下一步的 SoftwareCatalogsView
            if (self.tag == 0) 
            {
                [Config Instance].singleSoftwareCatalog = s;
                SoftwareTypeView * view = [[SoftwareTypeView alloc] init];
                view.headTitle = s.name;
                view.tag = s.tag;
                [self.navigationController pushViewController:view animated:YES];
            }
            //进入 SoftwaresView
            else
            {
                [Config Instance].singleSoftwareCatalog = s;
                SoftwareView * view = [[SoftwareView alloc] init];
                view.headTitle = s.name;
                view.isSoftwareTagList = YES;
                view.tag = s.tag;
                [self.navigationController pushViewController:view animated:YES];
            }
        }
    }
}

@end
