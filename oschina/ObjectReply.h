//
//  ObjectReply.h
//  oschina
//
//  Created by wangjun on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectReply : NSObject

@property (copy,nonatomic) NSString * objectname;
@property (copy,nonatomic) NSString * objectbody;

- (id)initWithParameter:(NSString *)nobjectname andBody:(NSString *)nobjectbody;

@end
