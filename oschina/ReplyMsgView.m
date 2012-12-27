//
//  ReplyMsgView.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReplyMsgView.h"

@implementation ReplyMsgView
@synthesize lblTitle;
@synthesize btnTitle;
@synthesize txtReply;
@synthesize parentCommentID;
@synthesize catalog;
@synthesize replyID;
@synthesize authorID;
@synthesize parent;
@synthesize webViewReply;
@synthesize parentComment;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [txtReply setDelegate:self];
    [Tool roundTextView:self.txtReply];
    
    UIBarButtonItem *_btnPub = [[UIBarButtonItem alloc] initWithTitle:@"回复" style:UIBarButtonItemStyleBordered target:self action:@selector(clickReply:)];
    self.navigationItem.rightBarButtonItem = _btnPub;
    
    if (self.parentComment) 
    {
        [self.webViewReply loadHTMLString:[Tool generateCommentDetail:self.parentComment] baseURL:nil];
        [Tool clearWebViewBackground:self.webViewReply];
    }
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    
    if (IS_IPHONE_5) {
        self.webViewReply.frame = CGRectMake(0, 0, 320, 323+88);
        self.txtReply.frame = CGRectMake(8, 332+88, 305, 46);
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    NSString *value = [[Config Instance] getReplyCache:self.parentCommentID andReplyID:self.replyID];
    if (value != nil) {
        self.txtReply.text = value;
    }
    
    if (commentBeforeLogin) {
        txtReply.text = commentBeforeLogin;
        commentBeforeLogin = nil;
    }
}
- (void)viewDidUnload
{
    [self setTxtReply:nil];
    lblTitle = btnTitle = nil;
    [Tool ReleaseWebView:self.webViewReply];
    [self setWebViewReply:nil];
    [self setTxtReply:nil];
    [self setTxtReply:nil];
    [super viewDidUnload];
}
- (IBAction)clickBackground:(id)sender {
    
    [txtReply resignFirstResponder];
}
- (IBAction)clickReply:(id)sender {
    
    [self clickBackground:nil];
    NSString *message = self.txtReply.text;
    if ([message isEqualToString:@""]) 
    {
        [Tool ToastNotification:@"错误 回复内容不能为空" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在回复" andView:self.view andHUD:hud];
    if (self.parent.commentType != 5) 
    {

        [[AFOSCClient sharedClient] postPath:api_comment_reply
                                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%d", self.parentCommentID],@"id",
                                              [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                              [NSString stringWithFormat:@"%d", self.catalog],@"catalog",
                                              [NSString stringWithFormat:@"%d", self.replyID],@"replyid",
                                              [NSString stringWithFormat:@"%d", self.authorID],@"authorid",
                                              message, @"content",nil]
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      [hud hide:YES];
                                      [Tool getOSCNotice2:operation.responseString];

                                      ApiError * error = [Tool getApiError2:operation.responseString];
                                      if (error == nil) {
                                          [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                          return ;
                                      }
                                      switch (error.errorCode) {
                                          case 1:
                                          {
                                              [[Config Instance] saveReplyCache:nil andCommentID:self.parentCommentID andReplyID:self.replyID];
                                              Comment *c = [Tool getMyLatestComment2:operation.responseString];
                                              if (c) {
                                                  [Config Instance].tempComment = c;
                                                  [Config Instance].tempComment.catalog = self.catalog;
                                                  [Config Instance].tempComment.parentID = self.parentCommentID;
                                              }
                                              [self.navigationController popViewControllerAnimated:YES];
                                          }
                                              break;
                                          case 0:
                                          {
                                              commentBeforeLogin = txtReply.text;
                                              //注意这里必须用 self.parentViewController
                                              [Tool noticeLogin:self.parentViewController.view andDelegate:self andTitle:[Tool getCommentLoginNoticeByCatalog:self.catalog]];
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
                                              [NSString stringWithFormat:@"%d", self.parentCommentID],@"blog",
                                              [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                              message, @"content",
                                              [NSString stringWithFormat:@"%d",self.replyID],@"reply_id",
                                              [NSString stringWithFormat:@"%d",parentComment.authorid],@"objuid",
                                              nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                      [hud hide:YES];
                                      [Tool getOSCNotice2:operation.responseString];
                                      
                                      ApiError * error = [Tool getApiError2:operation.responseString];
                                      if (error == nil) {
                                          [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                          return ;
                                      }
                                      switch (error.errorCode) {
                                          case 1:
                                          {
                                              [[Config Instance] saveReplyCache:nil andCommentID:self.parentCommentID andReplyID:self.replyID];
                                              Comment *c = [Tool getMyLatestComment2:operation.responseString];
                                              if (c) {
                                                  [Config Instance].tempComment = c;
                                                  [Config Instance].tempComment.catalog = self.catalog;
                                                  [Config Instance].tempComment.parentID = self.parentCommentID;
                                              }
                                              [self.navigationController popViewControllerAnimated:YES];
                                          }
                                              break;
                                          case 0:
                                          {
                                              commentBeforeLogin = txtReply.text;

                                              [Tool noticeLogin:self.parentViewController.view andDelegate:self andTitle:[Tool getCommentLoginNoticeByCatalog:self.catalog]];
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
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.navigationController andParent:self.parentViewController];
}
#pragma 浏览器链接处理
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [Tool analysis:[request.URL absoluteString] andNavController:self.parentViewController.navigationController];
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) 
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
#pragma 调整输入框
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-215, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+215, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}

- (IBAction)clickDidOnExit:(id)sender {
    [sender resignFirstResponder];
    [self clickReply:nil];
}
-(void)textViewDidChange:(UITextView *)textView
{
    [[Config Instance] saveReplyCache:textView.text andCommentID:self.parentCommentID andReplyID:self.replyID];
}
@end
