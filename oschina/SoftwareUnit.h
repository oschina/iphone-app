//
//  SoftwareUnit.h
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoftwareUnit : NSObject

@property (copy,nonatomic) NSString * name;
@property (copy,nonatomic) NSString * description;
@property (copy,nonatomic) NSString * url;

- (id)initWithParameters:(NSString *)newName andDescription:(NSString *)newDescription andUrl:(NSString *)newUrl;

@end
