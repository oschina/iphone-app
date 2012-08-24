//
//  SearchResult.h
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property int objid;
@property int type;
@property (nonatomic,retain) NSString * title;
@property (nonatomic,retain) NSString * url;
@property (retain,nonatomic) NSString * pubDate;
@property (retain,nonatomic) NSString * author;

- (id)initWithParameters:(int)nobjid andType:(int)ntype andTitle:(NSString *)ntitle andUrl:(NSString *)nurl andPubDate:(NSString *)nPubDate andAuthor:(NSString *)nauthor;

@end
