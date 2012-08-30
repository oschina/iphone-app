//
//  ApiError.h
//  oschina
//
//  Created by wangjun on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiError : NSObject

@property int errorCode;
@property (copy,nonatomic) NSString * errorMessage;

- (id)initWithParameters:(int)nerrorCode andMessage:(NSString *)nerrorMessage;

@end
