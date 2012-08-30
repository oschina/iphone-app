//
//  Activity.h
//  oschina
//
//  Created by wangjun on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"
#import "ObjectReply.h"
#import "FTCoreTextView.h"
#import "RTLabel.h"
#import "RTActiveCell.h"

@interface Activity : NSObject

@property int _id;
@property (copy,nonatomic) NSString * img;
@property (retain,nonatomic) UIImage * imgData;
@property (copy,nonatomic) NSString * author;
@property int authorid;
@property int catalog;
@property int objectid;
@property (copy,nonatomic) NSString * message;
@property (copy,nonatomic) NSString * fromNowOn;
@property int objectType;
@property int objectCatalog;
@property (copy,nonatomic) NSString * objectTitle;
@property int commentCount;
@property (copy,nonatomic) NSString * result;
@property int height;
@property BOOL isGetHeight;
@property (retain,nonatomic) ObjectReply * reply;
@property (nonatomic,retain) UIImage * imgTweetData;
@property (copy,nonatomic) NSString * imgTweet;
@property (copy,nonatomic) NSString * url;

- (id)initWithParameters:(int)newid 
                  andImg:(NSString *)nimg 
                  andAuthor:(NSString *)nauthor 
                  andAuthorID:(int)nauthorid 
                  andCatalog:(int)ncatalog 
                  andObjectid:(int)nobjectid 
                  andMessage:(NSString *)nmsg 
                  andPubDate:(NSString *)pubDate 
                  andCommentCount:(int)ncommentCount 
                  andObjectType:(int)nobjectType 
                  andObjectCatalog:(int)nobjectCatalog 
                  andObjectTitle:(NSString *)nObjectTitle 
                  andForUserView:(BOOL)isUserView 
                  andReply:(ObjectReply *)nreply 
                  andImgTweet:(NSString *)nimgTweet 
                  andUrl:(NSString *)nurl;

@end
