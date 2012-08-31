//
//  MyThread.m
//  oschina
//
//  Created by wangjun on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyThread.h"

@implementation MyThread
@synthesize mainView;

-(void)startNotice
{
    if (isRunning) {
        return;
    }
    else {
        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        isRunning = YES;
    }
}
-(void)startPubTweet:(NSString *)msg andImg:(NSData *)imgData
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:api_tweet_pub]];
    [request setUseCookiePersistence:[Config Instance].isCookie];
    [request setPostValue:[NSString stringWithFormat:@"%d", [Config Instance].getUID] forKey:@"uid"];
    [request setPostValue:msg forKey:@"msg"];
    [request addData:imgData withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"img"];
    [request setDelegate:self];
    request.tag = 10;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestPub:)];
    [request startAsynchronous];
}
- (void)startUpdatePortrait:(NSData *)imgData
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:api_userinfo_update]];
    [request setUseCookiePersistence:[Config Instance].isCookie];
    [request setPostValue:[NSString stringWithFormat:@"%d",[Config Instance].getUID] forKey:@"uid"];
    [request addData:imgData withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"portrait"];
    request.delegate = self;
    request.tag = 11;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestPortrait:)];
    [request startAsynchronous];
}

-(void)timerUpdate
{
    NSString * url = [NSString stringWithFormat:@"%@?uid=%d",api_user_notice,[Config Instance].getUID];
    
    [[AFOSCClient sharedClient]getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Tool getOSCNotice2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    //如果发送tweet失败
    if (request.tag == 10) {
        NSLog(@"后台发送动弹图片  网络失败");
    }
}
- (void)requestPub:(ASIHTTPRequest *)request
{
    [Tool getOSCNotice:request];
    if (request.hud) {
        [request.hud hide:YES];
    }
    ApiError *error = [Tool getApiError:request];
    switch (error.errorCode) {
        case 1:
        {
            NSLog(@"后台发送动弹图片  成功");
            [Config Instance].tweet = nil;
            [Config Instance].tweetCachePic = nil;
            UIView *v = [UIApplication sharedApplication].keyWindow;
            [Tool ToastNotification:@"动弹后台发布成功" andView:v andLoading:NO andIsBottom:YES];
        }
            break;
        case 0:
        case -2:
        case -1:
        {
            NSLog(@"后台发送动弹图片  失败  %@ %d",error.errorMessage, error.errorCode);
        }
            break;
    }
}
- (void)requestPortrait:(ASIHTTPRequest *)request
{
    [Tool getOSCNotice:request];
    if (request.hud) {
        [request.hud hide:YES];
    }
    ApiError *error = [Tool getApiError:request];
    switch (error.errorCode) {
        case 1:
        {
            NSLog(@"更新头像成功");
            UIView *v = [UIApplication sharedApplication].keyWindow;
            [Tool ToastNotification:@"成功更新您的头像" andView:v andLoading:NO andIsBottom:YES];
            //重新获取自我头像
        }
            break;
        case 0:
        case -2:
        case -1:
        {
            NSLog(@"后台发送动弹图片  失败  %@ %d",error.errorMessage, error.errorCode);
        }
            break;
    }
}


static MyThread * instance = nil;
+(MyThread *) Instance
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
