//
//  CheckNetwork.m
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"

@implementation CheckNetwork
+(BOOL)isExistenceNetwork
{
//	BOOL isExistenceNetwork;
//	Reachability *r = [Reachability reachabilityWithHostName:@"www.oschina.net"];
//    switch ([r currentReachabilityStatus]) {
//        case NotReachable:
//			isExistenceNetwork=FALSE;
//            //   NSLog(@"娌℃湁缃戠粶");
//            break;
//        case ReachableViaWWAN:
//			isExistenceNetwork=TRUE;
//            //   NSLog(@"姝ｅ湪浣跨敤3G缃戠粶");
//            break;
//        case ReachableViaWiFi:
//			isExistenceNetwork=TRUE;
//            //  NSLog(@"姝ｅ湪浣跨敤wifi缃戠粶");        
//            break;
//    }
//	return isExistenceNetwork;
    
    return YES;
}
@end
