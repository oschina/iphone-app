//
//  Activity.m
//  oschina
//
//  Created by wangjun on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Activity.h"

@implementation Activity
@synthesize _id;
@synthesize imgData;
@synthesize img;
@synthesize author;
@synthesize authorid;
@synthesize catalog;
@synthesize objectid;
@synthesize message;
@synthesize fromNowOn;
@synthesize commentCount;
@synthesize objectCatalog;
@synthesize objectTitle;
@synthesize objectType;
@synthesize result;
@synthesize height;
@synthesize isGetHeight;
@synthesize reply;
@synthesize imgTweetData;
@synthesize imgTweet;
@synthesize url;

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
                  andUrl:(NSString *)nurl
{
    Activity *a = [[Activity alloc] init];
    a._id = newid;
    a.img = nimg;
    a.author = nauthor;
    a.authorid = nauthorid;
    a.catalog = ncatalog;
    a.objectid = nobjectid;
    a.message = nmsg;
    a.fromNowOn = pubDate;
    a.commentCount = ncommentCount;
    a.objectCatalog = nobjectCatalog;
    a.objectTitle = nObjectTitle;
    a.objectType = nobjectType;
    a.reply = nreply;
    a.result = [Tool getTextViewString2:a.author andObjectType:a.objectType andObjectCatalog:a.objectCatalog andObjectTitle:a.objectTitle andMessage:a.message andPubDate:a.fromNowOn andReply:a.reply];
    RTLabel *lbl = [RTActiveCell textLabel];
    lbl.text = a.result;
    a.height = [lbl optimumSize].height;
    a.imgTweet = nimgTweet;
    a.url = nurl;
    return a;
}
@end
