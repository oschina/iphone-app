//
//  News.m
//  oschina
//
//  Created by wangjun on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "News.h"

@implementation News

@synthesize _id;
@synthesize title;
@synthesize url;
@synthesize author;
@synthesize authorid;
@synthesize pubDate;
@synthesize commentCount;
@synthesize newsType;
@synthesize attachment;
@synthesize authoruid2;

- (id)initWithParameters:(int)newID 
                andTitle:(NSString *)newTitle 
                andUrl:(NSString *)newUrl 
                andAuthor:(NSString *)nAuthor 
                andAuthorID:(int)nauthorID 
                andPubDate:(NSString *)nPubDate 
                andCommentCount:(int)nCommentCount
{
    News *n = [[News alloc] init];
    n._id = newID;
    n.title = newTitle;
    n.url = newUrl;
    n.author = nAuthor;
    n.authorid = nauthorID;
    n.pubDate = nPubDate;
    n.commentCount = nCommentCount;
    return n;
}

@end
