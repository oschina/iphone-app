//
//  PubTweet.m
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PubTweet.h"

@implementation PubTweet

@synthesize img;
@synthesize parent;
@synthesize lblHeadTip;
@synthesize txtContent;
@synthesize lblStringlength;
@synthesize atSomebody;
@synthesize isSourceUser;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [Tool roundTextView:txtContent];
    lblHeadTip.font = [UIFont boldSystemFontOfSize:17.0];
    UIToolbar *customToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 146, 44.01)];
    NSMutableArray *rightBarButtonArray = [[NSMutableArray alloc] initWithCapacity:2];

    UIBarButtonItem *btnPic = [[UIBarButtonItem alloc] initWithTitle:@"＋图片" style:UIBarButtonItemStyleBordered target:self action:@selector(clickImgs:)];
    [rightBarButtonArray addObject:btnPic];
    UIBarButtonItem *btnPub = [[UIBarButtonItem alloc] initWithTitle:@"动弹一下" style:UIBarButtonItemStyleBordered target:self action:@selector(click_PubTweet:)];
    [rightBarButtonArray addObject:btnPub];
    [customToolbar setItems:rightBarButtonArray animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customToolbar];
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    
    if (self.atSomebody) {
        txtContent.text = self.atSomebody;
    }
    
    [txtContent becomeFirstResponder];
    txtContent.delegate = self;
    
    //表情
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 216, 320, IS_IPHONE_5 ? 304 : 216)];
//    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.he÷Ωight - ( IS_IPHONE_5 ? 304 : 216), 320, 216)];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.contentSize = CGSizeMake(320.0, IS_IPHONE_5 ? 498 : 410.0);
    _emojiView = [[TSEmojiView alloc] initWithFrame:CGRectMake(-3, 0, 323, 520)];
    _emojiView.delegate = self;
    [scroll addSubview:_emojiView];
}
- (void)viewDidUnload
{
    [self setImg:nil];
    [self setLblHeadTip:nil];
    [self setTxtContent:nil];
    [self setLblStringlength:nil];
    [super viewDidUnload];
}
- (void)viewDidDisappear:(BOOL)animated
{
    if ([Config Instance].tweetCachePic) {
        self.img.image = [Config Instance].tweetCachePic;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    if (self.isSourceUser) {
        return;
    }
    if (self.atSomebody == nil) {
        
        //恢复缓存
        NSString *tweetCache = [Config Instance].tweet;
        if (tweetCache != nil) {
            txtContent.text = tweetCache;
        }
        
        if ([Config Instance].tweetCachePic) {
            self.img.image = [Config Instance].tweetCachePic;
        }
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 发表动弹
- (IBAction)click_PubTweet:(id)sender {
    
    [self clickBackground:nil];
    
    NSString *tweet = self.txtContent.text;
    if ([tweet isEqualToString:@""]) {
        [Tool ToastNotification:@"错误 动弹必须包含至少一个字符" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    //如果没有图片
    if (self.img.image == nil) {
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"正在发表" andView:self.view andHUD:hud];
        [[AFOSCClient sharedClient] postPath:api_tweet_pub parameters:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
            tweet,@"msg",nil]
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
                                                 [Config Instance].tweet = nil;
                                                 [Config Instance].tweetCachePic = nil;
                                                 [Config Instance].isNeedReloadTweets = YES;
                                                 self.txtContent.text = @"";
                                                 self.img.image = nil;
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
                                         [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                                     }];
    }
    //如果有图片 则后台发送
    else
    {
        [[MyThread Instance] startPubTweet:tweet andImg:UIImageJPEGRepresentation(self.img.image, 0.7f)];
        self.lblHeadTip.text = @"动弹后台发送中";
        return;
    }
    
    self.txtContent.text = @"";
    self.img.image = nil;
}

#pragma mark - 关闭键盘
- (IBAction)clickBackground:(id)sender 
{
    [self.txtContent resignFirstResponder];
    if (scroll.superview == self.view) {
        [scroll removeFromSuperview];
    }
}
- (IBAction)txtDidOnExit:(id)sender {
    [sender resignFirstResponder];
    [self click_PubTweet:nil];
}

#pragma mark - 选择图片
- (IBAction)clickImgs:(id)sender 
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"返回" otherButtonTitles:@"图库",@"拍照", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //获取点击按钮的标题
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"拍照"])
    {
        UIImagePickerController *imgPicker = [UIImagePickerController new];
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imgPicker animated:YES];
    }
    else if([buttonTitle isEqualToString:@"图库"])
    {
        UIImagePickerController *imgPicker = [UIImagePickerController new];
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imgPicker animated:YES];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    //添加到集合中
    UIImage * imgData = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.img.image = [Tool scale:imgData toSize:[Tool scaleSize:imgData.size]];
    [Config Instance].tweetCachePic = [Tool scale:imgData toSize:[Tool scaleSize:imgData.size]];
    [self clickBackground:nil];
}
//用户取消选择某张图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}
//点击顶部的完成按钮
- (IBAction)click_Close:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - TextView输入
- (void)textViewDidChange:(UITextView *)textView
{
    [Config Instance].tweet = textView.text;
    self.lblStringlength.text = [NSString stringWithFormat:@"%d", 160 - textView.text.length];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (scroll.superview == self.view) {
        [scroll removeFromSuperview];
    }
}

#pragma mark - 表情
- (void)didTouchEmojiView:(TSEmojiView*)emojiView touchedEmoji:(NSString*)str
{
    str = [NSString stringWithFormat:@"[%@]", str];
    NSString * version = [UIDevice currentDevice].systemVersion;
    int v = [version substringToIndex:1].intValue;
    if (v < 5) {
        txtContent.text = [NSString stringWithFormat:@"%@%@",txtContent.text, str];
    }
    else {
        
        int len = [txtContent selectedRange].location;
        txtContent.text = [NSString stringWithFormat:@"%@%@%@", [txtContent.text substringToIndex:len],str,[txtContent.text substringFromIndex:len]];
    }
    self.lblStringlength.text = [NSString stringWithFormat:@"%d", 160 - txtContent.text.length];
}
- (IBAction)clickFace:(id)sender {
    [txtContent resignFirstResponder];
    if (scroll.superview == self.view) {
        [scroll removeFromSuperview];
    }
    else
    {
        [self.view addSubview:scroll];
    }
}

@end
