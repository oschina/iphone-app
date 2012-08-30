//
//  DataSingleton.h
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoadingCell.h"

@interface DataSingleton : NSObject

#pragma 单例模式
+ (DataSingleton *) Instance;
+ (id)allocWithZone:(NSZone *)zone;

//返回标示正在加载的选项
- (UITableViewCell *)getLoadMoreCell:(UITableView *)tableView 
                       andIsLoadOver:(BOOL)isLoadOver 
                       andLoadOverString:(NSString *)loadOverString 
                       andLoadingString:(NSString *)loadingString 
                       andIsLoading:(BOOL)isLoading;

@end
