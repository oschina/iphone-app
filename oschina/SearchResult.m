//
//  SearchResult.m
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

@synthesize objid;
@synthesize type;
@synthesize title;
@synthesize url;
@synthesize pubDate;
@synthesize author;

- (id)initWithParameters:(int)nobjid 
                 andType:(int)ntype 
                 andTitle:(NSString *)ntitle 
                 andUrl:(NSString *)nurl 
                 andPubDate:(NSString *)nPubDate 
                 andAuthor:(NSString *)nauthor
{
    SearchResult * result = [[SearchResult alloc] init];
    result.objid = nobjid;
    result.type = ntype;
    result.title = ntitle;
    result.url = nurl;
    result.pubDate = nPubDate;
    result.author = nauthor;
    return result;
}

@end
