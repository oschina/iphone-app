//
//  CommentRefer.h
//  oschina
//
//  Created by wangjun on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentRefer : NSObject

@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * body;

- (id)initWithParamters:(NSString *)ntitle andBody:(NSString *)nbody;

@end
