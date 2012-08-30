//
//  ChatPopView.h
//  oschina
//
//  Created by wangjun on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum tagPopDirection
{
    ePopDirectionLeft = 0,
    ePopDirectionRight,
} ePopDirection;

@interface ChatPopView : UIView

@property (nonatomic,retain) UIImageView * popBackground;
@property (nonatomic,retain) UILabel * contentLabel;
@property (assign) ePopDirection direction;

- (id) initWithFrame:(CGRect)frame popDirection:(ePopDirection)d;
- (void)setText:(NSString *)str;


@end
