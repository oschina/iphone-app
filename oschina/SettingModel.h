//
//  SettingModel.h
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

@property (retain,nonatomic) NSString * img;
@property (retain,nonatomic) NSString * title;
@property (retain,nonatomic) NSString * title2;
@property NSUInteger tag;

- (id)initWith:(NSString *)_title andImg:(NSString *)_img andTag:(NSUInteger)_tag andTitle2:(NSString *)_title2;

@end
