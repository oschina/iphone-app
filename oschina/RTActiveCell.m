//
//  RTActiveCell.m
//  oschina
//
//  Created by wangjun on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RTActiveCell.h"

@implementation RTActiveCell
@synthesize imgPortrait;
@synthesize imgTweet;
@synthesize rtLabel;

- (void)initialize
{
    self.rtLabel = [RTActiveCell textLabel];
    [self.rtLabel setLineSpacing:18];
    [self.contentView addSubview:self.rtLabel];
    [self.rtLabel setBackgroundColor:[UIColor clearColor]];
    self.imgPortrait.placeholderImage = [UIImage imageNamed:@"avatar_loading.jpg"];
    self.imgTweet.placeholderImage = [UIImage imageNamed:@"tweetloading.jpg"];
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize optimumSize = [self.rtLabel optimumSize];
	CGRect frame = [self.rtLabel frame];
	frame.size.height = (int)optimumSize.height+5; // +5 to fix height issue, this should be automatically fixed in iOS5
	[self.rtLabel setFrame:frame];
}
+ (RTLabel*)textLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(50,8,250,100)];
    [label setParagraphReplacement:@""];
    return label;
}

@end
