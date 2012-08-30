//
//  Software.h
//  oschina
//
//  Created by wangjun on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Software : NSObject

@property int _id;
@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * extensionTitle;
@property (copy,nonatomic) NSString * license;
@property (copy,nonatomic) NSString * body;
@property (copy,nonatomic) NSString * homePage;
@property (copy,nonatomic) NSString * document;
@property (copy,nonatomic) NSString * download;
@property (copy,nonatomic) NSString * logo;
@property (copy,nonatomic) NSString * language;
@property (copy,nonatomic) NSString * os;
@property (copy,nonatomic) NSString * recordTime;
@property BOOL favorite;

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
               andFavorite:(BOOL)nfavorite;

@end
