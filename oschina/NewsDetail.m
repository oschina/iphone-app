//
//  NewsDetail.m
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsDetail.h"

@implementation NewsDetail

@synthesize webView;
@synthesize singleNews;
@synthesize newsID;
@synthesize isNextPage;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}

#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title = @"资讯详情";
    if (self.singleNews) {
        [self refreshFavorite:self.singleNews];
    }
}
- (void)clickFavorite:(id)sender
{
    UIBarButtonItem * btn = (UIBarButtonItem *)sender;
    BOOL isFav = [btn.title isEqualToString:@"收藏此文"];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:isFav ? @"正在添加收藏":@"正在删除收藏" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient]getPath:isFav ? api_favorite_add : api_favorite_delete 
                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%d", [Config Instance].getUID],@"uid",
                                        [NSString stringWithFormat:@"%d", newsID],@"objid",
                                        @"4",@"type", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
                                [hud hide:YES];
                                [Tool getOSCNotice2:operation.responseString];
                          
                                ApiError *error = [Tool getApiError2:operation.responseString];
                                if (error == nil) {
                                    [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                    return ;
                                }
                                switch (error.errorCode) 
                                {
                                    case 1:
                                    {
                                        btnFavorite.title = isFav ? @"取消收藏" : @"收藏此文";
                                        self.singleNews.favorite = !self.singleNews.favorite;
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
- (void)clickToHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarItem.title = @"资讯详情";
    self.tabBarItem.image = [UIImage imageNamed:@"detail"];
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    
    self.singleNews = [[SingleNews alloc] init];
    self.navigationController.title = @"资讯详情";
    self.webView.delegate = self;
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    if ([Config Instance].isNetworkRunning) 
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        
        NSString *url = [NSString stringWithFormat:@"%@?id=%d",api_news_detail, newsID];
        [[AFOSCClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Tool getOSCNotice2:operation.responseString];
            [hud hide:YES];
            
            self.singleNews = [Tool readStrNewsDetail:operation.responseString];
            if (self.singleNews == nil) {
                [Tool ToastNotification:@"加载失败" andView:self.view andLoading:NO andIsBottom:NO];
                return;
            }
            [self loadData:self.singleNews];
            
            //如果有网络 则缓存它
            if ([Config Instance].isNetworkRunning) 
            {
                [Tool saveCache:1 andID:self.singleNews._id andString:operation.responseString];
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
        NSString *value = [Tool getCache:1 andID:newsID];
        if (value) {
            self.singleNews = [Tool readStrNewsDetail:value];
            [self loadData:self.singleNews];
        }
        else {
            [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
        }
    }
}

- (void)viewDidUnload
{
    [Tool ReleaseWebView:self.webView];
    [self setWebView:nil];
    singleNews = nil;
    [super viewDidUnload];
}
- (void)loadData:(SingleNews *)n
{
    [self refreshFavorite:n];
    //通知去修改新闻评论数
    Notification_CommentCount *notification = [[Notification_CommentCount alloc] initWithParameters:self andCommentCount:n.commentCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_DetailCommentCount object:notification];
    //新闻  主要用于微博分享
    [Config Instance].shareObject = [[ShareObject alloc] initWithParameters:n.title andUrl:n.url];
    //控件更新
    NSString *author_str = [NSString stringWithFormat:@"<a href='http://my.oschina.net/u/%d'>%@</a> 发布于 %@",n.authorid,n.author,n.pubDate];
    
    NSString *software = @"";
    if ([n.softwarename isEqualToString:@""] == NO) {
        software = [NSString stringWithFormat:@"<div id='oschina_software' style='margin-top:8px;color:#FF0000;font-size:14px;font-weight:bold'>更多关于:&nbsp;<a href='%@'>%@</a>&nbsp;的详细信息</div>",n.softwarelink, n.softwarename];
    }
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr/><div id='oschina_body'>%@</div>%@%@%@</body>",HTML_Style, n.title,author_str, n.body,software,[Tool generateRelativeNewsString:n.relativies],HTML_Bottom];
    
    NSString *result = [Tool getHTMLString:html];
    [self.webView loadHTMLString:result baseURL:nil];
}
- (void)refreshFavorite:(SingleNews *)n
{
    if (self.isNextPage) 
    {
        UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 128, 44.01)];
        NSMutableArray *right = [[NSMutableArray alloc] initWithCapacity:2];
        UIBarButtonItem * btnHome = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStyleBordered target:self action:@selector(clickToHome:)];
        [right addObject:btnHome];
        
        btnFavorite = [[UIBarButtonItem alloc] initWithTitle:n.favorite ? @"取消收藏" : @"收藏此文" style:UIBarButtonItemStyleBordered target:self action:@selector(clickFavorite:)];
        [right addObject:btnFavorite];
        [toolbar setItems:right animated:YES];
        self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    }
    else
    {
        btnFavorite = [[UIBarButtonItem alloc] initWithTitle:n.favorite ? @"取消收藏" : @"收藏此文" style:UIBarButtonItemStyleBordered target:self action:@selector(clickFavorite:)];
        self.parentViewController.navigationItem.rightBarButtonItem = btnFavorite;
    }
}

#pragma 浏览器链接处理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
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

@end
