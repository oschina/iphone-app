//
//  SinglePostDetail.h
//  oschina
//
//  Created by wangjun on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinglePostDetail : NSObject

@property int _id;
@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * url;
@property (copy,nonatomic) NSString * portrait;
@property (copy,nonatomic) NSString * body;
@property (copy,nonatomic) NSString * author;
@property int authorid;
@property (copy,nonatomic) NSString * pubDate;
@property int answerCount;
@property int viewCount;
@property BOOL favorite;
@property (retain,nonatomic) NSMutableArray * tags;

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
                andTags:(NSMutableArray *)_tags;

@end
