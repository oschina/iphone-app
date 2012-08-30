//
//  TweetPubCache.h
//  oschina
//
//  Created by wangjun on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetPubCache : NSObject

@property (copy,nonatomic) NSString * tweetText;
@property (retain,nonatomic) NSData * tweetImg;
@property BOOL isFirstTime;
@property (copy,nonatomic) NSString * key;

+ (TweetPubCache *)getTweetPubCacheByKey:(NSString *)nkey andArray:(NSArray *)datas;

- (id)initWithParameters:(NSString *)text andImg:(NSData *)img andKey:(NSString *)nkey;

@end
