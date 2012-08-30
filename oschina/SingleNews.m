//
//  SingleNews.m
//  oschina
//
//  Created by wangjun on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SingleNews.h"

@implementation SingleNews

@synthesize _id;
@synthesize title;
@synthesize url;
@synthesize body;
@synthesize author;
@synthesize authorid;
@synthesize pubDate;
@synthesize commentCount;
@synthesize relativies;
@synthesize softwarelink;
@synthesize softwarename;
@synthesize favorite;

- (id)initWithParameters:(int)newid 
                andTitle:(NSString *)ntitle 
                andUrl:(NSString *)newUrl 
                andBody:(NSString *)newBody 
                andAuthor:(NSString *)newAuthor 
                andAuthorID:(int)nauthorID 
                andPubDate:(NSString *)nPubDate 
                andCommentCount:(int)nCommentCount 
                andFavorite:(BOOL)nfavorite
{
    SingleNews *news = [[SingleNews alloc] init];
    news._id = newid;
    news.title = ntitle;
    news.url = newUrl;
    news.body = newBody;
    news.author = newAuthor;
    news.authorid = nauthorID;
    news.pubDate = nPubDate;
    news.commentCount = nCommentCount;
    news.favorite = nfavorite;
    return news;
}

@end
