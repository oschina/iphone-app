//
//  ReplyMsgView.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "MessageSystemView.h"
#import "Comment.h"
@class MessageSystemView;

@interface ReplyMsgView : UIViewController<UIActionSheetDelegate,UIWebViewDelegate,UITextViewDelegate>
{
    NSString * commentBeforeLogin;
}
- (IBAction)clickBackground:(id)sender;

- (IBAction)clickReply:(id)sender;

@property (retain,nonatomic) NSString * lblTitle;
@property (retain,nonatomic) NSString * btnTitle;


@property (strong, nonatomic) MessageSystemView * parent;
@property (strong, nonatomic) IBOutlet UIWebView *webViewReply;
@property (retain, nonatomic) Comment * parentComment;
- (IBAction)clickDidOnExit:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *txtReply;

@property int parentCommentID;
@property int catalog;
@property int replyID;
@property int authorID;
@end
