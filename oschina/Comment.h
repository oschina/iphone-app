//
//  Comment.h
//  oschina
//
//  Created by wangjun on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"
@class Tool;

@interface Comment : NSObject

@property int _id;
@property (retain,nonatomic) NSString * img;
@property (retain,nonatomic) UIImage * imgData;
@property (retain,nonatomic) NSString * author;
@property int authorid;
@property (retain,nonatomic) NSString * content;
@property (retain,nonatomic) NSString * pubDate;
@property (retain,nonatomic) NSMutableArray * replies;
@property (retain,nonatomic) NSMutableArray * refers;
@property int appClient;
@property int catalog;
@property int parentID;
@property int height;
@property int height_reference;
@property float width_bubble;

- (id)initWithParameters:(int)nid andImg:(NSString *)nimg andAuthor:(NSString *)nauthor andAuthorID:(int)nauthorid andContent:(NSString *)nContent andPubDate:(NSString *)nPubDate andReplies:(NSMutableArray *)array andRefers:(NSMutableArray *)nrefers andAppClient:(int)nappclient;

@end
