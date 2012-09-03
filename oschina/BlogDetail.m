//
//  BlogDetail.m
//  oschina
//
//  Created by wangjun on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BlogDetail.h"

@implementation BlogDetail
@synthesize webView;
@synthesize blogID;
@synthesize singleBlog;

#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"博客详情";
    [Tool clearWebViewBackground:webView];
    self.webView.delegate = self;
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    //如果有网络
    if ([Config Instance].isNetworkRunning) {

        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        NSString *url = [NSString stringWithFormat:@"%@?id=%d",api_blog_detail, blogID];
        [[AFOSCClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [hud hide:YES];
            [Tool getOSCNotice2:operation.responseString];
            
            Blog *b = [Tool readStrBlogDetail:operation.responseString];
            if (b == nil) {
                [Tool ToastNotification:@"加载失败" andView:self.view andLoading:NO andIsBottom:NO];
                return;
            }
            [self loadData:b];
            
            if ([Config Instance].isNetworkRunning) {
                [Tool saveCache:4 andID:b._id andString:operation.responseString];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [hud hide:YES];
            if ([Config Instance].isNetworkRunning) {
                [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
            }
            
        }];
    }
    else
    {
        NSString *value = [Tool getCache:4 andID:blogID];
        if (value) {
            Blog *b = [Tool readStrBlogDetail:value];
            [self loadData:b];
        }
        else {
            [Tool ToastNotification:@"错误 网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
        }
    }
}
- (void)clickFavorite:(id)sender
{
    UIBarButtonItem * btn = (UIBarButtonItem *)sender;
    BOOL isFav = [btn.title isEqualToString:@"收藏此博客"];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:isFav ? @"正在添加收藏":@"正在删除收藏" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient]getPath:isFav?api_favorite_add:api_favorite_delete 
                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                        [NSString stringWithFormat:@"%d", blogID],@"objid",
                                        @"3",@"type", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
                                [hud hide:YES];
                                [Tool getOSCNotice2:operation.responseString];
                                
                                ApiError *error = [Tool getApiError2:operation.responseString];
                                if (error == nil) {
                                    [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                    return;
                                }
                                switch (error.errorCode) 
                                {
                                    case 1:
                                    {
                                        btnFavorite.title = isFav ? @"取消收藏" : @"收藏此博客";
                                        singleBlog.favorite = !singleBlog.favorite;
                                    }
                                        break;
                                    case 0:
                                    case -2:
                                    case -1:
                                    {
                                        [Tool ToastNotification:[NSString stringWithFormat:@"错误 %@",error.errorMessage] andView:self.view andLoading:NO andIsBottom:NO];
                                    }
                                        break;
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [hud hide:YES];
                                [Tool ToastNotification:@"添加收藏失败" andView:self.view andLoading:NO andIsBottom:NO];
                            }];

}

- (void)viewDidUnload
{
    [Tool ReleaseWebView:self.webView];
    [self setWebView:nil];
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (self.singleBlog) {
        [self refreshFavorite:self.singleBlog];
    }
}
- (void)loadData:(Blog *)b
{
    self.singleBlog = b;
    [self refreshFavorite:b];
    
    //通知去修改新闻评论数
    Notification_CommentCount *notification = [[Notification_CommentCount alloc] initWithParameters:self andCommentCount:b.commentCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_DetailCommentCount object:notification];

    
    //新式方法
    NSString *author_str = [NSString stringWithFormat:@"<a href='http://my.oschina.net/u/%d'>%@</a>&nbsp;发表于&nbsp;%@",b.authorid, b.author,  [Tool intervalSinceNow:b.pubDate]];
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr/><div id='oschina_body'>%@</div>%@</body>",HTML_Style, b.title,author_str,b.body,HTML_Bottom];
    NSString *result = [Tool getHTMLString:html];
    [self.webView loadHTMLString:result baseURL:nil];
    
    [Config Instance].shareObject = [[ShareObject alloc] initWithParameters:b.title andUrl:b.url];
}
- (void)refreshFavorite:(Blog *)b
{
    btnFavorite = [[UIBarButtonItem alloc] initWithTitle:b.favorite ? @"取消收藏" : @"收藏此博客" style:UIBarButtonItemStyleBordered target:self action:@selector(clickFavorite:)];
    self.parentViewController.navigationItem.rightBarButtonItem = btnFavorite;
}

#pragma 浏览器链接处理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [Tool analysis:[request.URL absoluteString] andNavController:self.navigationController];
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) 
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
@end
