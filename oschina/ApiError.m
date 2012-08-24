//
//  ApiError.m
//  oschina
//
//  Created by wangjun on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ApiError.h"

@implementation ApiError

@synthesize errorCode;
@synthesize errorMessage;

- (id)initWithParameters:(int)nerrorCode andMessage:(NSString *)nerrorMessage
{
    ApiError *error = [[ApiError alloc] init];
    error.errorCode = nerrorCode;
    error.errorMessage = nerrorMessage;
    return error;
}

@end
