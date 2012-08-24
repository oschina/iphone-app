//
//  ShareObject.h
//  oschina
//
//  Created by wangjun on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareObject : NSObject

@property (retain,nonatomic) NSString * title;
@property (retain,nonatomic) NSString * url;

- (id)initWithParameters:(NSString *)ntitle andUrl:(NSString *)nurl;

@end
