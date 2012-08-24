//
//  TweetPubCache.m
//  oschina
//
//  Created by wangjun on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TweetPubCache.h"

@implementation TweetPubCache

@synthesize tweetText;
@synthesize tweetImg;
@synthesize isFirstTime;
@synthesize key;

+ (TweetPubCache *)getTweetPubCacheByKey:(NSString *)nkey andArray:(NSArray *)datas
{
    for (TweetPubCache *t in datas) {
        if ([t.key isEqualToString:nkey]) {
            return t;
        }
    }
    return nil;
}

- (id)initWithParameters:(NSString *)text andImg:(NSData *)img andKey:(NSString *)nkey
{
    TweetPubCache * t = [[TweetPubCache alloc] init];
    t.tweetImg = img;
    t.tweetText = text;
    t.isFirstTime = YES;
    t.key = nkey;
    return t;
}


@end
