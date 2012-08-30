//
//  BlogUnit.h
//  oschina
//
//  Created by wangjun on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlogUnit : NSObject

@property int _id;
@property (copy,nonatomic) NSString * url;
@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * pubDate;
@property (copy,nonatomic) NSString * authorName;
@property int authorUID;
@property int commentCount;
@property int documentType;

- (id)initWithParameters:(int)nid 
                  andUrl:(NSString *)nurl 
                  andTitle:(NSString *)ntitle 
                  andPubDate:(NSString *)npubDate 
                  andAuthorName:(NSString *)nauthorName 
                  andAuthorUID:(int)nauthorUID 
                  andCommentCount:(int)nCommentCount 
                  andDocumentType:(int)nDocumentType;

@end
