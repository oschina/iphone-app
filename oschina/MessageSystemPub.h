//
//  MessageSystemPub.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiError.h"
#import "MessageSystemView.h"

@interface MessageSystemPub : UIViewController<UIActionSheetDelegate,UITextViewDelegate>
{
    NSString * commentBeforeLogin;
}

- (IBAction)clickComment:(id)sender;
- (IBAction)backgroundDown:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblState1;
@property (strong, nonatomic) IBOutlet UISwitch *switchRepost;
@property (strong,nonatomic) MessageSystemView * parent;
@property (retain,nonatomic) NSString * btnPubTitle;
- (IBAction)changeIsPostToMyZone:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lbl_HeadTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtContent;

@property int catalog;
@property int parentID;

@property BOOL isListIn;
- (IBAction)clickDidOnExit:(id)sender;

@end
