//
//  Config.m
//  oschina
//
//  Created by wangjun on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Config.h"
#import "AESCrypt.h"

@implementation Config
@synthesize shareObject;
@synthesize isNeedReloadTweets;
@synthesize tempComment;
@synthesize isLogin;
@synthesize viewBeforeLogin;
@synthesize viewNameBeforeLogin;
@synthesize isNetworkRunning;
@synthesize singleSoftwareCatalog;
@synthesize tweetCachePic;
@synthesize tweet;
@synthesize questionTitle;
@synthesize questionContent;
@synthesize questionIndex;
@synthesize msgs;
@synthesize comments;
@synthesize replies;

-(void)saveUserNameAndPwd:(NSString *)userName andPwd:(NSString *)pwd
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"UserName"];
    [settings removeObjectForKey:@"Password"];
    [settings setObject:userName forKey:@"UserName"];
    
    pwd = [AESCrypt encrypt:pwd password:@"pwd"];
    
    [settings setObject:pwd forKey:@"Password"];
    [settings synchronize];
}
-(NSString *)getUserName
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"UserName"];
}
-(NSString *)getPwd
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * temp = [settings objectForKey:@"Password"];
    return [AESCrypt decrypt:temp password:@"pwd"];
}
-(void)saveUID:(int)uid
{
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    [setting removeObjectForKey:@"UID"];
    [setting setObject:[NSString stringWithFormat:@"%d", uid] forKey:@"UID"];
    [setting synchronize];
}
-(int)getUID
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString *value = [setting objectForKey:@"UID"];
    if (value && [value isEqualToString:@""] == NO) 
    {
        return [value intValue];
    }
    else
    {
        return 0;
    }
}
-(void)saveCookie:(BOOL)_isLogin
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    [setting removeObjectForKey:@"cookie"];
    [setting setObject:isLogin ? @"1" : @"0" forKey:@"cookie"];
    [setting synchronize];
}
-(BOOL)isCookie
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * value = [setting objectForKey:@"cookie"];
    if (value && [value isEqualToString:@"1"]) {
        return YES;
    }
    else 
    {
        return NO;
    }
}
-(void)savePostPubNoticeMe:(BOOL)isNotice
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"isNotice"];
    [settings setObject:isNotice ? @"1" : @"0" forKey:@"isNotice"];
    [settings synchronize];
}
-(BOOL)isPostPubNoticeMe
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * value = [settings objectForKey:@"isNotice"];
    return value && [value isEqualToString:@"1"];
}

-(void)saveIsPostToMyZone:(BOOL)isToMyZone
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"isToMyZone"];
    [settings setObject:isToMyZone ? @"1" : @"0" forKey:@"isToMyZone"];
    [settings synchronize];
}
-(BOOL)getIsPostToMyZone
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *value = [settings objectForKey:@"isToMyZone"];
    if (value) {
        if ([value isEqualToString:@"1"]) {
            return YES;
        }
        else
            return NO;
    }
    else
        return NO;  
}

-(void)savePubPostCatalog:(int)catalog
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"PubPostCatalog"];
    [settings setObject:[NSString stringWithFormat:@"%d",catalog] forKey:@"PubPostCatalog"];
    [settings synchronize];
}

-(int)getPubPostCatalog
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * value = [settings objectForKey:@"PubPostCatalog"];
    if (value) {
        return [value intValue];
    }
    else 
        return 0;
}

-(NSString *)getIOSGuid
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * value = [settings objectForKey:@"guid"];
    if (value && [value isEqualToString:@""] == NO) {
        return value;
    }
    else
    {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString * uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        [settings setObject:uuidString forKey:@"guid"];
        [settings synchronize];
        return uuidString;
    }
}

-(void)saveMsgCache:(NSString *)msg andUID:(int)uid
{
    if (self.msgs == nil) {
        self.msgs = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    if (msg == nil) 
    {
        [self.msgs removeObjectForKey:[NSString stringWithFormat:@"%d",uid]];
    }
    else
    {
        [self.msgs setObject:msg forKey:[NSString stringWithFormat:@"%d",uid]];
    }
}
-(NSString *)getMsgCache:(int)uid
{
    if (self.msgs != nil) {
        return [self.msgs objectForKey:[NSString stringWithFormat:@"%d", uid]];
    }
    else
        return @"";
}

-(void)saveCommentCache:(NSString *)comment andCommentID:(int)commentID
{
    if (self.comments == nil) {
        self.comments = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    if (comment == nil) {
        [self.comments removeObjectForKey:[NSString stringWithFormat:@"%d",commentID]];
    }
    else
    {
        [self.comments setObject:comment forKey:[NSString stringWithFormat:@"%d", commentID]];
    }
    
}
-(NSString *)getCommentCache:(int)commentID
{
    if (self.comments != nil) {
        return [self.comments objectForKey:[NSString stringWithFormat:@"%d", commentID]];
    }
    else
        return @"";
}

-(void)saveReplyCache:(NSString *)reply andCommentID:(int)commentID andReplyID:(int)replyID
{
    if (self.replies == nil) {
        self.replies = [[NSMutableDictionary alloc]initWithCapacity:3];
    }
    if (reply == nil) {
        [self.replies removeObjectForKey:[NSString stringWithFormat:@"%d_%d",commentID, replyID]];
    }
    else
    {
        [self.replies setObject:reply forKey:[NSString stringWithFormat:@"%d_%d",commentID, replyID]];
    }
}
-(NSString *)getReplyCache:(int)commentID andReplyID:(int)replyID
{
    if (self.replies != nil) {
        return [self.replies objectForKey:[NSString stringWithFormat:@"%d_%d",commentID, replyID]];
    }
    else
        return @"";
}    

static Config * instance = nil;
+(Config *) Instance
{
    @synchronized(self)
    {
        if(nil == instance)
        {
            [self new];
        }
    }
    return instance;
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}
@end
