//
//  PubMessage.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "ApiError.h"
#import "Config.h"

@interface PubMessage : UIViewController<UITextViewDelegate>

- (IBAction)clickPubMessage:(id)sender;
- (IBAction)clickbackground:(id)sender;
//接受者
@property (nonatomic,copy) NSString * receiver;
@property int receiverid;
@property BOOL isFromUserView;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Receiver;
- (IBAction)clickDidOnExit:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *txtContent;

@end
