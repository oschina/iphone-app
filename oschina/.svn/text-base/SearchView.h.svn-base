//
//  SearchView.h
//  oschina
//
//  Created by wangjun on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResult.h"
#import "MBProgressHUD.h"

@interface SearchView : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    NSMutableArray * results;
    BOOL isLoading;
    BOOL isLoadOver;
    
    int allCount;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentSearch;
@property (strong, nonatomic) IBOutlet UITableView *tableResult;
@property (strong, nonatomic) IBOutlet UISearchBar *_searchBar;
- (IBAction)segementChanged:(id)sender;

-(void)doSearch;
-(void)clear;


@end
