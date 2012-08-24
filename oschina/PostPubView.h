//
//  PostPubView.h
//  oschina
//
//  Created by wangjun on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"

@interface PostPubView : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentCatalog;
@property (strong, nonatomic) IBOutlet UITextView *txtContent;
@property (strong, nonatomic) IBOutlet UISwitch *switchNotice;
- (IBAction)clickPub:(id)sender;
- (IBAction)txtTitleExit:(id)sender;
- (IBAction)backgroundTouchDown:(id)sender;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)isNoticeMeChanged:(id)sender;
- (IBAction)textChanged:(id)sender;

@end
