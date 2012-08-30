//
//  RelativeNews.h
//  oschina
//
//  Created by wangjun on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RelativeNews : NSObject

@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) NSString * title;

- (id)initWithParameters:(NSString *)nurl andTitle:(NSString *)ntitle;

@end
