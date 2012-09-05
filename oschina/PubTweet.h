//
//  PubTweet.h
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "ApiError.h"
#import <QuartzCore/QuartzCore.h>
#import "TwitterView.h"
#import "MyThread.h"
#import "MBProgressHUD.h"
#import "TSEmojiView.h"

@interface PubTweet : UIViewController<UIImagePickerControllerDelegate,MBProgressHUDDelegate,UITextViewDelegate,TSEmojiViewDelegate>
{
    //加载指示
    MBProgressHUD * hud;

    //表情
    TSEmojiView * _emojiView;
    UIScrollView * scroll;
}

@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) TwitterView * parent;
@property (strong, nonatomic) IBOutlet UILabel *lblHeadTip;
@property (strong, nonatomic) IBOutlet UITextView *txtContent;
@property BOOL isSourceUser;
@property (strong, nonatomic) IBOutlet UILabel *lblStringlength;
@property (copy, nonatomic) NSString * atSomebody;

- (IBAction)click_PubTweet:(id)sender;
- (IBAction)clickBackground:(id)sender;
- (IBAction)txtDidOnExit:(id)sender;
- (IBAction)clickImgs:(id)sender;
- (IBAction)clickFace:(id)sender;

@end
