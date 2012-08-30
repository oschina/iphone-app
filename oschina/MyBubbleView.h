//
//  MyBubbleView.h
//  oschina
//
//  Created by wangjun on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatPopView.h"

@interface MyBubbleView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isLoading;
    BOOL isLoadOver;
    NSMutableArray * comments;
    int allCount;
}

@property (strong, nonatomic) IBOutlet UITableView *tableBubbles;
@property int friendID;
@property (copy,nonatomic) NSString * friendName;

- (void)reload;

@end
