//
//  SingleNews.h
//  oschina
//
//  Created by wangjun on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleNews : NSObject

@property int _id;
@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * url;
@property (copy,nonatomic) NSString * body;
@property (copy,nonatomic) NSString * author;
@property int authorid;
@property (copy,nonatomic) NSString * pubDate;
@property int commentCount;
@property (retain,nonatomic) NSArray * relativies;
@property (copy,nonatomic) NSString * softwarelink;
@property (copy,nonatomic) NSString * softwarename;
@property BOOL favorite;

- (id)initWithParameters:(int)newid 
                andTitle:(NSString *)ntitle 
                andUrl:(NSString *)newUrl 
                andBody:(NSString *)newBody 
                andAuthor:(NSString *)newAuthor 
                andAuthorID:(int)nauthorID 
                andPubDate:(NSString *)nPubDate 
                andCommentCount:(int)nCommentCount 
                andFavorite:(BOOL)nfavorite;

@end
