//
//  RelativeNews.m
//  oschina
//
//  Created by wangjun on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RelativeNews.h"

@implementation RelativeNews

@synthesize url;
@synthesize title;

- (id)initWithParameters:(NSString *)nurl andTitle:(NSString *)ntitle
{
    RelativeNews *r = [[RelativeNews alloc] init];
    r.url = nurl;
    r.title = ntitle;
    return r;
}

@end
