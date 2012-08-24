//
//  AFOSCClient.h
//  oschina
//
//  Created by wangjun on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "About.h"
#import "AFHTTPClient.h"

@interface AFOSCClient : AFHTTPClient

+ (AFOSCClient *)sharedClient;

@end
