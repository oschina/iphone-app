//
//  UITap.h
//  oschina
//
//  Created by wangjun on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITap : UITapGestureRecognizer

@property int tag;
@property (nonatomic,copy) NSString * tagString; 

@end
