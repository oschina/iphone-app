//
//  MsgCell.m
//  oschina
//
//  Created by wangjun on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MsgCell.h"

@implementation MsgCell
@synthesize img;
@synthesize lbl_Title;
@synthesize delegate;
@synthesize txt_Content;
@synthesize myView;
@synthesize referView;

-(void)viewDidUnload
{
    img = nil;
    lbl_Title = nil;
}

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
    //    if (action == @selector(cut:))
    //    {  
    //        return NO;  
    //    }   
    //    else if(action == @selector(copy:))
    //    {  
    //        return NO;  
    //    }   
    //    else if(action == @selector(paste:))
    //    {  
    //        return NO;  
    //    }   
    //    else if(action == @selector(select:))
    //    {  
    //        return NO;  
    //    }   
    //    else if(action == @selector(selectAll:))
    //    {  
    //        return NO;  
    //    } 
    //    else 
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
