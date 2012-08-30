//
//  SoftwareCatalog.h
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoftwareCatalog : NSObject

@property (nonatomic,copy) NSString * name;
@property int tag;

- (id)initWithParameters:(NSString *)newName andTag:(int)nTag;

@end
