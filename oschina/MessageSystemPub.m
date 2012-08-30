
//  MessageSystemPub.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageSystemPub.h"

@implementation MessageSystemPub
@synthesize lblState1;
@synthesize switchRepost;
@synthesize parent;
@synthesize btnPubTitle;
@synthesize lbl_HeadTitle;
@synthesize txtContent;
@synthesize catalog;
@synthesize parentID;
@synthesize isListIn;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Tool roundTextView:txtContent];
    //显示正确的按钮字符
    //如果父级别是 问答 则改成我要回帖
    if (self.catalog == 2) {
        self.lbl_HeadTitle.text = @"我要回帖";
    }
    
    //如果不需要显示
    if (parent.isDisplayRepostToMyZone) {
        self.switchRepost.hidden = NO;
        self.lblState1.hidden = NO;
        //决定开关
        [self.switchRepost setOn:[Config Instance].getIsPostToMyZone];
    }
    else
    {
        self.switchRepost.hidden = YES;
        self.lblState1.hidden = YES;
    }
    
    UIBarButtonItem *_btnPub = [[UIBarButtonItem alloc] initWithTitle:@"立即发表" style:UIBarButtonItemStyleBordered target:self action:@selector(clickComment:)];
    self.navigationItem.rightBarButtonItem = _btnPub;
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    [txtContent becomeFirstResponder];
    self.txtContent.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated
{
    NSString *value = [[Config Instance] getCommentCache:self.parentID];
    if (value != nil) {
        self.txtContent.text = value;
    }
    if (commentBeforeLogin) {
        txtContent.text = commentBeforeLogin;
        commentBeforeLogin = nil;
    }
}
- (void)viewDidUnload
{
    [self setTxtContent:nil];
    [self setSwitchRepost:nil];
    [self setLblState1:nil];
    parent = nil;
    [self setLbl_HeadTitle:nil];
    [self setTxtContent:nil];
    [self setTxtContent:nil];
    [super viewDidUnload];
}
//发表评论
- (IBAction)clickComment:(id)sender {
    
    [self backgroundDown:nil];
    
    NSString *content = self.txtContent.text;
    if ([content isEqualToString:@""]) {
        [Tool ToastNotification:@"错误 内容不能为空" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    //登录验证 如果没有验证需要提示登录
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在发表" andView:self.view andHUD:hud];
    
    if (parent.commentType != 5) 
    {
        [[AFOSCClient sharedClient] postPath:api_comment_pub
                                  parameters:
                                     [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.catalog],@"catalog",
                                      [NSString stringWithFormat:@"%d", self.parentID],@"id",
                                      [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                      content, @"content",
                                      self.switchRepost.isOn ? @"1" : @"0", @"isPostToMyZone",
                                      nil]
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         [hud hide:YES];
                                         [Tool getOSCNotice2:operation.responseString];
                                         ApiError *error = [Tool getApiError2:operation.responseString];
                                         if (error == nil) {
                                             [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                             return ;
                                         }
                                         switch (error.errorCode) {
                                             case 1:
                                             {
                                                 [[Config Instance] saveCommentCache:nil andCommentID:self.parentID];
                                                 //获取刚才发表的评论并保存在内存中
                                                 Comment *c = [Tool getMyLatestComment2:operation.responseString];
                                                 if (c && isListIn) {
                                                     [Config Instance].tempComment = c;
                                                     [Config Instance].tempComment.catalog = self.catalog;
                                                     [Config Instance].tempComment.parentID = self.parentID;
                                                 }
                                                 //返回
                                                 [self dismissModalViewControllerAnimated:YES];
                                                 //自动回退成功
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }
                                                 break;
                                                 //评论成功不需要提示
                                             case 0:
                                             {
                                                 commentBeforeLogin = txtContent.text;
                                                 [Tool noticeLogin:self.view andDelegate:self andTitle:[Tool getCommentLoginNoticeByCatalog:self.catalog]];
                                             }
                                                 break;
                                             case -2:
                                             case -1:
                                             {
                                                 [Tool ToastNotification:[NSString stringWithFormat:@"错误 %@", error.errorMessage] andView:self.view andLoading:NO andIsBottom:NO];
                                             }
                                                 break;
                                         }
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [hud hide:YES];
                                         [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                                     }];
    }
    else
    {
        [[AFOSCClient sharedClient] postPath:api_blogcomment_pub
                                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%d",self.parentID],@"blog",
                                              [NSString stringWithFormat:@"%d",[Config Instance].getUID],@"uid",
                                              content, @"content",nil]
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                         [hud hide:YES];
                                         [Tool getOSCNotice2:operation.responseString];
                                         ApiError *error = [Tool getApiError2:operation.responseString];
                                         if (error == nil) {
                                             [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                             return ;
                                         }
                                         switch (error.errorCode) {
                                             case 1:
                                             {
                                                 [[Config Instance] saveCommentCache:nil andCommentID:self.parentID];
                                                 //获取刚才发表的评论并保存在内存中
                                                 Comment *c = [Tool getMyLatestComment2:operation.responseString];
                                                 if (c && isListIn) {
                                                     [Config Instance].tempComment = c;
                                                     [Config Instance].tempComment.catalog = self.catalog;
                                                     [Config Instance].tempComment.parentID = self.parentID;
                                                 }
                                                 //返回
                                                 [self dismissModalViewControllerAnimated:YES];
                                                 //自动回退成功
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }
                                                 break;
                                                 //评论成功不需要提示
                                             case 0:
                                             {
                                                 commentBeforeLogin = txtContent.text;
                                                 [Tool noticeLogin:self.view andDelegate:self andTitle:[Tool getCommentLoginNoticeByCatalog:self.catalog]];
                                             }
                                                 break;
                                             case -2:
                                             case -1:
                                             {
                                                 [Tool ToastNotification:[NSString stringWithFormat:@"错误 %@", error.errorMessage] andView:self.view andLoading:NO andIsBottom:NO];
                                             }
                                                 break;
                                         }
                                         
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [hud hide:YES];
                                      [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                                  }];
        
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.navigationController andParent:self];
}
//关闭键盘
- (IBAction)backgroundDown:(id)sender {
    [txtContent resignFirstResponder];
}
- (IBAction)changeIsPostToMyZone:(id)sender {
    
    [[Config Instance] saveIsPostToMyZone:self.switchRepost.isOn];
}
- (IBAction)clickDidOnExit:(id)sender {
    [sender resignFirstResponder];
    [self clickComment:nil];
}
-(void)textViewDidChange:(UITextView *)textView
{
    [[Config Instance] saveCommentCache:textView.text andCommentID:self.parentID];
}
@end
