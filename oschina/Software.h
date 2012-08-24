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
@property (retain,nonatomic) NSString * title;
@property (retain,nonatomic) NSString * extensionTitle;
@property (retain,nonatomic) NSString * license;
@property (retain,nonatomic) NSString * body;
@property (retain,nonatomic) NSString * homePage;
@property (retain,nonatomic) NSString * document;
@property (retain,nonatomic) NSString * download;
@property (retain,nonatomic) NSString * logo;
@property (retain,nonatomic) NSString * language;
@property (retain,nonatomic) NSString * os;
@property (retain,nonatomic) NSString * recordTime;
@property BOOL favorite;

- (id)initWithParemters:(int)nid andTitle:(NSString *)ntitle andExtension:(NSString *)nExtensionTitle andLicense:(NSString *)nlicense andBody:(NSString *)nbody andHomepage:(NSString *)nhomepage andDocument:(NSString *)ndocument andDownload:(NSString *)ndownload andLogo:(NSString *)nlogo andLanguage:(NSString *)nlanguage andOS:(NSString *)nos andRecordTime:(NSString *)nrecordTime andFavorite:(BOOL)nfavorite;

@end
