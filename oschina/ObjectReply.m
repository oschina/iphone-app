//
//  ObjectReply.m
//  oschina
//
//  Created by wangjun on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ObjectReply.h"

@implementation ObjectReply

@synthesize objectbody;
@synthesize objectname;

- (id)initWithParameter:(NSString *)nobjectname andBody:(NSString *)nobjectbody
{
    ObjectReply *or = [[ObjectReply alloc] init];
    or.objectbody = nobjectbody;
    or.objectname = nobjectname;
    return or;
}

@end
