//
//  SoftwareTypeView.h
//  oschina
//
//  Created by wangjun on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoftwareCatalog.h"

@interface SoftwareTypeView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * softwareCatalogs;
    BOOL isLoading;
    BOOL isLoadOver;
}
@property (strong, nonatomic) IBOutlet UITableView *tableSoftwareCatalogs;
@property (retain, nonatomic) NSString * headTitle;
@property int tag;

-(void)reload;
-(void)clear;

@end
