//
//  AFOSCClient.m
//  oschina
//
//  Created by wangjun on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AFOSCClient.h"
#import "AFXMLRequestOperation.h"

//static NSString * const kAFTwitterAPIBaseURLString = @"http://www.oschina.net/action/api/";
//static NSString * const kAFUrl = @"http://"
//#define kAFUrl @"http://192.168.1.213/action/api/"
#define kAFUrl @"http://www.oschina.net/action/api/"

@interface AFOSCClient ()

@end

@implementation AFOSCClient

+ (AFOSCClient *)sharedClient {
    static AFOSCClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFOSCClient alloc] initWithBaseURL:[NSURL URLWithString:kAFUrl]];
        [_sharedClient setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@", [Tool getOSVersion], [Config Instance].getIOSGuid]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}


@end
