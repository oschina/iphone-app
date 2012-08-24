//
//  BubbleView.h
//  oschina
//
//  Created by wangjun on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

@interface BubbleView : UIViewController<UIBubbleTableViewDataSource>
{
    BOOL isLoading;
    BOOL isLoadOver;
    NSMutableArray * comments;
    int allCount;
}

@property (strong, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property int friendID;
@property (retain,nonatomic) NSString * friendName;
-(void)reload;

@end
