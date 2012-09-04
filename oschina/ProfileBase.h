//
//  ProfileBase.h
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageView.h"
#import "ActivesView.h"
#import "PubMessage.h"
#import "OSAppDelegate.h"
#import "OSCNotice.h"

@interface ProfileBase : UIViewController<UIActionSheetDelegate>
{
    int nextTabIndexByNotice;
}

@property (strong, nonatomic) UISegmentedControl * segment_Title;
@property (strong, nonatomic) MessageView * msgView;
@property (strong, nonatomic) ActivesView * activesView;
@property (retain, nonatomic) NSArray * titles;

- (NSString *)getSegmentTitle;

@property BOOL isLoginJustNow;

- (void)myInit;
- (void)clearOSCNotice:(int)type;
- (void)segmentAction:(id)sender;

@end
