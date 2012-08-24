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
@property (retain,nonatomic) NSString * title;
@property (retain,nonatomic) NSString * url;
@property (retain,nonatomic) NSString * body;
@property (retain,nonatomic) NSString * author;
@property int authorid;
@property (retain,nonatomic) NSString * pubDate;
@property int commentCount;
@property (retain,nonatomic) NSArray * relativies;
@property (retain,nonatomic) NSString * softwarelink;
@property (retain,nonatomic) NSString * softwarename;
@property BOOL favorite;

- (id)initWithParameters:(int)newid andTitle:(NSString *)ntitle andUrl:(NSString *)newUrl andBody:(NSString *)newBody andAuthor:(NSString *)newAuthor andAuthorID:(int)nauthorID andPubDate:(NSString *)nPubDate andCommentCount:(int)nCommentCount andFavorite:(BOOL)nfavorite;

@end
