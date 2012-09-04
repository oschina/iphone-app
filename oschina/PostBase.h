//
//  PostBase.h
//  oschina
//
//  Created by wangjun on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostPubView.h"
#import "PostsView.h"

@interface PostBase : UIViewController<UIActionSheetDelegate>

@property (strong,nonatomic) UISegmentedControl * segment_title;
@property (strong,nonatomic) PostsView * postsView;

- (NSString *)getSegmentTitle;
- (void)myInit;

@end
