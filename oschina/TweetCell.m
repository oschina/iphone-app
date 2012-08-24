//
//  TweetCell.m
//  oschina
//
//  Created by wangjun on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell
@synthesize img;
@synthesize txt_Message;
@synthesize lbl_Time;
@synthesize lbl_Author;
@synthesize lblCommentCount;
@synthesize imgTweet;
@synthesize delegate;

-(void)initGR
{
    UILongPressGestureRecognizer *longPressGR = [[ UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGR.minimumPressDuration = 0.7;
    [self addGestureRecognizer:longPressGR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if([self isHighlighted])
    {
        [[self delegate] performSelector:@selector(showMenu:) withObject:self];
    }
}
- (void)delete:(id)sender 
{  
    [[self delegate]  performSelector:@selector(deleteRow:) withObject:self];
} 
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(delete:))
    {  
        return YES;  
    }
    else   
    {  
        return [super canPerformAction:action withSender:sender];  
    }  
}
@end
