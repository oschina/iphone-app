//
//  SinglePostDetail.m
//  oschina
//
//  Created by wangjun on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinglePostDetail.h"

@implementation SinglePostDetail

@synthesize _id;
@synthesize title;
@synthesize portrait;
@synthesize body;
@synthesize author;
@synthesize authorid;
@synthesize pubDate;
@synthesize answerCount;
@synthesize viewCount;
@synthesize url;
@synthesize favorite;
@synthesize tags;

- (id)initWithParameters:(int)newid 
                andTitle:(NSString *)ntitle 
                andUrl:(NSString *)nUrl 
                andPortrait:(NSString *)nportrait 
                andBody:(NSString *)nbody 
                andAuthor:(NSString *)nauthor 
                andAuthorID:(int)nauthorid 
                andPubDate:(NSString *)nPubDate 
                andAnswer:(int)nanswerCount 
                andView:(int)nviewCount 
                andFavorite:(BOOL)nfavorite 
                andTags:(NSMutableArray *)_tags
{
    SinglePostDetail *p = [[SinglePostDetail alloc] init];
    p._id = newid;
    p.title = ntitle;
    p.url = nUrl;
    p.portrait = nportrait;
    p.body = nbody;
    p.author = nauthor;
    p.authorid = nauthorid;
    p.pubDate = nPubDate;
    p.answerCount = nanswerCount;
    p.viewCount = nviewCount;
    p.favorite = nfavorite;
    p.tags = _tags;
    return p;
}

@end
