//
//  Friend.m
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Friend.h"

@implementation Friend

@synthesize name;
@synthesize userID;
@synthesize portrait;
@synthesize expertise;
@synthesize isMale;
@synthesize imgData;

- (id)initWithParameters:(NSString *)newName 
                  andUID:(int)newUID 
                  andPortrait:(NSString *)nportrait 
                  andExpertise:(NSString *)nexpertise 
                  andMale:(BOOL)nisMale
{
    Friend * f = [[Friend alloc] init];
    f.name = newName;
    f.userID = newUID;
    f.portrait = nportrait;
    f.expertise = nexpertise;
    f.isMale = nisMale;
    return f;
}

@end
