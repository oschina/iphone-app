//
//  Tweet.m
//  oschina
//
//  Created by wangjun on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

@synthesize _id;
@synthesize tweet;
@synthesize author;
@synthesize authorID;
@synthesize fromNowOn;
@synthesize img;
@synthesize imgData;
@synthesize commentCount;
@synthesize imgTweet;
@synthesize imgTweetData;
@synthesize imgBig;
@synthesize appClient;
@synthesize height;

- (id)initWidthParameters:(int)newid 
                andAuthor:(NSString *)newAuthor 
                andAuthorID:(int)newAuthorID 
                andTweet:(NSString *)newTweet 
                andFromNowOn:(NSString *)newFromNowOn 
                andImg:(NSString *)newImg 
                andCommentCount:(int)newCommentCount 
                andImgTweet:(NSString *)nimgTweet 
                andImgBig:(NSString *)nimgBig 
                andAppClient:(int)nappClient
{
    Tweet *t = [[Tweet alloc] init];
    t._id = newid;
    t.author = newAuthor;
    t.authorID = newAuthorID;
    t.tweet = newTweet;
    t.fromNowOn = newFromNowOn;
    t.img = newImg;
    t.commentCount = newCommentCount;
    t.imgTweet = nimgTweet;
    t.imgBig = nimgBig;
    t.appClient = nappClient;
    UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(157, 178, 236, 331)];
    t.height = [Tool getTextViewHeight:txt andUIFont:[UIFont fontWithName:@"arial" size:14.0f] andText:t.tweet];
    return t;
}

@end
