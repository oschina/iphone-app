//
//  Favorite.m
//  oschina
//
//  Created by wangjun on 12-5-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

@synthesize objid;
@synthesize type;
@synthesize title;
@synthesize url;

- (id)initWithParameters:(int)nobjid andType:(int)nType andTitle:(NSString *)ntitle andUrl:(NSString *)nurl
{
    Favorite *f = [[Favorite alloc] init];
    f.objid = nobjid;
    f.type = nType;
    f.title = ntitle;
    f.url = nurl;
    return f;
}

@end
