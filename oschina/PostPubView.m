//
//  PostPubView.m
//  oschina
//
//  Created by wangjun on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostPubView.h"

@implementation PostPubView
@synthesize txtTitle;
@synthesize segmentCatalog;
@synthesize txtContent;
@synthesize switchNotice;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //验证登录
    [super viewDidLoad];
    [Tool roundTextView:txtContent];
    [txtContent setDelegate:self];
    
    self.navigationItem.title = @"我要提问";
    
    //切换
    [self.switchNotice setOn:[[Config Instance] isPostPubNoticeMe]];
    
    UIBarButtonItem *btnPub = [[UIBarButtonItem alloc] initWithTitle:@"发表问题" style:UIBarButtonItemStyleBordered target:self action:@selector(clickPub:)];
    self.navigationItem.rightBarButtonItem = btnPub;
    
    self.segmentCatalog.selectedSegmentIndex = [[Config Instance] getPubPostCatalog];
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    
    [txtTitle becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setTxtTitle:nil];
    [self setSegmentCatalog:nil];
    [self setTxtContent:nil];
    [self setSwitchNotice:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)clickPub:(id)sender {

    NSString *title = self.txtTitle.text;
    NSString *content = self.txtContent.text;
    if ([title isEqualToString:@""]) {
        [Tool ToastNotification:@"错误 问答标题不能为空" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    if ([content isEqualToString:@""]) {
        [Tool ToastNotification:@"错误 问答内容不能为空" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在发表" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient] postPath:api_post_pub parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[Config Instance].getUID],@"uid",title,@"title",[NSString stringWithFormat:@"%d", self.segmentCatalog.selectedSegmentIndex+1],@"catalog",content,@"content",self.switchNotice.isOn ? @"1":@"0",@"isNoticeMe", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
        [Tool getOSCNotice2:operation.responseString];
        
        ApiError *error = [Tool getApiError2:operation.responseString];
        if (error == nil) {
            [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
            return;
        }
        switch (error.errorCode) {
            case 1:
            {
                [Config Instance].questionIndex = 0;
                [Config Instance].questionContent = nil;
                [Config Instance].questionTitle = Nil;
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case 0:
            case -2:
            case -1:
            {
                [Tool ToastNotification:[NSString stringWithFormat:@"错误 %@", error.errorMessage] andView:self.view andLoading:NO andIsBottom:NO];
            }
                break;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hide:YES];
        [Tool ToastNotification:@"发布问题失败" andView:self.view andLoading:NO andIsBottom:NO];
        
    }];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.segmentCatalog.selectedSegmentIndex = [Config Instance].questionIndex;
    NSString *title = [Config Instance].questionTitle;
    NSString *content = [Config Instance].questionContent;
    if (title != nil) {
        self.txtTitle.text = title;
    }
    if (content != nil) {
        self.txtContent.text = content;
    }
}

- (IBAction)txtTitleExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTouchDown:(id)sender {
    [txtTitle resignFirstResponder];
    [txtContent resignFirstResponder];
}

- (IBAction)segmentChanged:(id)sender {
    [Config Instance].questionIndex = self.segmentCatalog.selectedSegmentIndex;
    [[Config Instance] savePubPostCatalog:self.segmentCatalog.selectedSegmentIndex];
    switch (self.segmentCatalog.selectedSegmentIndex) {
        case 0:
        case 2:
            self.txtTitle.placeholder = @"你有什么技术问题,请在此输入";
            break;
        case 1:
            self.txtTitle.placeholder = @"你有要跟大家分享的呢,请在此输入";
            break;
        case 3:
            self.txtTitle.placeholder = @"[城市]我想要应聘一个 xxxx 职位";
            break;
        case 4:
            self.txtTitle.placeholder = @"你对OSChina.net有什么建议,请在此输入";
            break;
    }
}

- (IBAction)isNoticeMeChanged:(id)sender {
    [[Config Instance] savePostPubNoticeMe:self.switchNotice.isOn];
}

- (IBAction)textChanged:(id)sender {
    [Config Instance].questionTitle = txtTitle.text;
}


#pragma 调整输入框
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-78, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+78, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}

@end
