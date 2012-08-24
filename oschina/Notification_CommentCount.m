//
//  Notification_CommentCount.m
//  oschina
//
//  Created by wangjun on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Notification_CommentCount.h"

@implementation Notification_CommentCount

@synthesize attachment;
@synthesize commentCount;

- (id)initWithParameters:(id)nattachment andCommentCount:(int)ncommentCount
{
    Notification_CommentCount *notification = [[Notification_CommentCount alloc] init];
    notification.attachment = nattachment;
    notification.commentCount = ncommentCount;
    return notification;
}

@end
