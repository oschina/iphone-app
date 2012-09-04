//
//  Comment.m
//  oschina
//
//  Created by wangjun on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Comment.h"
#import "Tool.h"

@implementation Comment

@synthesize _id;
@synthesize img;
@synthesize imgData;
@synthesize author;
@synthesize authorid;
@synthesize content;
@synthesize pubDate;
@synthesize replies;
@synthesize catalog;
@synthesize parentID;
@synthesize height;
@synthesize refers;
@synthesize height_reference;
@synthesize appClient;
@synthesize width_bubble;

- (id)initWithParameters:(int)nid 
                  andImg:(NSString *)nimg 
                  andAuthor:(NSString *)nauthor 
                  andAuthorID:(int)nauthorid 
                  andContent:(NSString *)nContent 
                  andPubDate:(NSString *)nPubDate 
                  andReplies:(NSMutableArray *)array 
                  andRefers:(NSMutableArray *)nrefers
                  andAppClient:(int)nappclient
{
    Comment *c = [[Comment alloc] init];
    c._id = nid;
    c.img = nimg;
    c.author = nauthor;
    c.authorid = nauthorid;
    c.content = nContent;
    c.pubDate = nPubDate;
    c.replies = array;
    c.refers = nrefers;
    c.appClient = nappclient;
    c.width_bubble = 0;
    if (nrefers != nil && nrefers.count > 0) {
        UIView * referView = [Tool getReferView:nrefers];
        c.height_reference = referView.frame.size.height + 7;
    }
    else {
        c.height_reference = 0;
    }
    
    UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(170, 474, 260, 922)];
    c.height = [Tool getTextViewHeight:txt andUIFont:[UIFont fontWithName:@"arial" size:14.0] andText:c.content];
    if (c.replies && [c.replies count] > 0 ) {
        c.height += 13+19+[c.replies count]*35;
    }
    else
    {
        c.height += 13;
    }
    
    return c;
}

@end
