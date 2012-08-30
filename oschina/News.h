//
//  News.h
//  oschina
//
//  Created by wangjun on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject

@property int _id;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) NSString * author;
@property int authorid;
@property (nonatomic,copy) NSString * pubDate;
@property int commentCount;
@property int newsType;
@property (nonatomic,copy) NSString * attachment;
@property int authoruid2;

- (id)initWithParameters:(int)newID 
                andTitle:(NSString *)newTitle 
                andUrl:(NSString *)newUrl 
                andAuthor:(NSString *)nAuthor 
                andAuthorID:(int)authorID 
                andPubDate:(NSString *)nPubDate 
                andCommentCount:(int)nCommentCount;

@end
