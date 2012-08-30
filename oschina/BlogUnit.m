//
//  BlogUnit.m
//  oschina
//
//  Created by wangjun on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BlogUnit.h"

@implementation BlogUnit

@synthesize _id;
@synthesize url;
@synthesize title;
@synthesize pubDate;
@synthesize authorUID;
@synthesize authorName;
@synthesize commentCount;
@synthesize documentType;

- (id)initWithParameters:(int)nid 
                  andUrl:(NSString *)nurl 
                  andTitle:(NSString *)ntitle 
                  andPubDate:(NSString *)npubDate 
                  andAuthorName:(NSString *)nauthorName 
                  andAuthorUID:(int)nauthorUID 
                  andCommentCount:(int)nCommentCount 
                  andDocumentType:(int)nDocumentType
{
    BlogUnit *b = [[BlogUnit alloc] init];
    b._id = nid;
    b.url = nurl;
    b.title = ntitle;
    b.pubDate = npubDate;
    b.authorName = nauthorName;
    b.authorUID = nauthorUID;
    b.commentCount = nCommentCount;
    b.documentType = nDocumentType;
    return b;
}

@end
