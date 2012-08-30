//
//  Blog.m
//  oschina
//
//  Created by wangjun on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Blog.h"

@implementation Blog

@synthesize _id;
@synthesize title;
@synthesize where;
@synthesize body;
@synthesize author;
@synthesize authorid;
@synthesize documentType;
@synthesize pubDate;
@synthesize favorite;
@synthesize url;
@synthesize commentCount;

- (id)initWithParameters:(int)nid 
                andTitle:(NSString *)ntitle 
                andWhere:(NSString *)nwhere 
                andBody:(NSString *)nbody 
                andAuthor:(NSString *)nauthor 
                andAuthorid:(int)nauthorid 
                andDocumentType:(int)nDocumentType 
                andPubDate:(NSString *)nPubDate 
                andFavorite:(BOOL)nfavorite 
                andUrl:(NSString *)nurl 
                andCommentCount:(int)ncommentCount
{
    Blog * b = [[Blog alloc] init];
    b._id = nid;
    b.title = ntitle;
    b.where = nwhere;
    b.body = nbody;
    b.author = nauthor;
    b.authorid = nauthorid;
    b.documentType = nDocumentType;
    b.pubDate = nPubDate;
    b.favorite = nfavorite;
    b.url = nurl;
    b.commentCount = ncommentCount;
    return b;
}

@end
