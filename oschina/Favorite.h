//
//  Favorite.h
//  oschina
//
//  Created by wangjun on 12-5-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property int objid;
@property int type;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * url;

- (id)initWithParameters:(int)nobjid andType:(int)nType andTitle:(NSString *)ntitle andUrl:(NSString *)nurl;

@end
