//
//  Message.h
//  oschina
//
//  Created by wangjun on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Message : NSObject

@property int _id;
@property (copy,nonatomic) NSString * sender;
@property int senderID;
@property (copy,nonatomic) NSString * content;
@property (copy,nonatomic) NSString * fromNowOn;
@property (retain,nonatomic) UIImage * imgData;
@property (copy,nonatomic) NSString * img;
@property int friendid;
@property (copy,nonatomic) NSString * friendName;
@property BOOL isEnableDel;
@property int count;
@property int height;

- (id)initWithParameter:(int)newID 
              andSender:(NSString *)sender 
              andSenderID:(int)nsenderID 
              andContent:(NSString *)newContent 
              andFromNowOn:(NSString *)time 
              andImg:(NSString *)nImg 
              andFriendid:(int)nfriendid 
              andFriendName:(NSString *)nfriendName 
              andCount:(int)nCount;

@end
