//
//  ChatPopView.m
//  oschina
//
//  Created by wangjun on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatPopView.h"

@implementation ChatPopView
@synthesize popBackground;
@synthesize contentLabel;
@synthesize direction;

- (id)initWithFrame:(CGRect)frame popDirection:(ePopDirection)d
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.direction = d;
        
        UIImageView * back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.popBackground = back;
        
        UIImage *theImage = nil;
        if (ePopDirectionRight == self.direction) {
            theImage = [UIImage imageNamed:@"bubbleMine"];
        }
        else
        {
            theImage = [UIImage imageNamed:@"bubbleSomeone"];
        }
        
        popBackground.image = [theImage stretchableImageWithLeftCapWidth:21 topCapHeight:15];
        [self addSubview:popBackground];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake( d == ePopDirectionLeft?17:10, 5, frame.size.width-15, frame.size.height)];
        self.contentLabel = content;
        contentLabel.font = [UIFont fontWithName:@"Arial" size:14];
        contentLabel.numberOfLines = 0;
        contentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:contentLabel];
    }
    return self;
}

- (void)setText:(NSString *)str
{
    contentLabel.text = str;
    [contentLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentLabel.frame.size.width+30, contentLabel.frame.size.height + 15);
    popBackground.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}


@end
