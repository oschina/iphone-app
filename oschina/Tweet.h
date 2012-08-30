//
//  Tweet.h
//  oschina
//
//  Created by wangjun on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"

@interface Tweet : NSObject

@property int _id;
@property (nonatomic,copy) NSString * author;
@property int authorID;
@property (nonatomic,copy) NSString * tweet;
@property (nonatomic,copy) NSString * fromNowOn;
@property (nonatomic,copy) NSString * img;
@property (nonatomic,retain) UIImage * imgData;
@property int commentCount;
@property (nonatomic,copy) NSString * imgTweet;
@property (nonatomic,retain) UIImage * imgTweetData;
@property (nonatomic,copy) NSString * imgBig;
@property int appClient;
@property int height;

- (id)initWidthParameters:(int)newid 
                andAuthor:(NSString *)newAuhtor 
                andAuthorID:(int)newAuthorID 
                andTweet:(NSString *)newTweet 
                andFromNowOn:(NSString *)newFromNowOn 
                andImg:(NSString *)img
                andCommentCount:(int)newCommentCount 
                andImgTweet:(NSString *)nimgTweet 
                andImgBig:(NSString *)nimgBig 
                andAppClient:(int)nappClient;

@end
