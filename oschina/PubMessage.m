#import "PubMessage.h"

@implementation PubMessage
@synthesize txtContent;
@synthesize receiver;
@synthesize receiverid;
@synthesize isFromUserView;
@synthesize lbl_Receiver;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"发送留言";
    [Tool roundTextView:self.txtContent];
    //如果又接受者
    if (receiver && ![receiver isEqualToString:@""]) {
        lbl_Receiver.text = [NSString stringWithFormat:@"发给: %@", receiver];
    }
    
    UIBarButtonItem *_btnPub = [[UIBarButtonItem alloc] initWithTitle:@"发送消息" style:UIBarButtonItemStyleBordered  target:self action:@selector(clickPubMessage:)];
    self.navigationItem.rightBarButtonItem = _btnPub;
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    
    [txtContent becomeFirstResponder];
    txtContent.delegate = self;
}
- (void)viewDidUnload
{
    [self setTxtContent:nil];
    [self setLbl_Receiver:nil];
    [self setTxtContent:nil];
    [self setTxtContent:nil];
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated
{
    NSString *msg = [[Config Instance] getMsgCache:self.receiverid];
    if (msg != nil) {
        self.txtContent.text = msg;
    }
}
- (IBAction)clickPubMessage:(id)sender 
{
    [self clickbackground:nil];
    
    NSString *message = self.txtContent.text;
    if ([message isEqualToString:@""]) {
        [Tool ToastNotification:@"错误 留言内容不能为空" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    if ([message length]>250) {
        [Tool ToastNotification:@"错误 留言内容不能超过250个字符" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    //登录验证 如果没有验证需要提示登录
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在发送" andView:self.view andHUD:hud];
    
    [[AFOSCClient sharedClient] postPath:api_message_pub parameters:
                                 
        [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                                    [NSString stringWithFormat:@"%d", receiverid],@"receiver",
                                                    message, @"content",
                                                    nil]
     
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                             [[Config Instance] saveMsgCache:nil andUID:self.receiverid];
                                             if (isFromUserView == NO) {
                                                 Comment *c = [Tool getMyLatestComment2:operation.responseString];
                                                 if (c) {
                                                     [Config Instance].tempComment = c;
                                                     [Config Instance].tempComment.catalog = 4;
                                                 }
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }
                                             else
                                             {
                                                 [Tool ToastNotification:@"发送留言成功" andView:self.view andLoading:NO andIsBottom:NO];
                                             }
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
- (IBAction)clickbackground:(id)sender 
{
    [txtContent resignFirstResponder];
}

- (IBAction)clickDidOnExit:(id)sender {
    [sender resignFirstResponder];
    [self clickPubMessage:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [[Config Instance] saveMsgCache:textView.text andUID:self.receiverid];
}
@end
