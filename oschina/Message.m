//
//  Message.m
//  oschina
//
//  Created by wangjun on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "Tool.h"

@implementation Message
@synthesize _id;
@synthesize sender;
@synthesize senderID;
@synthesize content;
@synthesize fromNowOn;
@synthesize imgData;
@synthesize img;
@synthesize friendid;
@synthesize friendName;
@synthesize count;
@synthesize isEnableDel;
@synthesize height;

- (id)initWithParameter:(int)newID 
              andSender:(NSString *)nsender 
              andSenderID:(int)nsenderID 
              andContent:(NSString *)newContent 
              andFromNowOn:(NSString *)time 
              andImg:(NSString *)nImg 
              andFriendid:(int)nfriendid 
              andFriendName:(NSString *)nfriendName 
              andCount:(int)nCount
{
    Message *m = [Message new];
    m._id = newID;
    m.sender = nsender;
    m.senderID = nsenderID;
    m.content = newContent;
    m.fromNowOn = time;
    m.img = nImg;
    m.friendid = nfriendid;
    m.friendName = nfriendName;
    m.count = nCount;
    
    UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(166, 252, 255, 503)];
    
    m.height = [Tool getTextViewHeight:txt andUIFont:[UIFont fontWithName:@"arial" size:14.0] andText:[NSString stringWithFormat:@"发给%@:\n%@",m.friendName, m.content]];
    
    return m;
}

@end
