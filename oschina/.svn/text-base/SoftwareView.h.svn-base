//
//  SoftwareView.h
//  oschina
//
//  Created by wangjun on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoftwareUnit.h"

@interface SoftwareView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    NSMutableArray * softwares;
    BOOL isLoading;
    BOOL isLoadOver;
}

@property (strong, nonatomic) IBOutlet UITableView *tableSoftwares;
@property (retain, nonatomic) NSString * headTitle;
@property (retain, nonatomic) NSString * searchTag;
@property int tag;
@property BOOL isSoftwareTagList;

-(void)reload;
-(void)reloadType;
-(void)clear;

@end
