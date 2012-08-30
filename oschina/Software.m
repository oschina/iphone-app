//
//  Software.m
//  oschina
//
//  Created by wangjun on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Software.h"

@implementation Software

@synthesize _id;
@synthesize title;
@synthesize extensionTitle;
@synthesize license;
@synthesize body;
@synthesize homePage;
@synthesize document;
@synthesize download;
@synthesize logo;
@synthesize language;
@synthesize os;
@synthesize recordTime;
@synthesize favorite;

- (id)initWithParemters:(int)nid 
               andTitle:(NSString *)ntitle 
               andExtension:(NSString *)nExtensionTitle 
               andLicense:(NSString *)nlicense 
               andBody:(NSString *)nbody 
               andHomepage:(NSString *)nhomepage 
               andDocument:(NSString *)ndocument 
               andDownload:(NSString *)ndownload 
               andLogo:(NSString *)nlogo 
               andLanguage:(NSString *)nlanguage 
               andOS:(NSString *)nos 
               andRecordTime:(NSString *)nrecordTime
               andFavorite:(BOOL)nfavorite
{
    Software *s = [[Software alloc] init];
    s._id = nid;
    s.title = ntitle;
    s.extensionTitle = nExtensionTitle;
    s.license = nlicense;
    s.body = nbody;
    s.homePage = nhomepage;
    s.document = ndocument;
    s.download = ndownload;
    s.logo = nlogo;
    s.language = nlanguage;
    s.os = nos;
    s.recordTime = nrecordTime;
    s.favorite = nfavorite;
    
    return s;
}

@end
