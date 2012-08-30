//
//  Friend.h
//  oschina
//
//  Created by wangjun on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject

@property (copy,nonatomic) NSString * name;
@property int userID;
@property (copy,nonatomic) NSString * portrait;
@property (copy,nonatomic) NSString * expertise;
@property BOOL isMale;
@property (retain,nonatomic) UIImage * imgData;

- (id)initWithParameters:(NSString *)newName 
                  andUID:(int)newUID 
                  andPortrait:(NSString *)nportrait 
                  andExpertise:(NSString *)nexpertise 
                  andMale:(BOOL)nisMale;
@end
