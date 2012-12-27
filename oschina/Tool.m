//
//  Tool.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tool.h"
static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
@implementation Tool

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *progressAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(121, 80, 37, 37);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}
+ (ApiError *)getApiError:(ASIHTTPRequest *)request
{
    return [Tool getApiError2:request.responseString];
}
+ (ApiError *)getApiError2:(NSString *)response
{
    @try {
        TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
        TBXMLElement *root = xml.rootXMLElement;  
        if (root == nil) {
            return nil;
        }
        TBXMLElement *result = [TBXML childElementNamed:@"result" parentElement:root];
        if (result == nil) {
            return nil;
        }
        TBXMLElement *errorCode = [TBXML childElementNamed:@"errorCode" parentElement:result];
        TBXMLElement *errorMessage = [TBXML childElementNamed:@"errorMessage" parentElement:result];
        return [[ApiError alloc] initWithParameters:[[TBXML textForElement:errorCode] intValue] andMessage:[TBXML textForElement:errorMessage]];
    }
    @catch (NSException *exception) {
        [NdUncaughtExceptionHandler TakeException:exception];
        return [[ApiError alloc] initWithParameters:-1 andMessage:@"出现异常"];
    }
    @finally {
        //        return [[ApiError alloc] initWithParameters:-1 andMessage:@"出现异常"];
    }
}
+ (Comment *)getMyLatestComment:(ASIHTTPRequest *)request
{
    return [Tool getMyLatestComment2:request.responseString];
}
+ (Comment *)getMyLatestComment2:(NSString *)response
{
//    NSString *response = [request responseString];
    TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *c = [TBXML childElementNamed:@"comment" parentElement:root];
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:c];
    TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:c];
    TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:c];
    TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:c];
    TBXMLElement *content = [TBXML childElementNamed:@"content" parentElement:c];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:c];
    NSMutableArray * replies = [Tool getReplies:c];
    NSMutableArray * refers = [Tool getRefers:c];
    TBXMLElement *appclient = [TBXML childElementNamed:@"appclient" parentElement:c];
    Comment *comment = [[Comment alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andContent:[TBXML textForElement:content] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andReplies:replies andRefers:refers andAppClient:appclient == nil ? 1 : [TBXML textForElement:appclient].intValue];
    return comment;

}
+ (NSString *)getBBSIndex:(int)index
{
    if (index < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%d楼", index+1];
}
+ (NSMutableArray *)getRelativeNews:(NSString *)request
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:request error:nil];
    TBXMLElement *root = xml.rootXMLElement;    
    TBXMLElement *news = [TBXML childElementNamed:@"news" parentElement:root];
    TBXMLElement *relativies = [TBXML childElementNamed:@"relativies" parentElement:news];
    if (relativies) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
        TBXMLElement *relative = [TBXML childElementNamed:@"relative" parentElement:relativies];
        TBXMLElement *title = [TBXML childElementNamed:@"rtitle" parentElement:relative];
        TBXMLElement *url = [TBXML childElementNamed:@"rurl" parentElement:relative];
        [array addObject:[[RelativeNews alloc] initWithParameters:[TBXML textForElement:url] andTitle:[TBXML textForElement:title]]];
        while (relative) {
            relative = [TBXML nextSiblingNamed:@"relative" searchFromElement:relative];
            if (relative) {
                title = [TBXML childElementNamed:@"rtitle" parentElement:relative];
                url = [TBXML childElementNamed:@"rurl" parentElement:relative];
                if (url && title) {
                    [array addObject:[[RelativeNews alloc] initWithParameters:[TBXML textForElement:url] andTitle:[TBXML textForElement:title]]];
                }
            }
        }
        return array;
    }
    else{
        return nil;
    }
}
+ (NSString *)generateRelativeNewsString:(NSArray *)array
{
    if (array == nil || [array count] == 0) {
        return @"";
    }
    NSString *middle = @"";
    for (RelativeNews *r in array) {
        middle = [NSString stringWithFormat:@"%@<a href=%@ style='text-decoration:none'>%@</a><p/>",middle, r.url, r.title];
    }
    return [NSString stringWithFormat:@"<hr/>相关文章<div style='font-size:14px'><p/>%@</div>", middle];
}
+ (NSString *)generateCommentDetail:(Comment *)comment
{
    NSString *first = [NSString stringWithFormat:@"<div style='color:#0D6DA8;font-size:16px'>%@ 发表于%@</div>", comment.author, comment.pubDate];
    NSString *second = [NSString stringWithFormat:@"<div style='font-size:15px;line-height:20px'>%@</div>",comment.content];
    
    NSString *three = @"";
    if ([comment.replies count]>0) {
        three = [NSString stringWithFormat:@"<br/><div style='font-size:14px;line-height:19px'>-- 共有%d条评论 --</div><div style='font-size:13px;color:#888888;'>", [comment.replies count]];
        for (NSString *r in comment.replies) {
            three = [NSString stringWithFormat:@"%@%@<p/>",three,r];
        }
        three = [NSString stringWithFormat:@"%@</div>", three];
    }
    return [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@%@%@</body>", first, second,three];
}
+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom
{
    if (isBottom) {
        NSUInteger sectionCount = [tableView numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [tableView numberOfRowsInSection:0];
            if (rowCount) {
                NSUInteger ii[2] = {0, rowCount - 1};
                NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:isBottom ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:YES];
            }
        }
    }
    else
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog
{
    switch (catalog) {
        case 1:
        case 3:
            return @"请先登录后发表评论";
        case 2:
            return @"请先登录后再回帖或评论";
        case 4:
            return @"请先登录后发留言";
    }
    return @"请先登录后发表评论";
}
+ (void)roundTextView:(UITextView *)txtView
{
    txtView.layer.borderColor = UIColor.grayColor.CGColor;
    txtView.layer.borderWidth = 1;
    txtView.layer.cornerRadius = 6.0;
    txtView.layer.masksToBounds = YES;
    txtView.clipsToBounds = YES;
}
+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title
{
    UIActionSheet * loginSheet = [[UIActionSheet alloc] initWithTitle:title delegate:delegate cancelButtonTitle:@"返回" destructiveButtonTitle:nil otherButtonTitles:@"登录", nil];
//    [loginSheet showInView:view];
    [loginSheet showInView:[UIApplication sharedApplication].keyWindow];
}
+ (void)processLoginNotice:(UIActionSheet *)actionSheet andButtonIndex:(NSInteger)buttonIndex andNav:(UINavigationController *)nav andParent:(UIViewController *)parent
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"登录"]) {
        LoginView *loginView = [[LoginView alloc] init];
        loginView.isPopupByNotice = YES;
//        loginView.parent = parent;
        [Config Instance].viewBeforeLogin = parent;
        [nav pushViewController:loginView animated:YES];
    }
}
+ (void)pushNewsDetail:(News *)news andNavController:(UINavigationController *)navController andIsNextPage:(BOOL)isNextPage
{
    switch (news.newsType) {
            //标准新闻
        case 0:
        {
            UITabBarController *newsTab = [[UITabBarController alloc] init];
            newsTab.title = @"资讯详情";
            NewsDetail *nDetail = [[NewsDetail alloc] init];
            nDetail.newsID = news._id;
            nDetail.isNextPage = isNextPage;
            nDetail.tabBarItem.image = [UIImage imageNamed:@"detail"];
            
            MessageSystemView *newsComments = [[MessageSystemView alloc] init];
            newsComments.tabBarItem.title = @"评论";
            newsComments.tabBarItem.image = [UIImage imageNamed:@"commentlist"];
            newsComments.attachment = nDetail;
            newsComments.pubButtonTitle = @"发表评论";
            newsComments.replyLabelTitle = @"评论此回帖";
            newsComments.catalog = 1;
            newsComments.parentID = news._id;
            
            ShareView *shareView = [[ShareView alloc] init];
            shareView.tabBarItem.image = [UIImage imageNamed:@"share"];
            newsTab.viewControllers = [NSArray arrayWithObjects:nDetail,newsComments,shareView, nil];
            newsTab.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:newsTab animated:YES];
        }
            break;
            //软件
        case 1:
        {
            SoftwareDetail *software = [[SoftwareDetail alloc] init];
            software.softwareName = news.attachment;
            software.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:software animated:YES];
        }
            break;
            //问答
        case 2:
        {
            Post *p = [[Post alloc] init];
            p._id = news.attachment.intValue;
            [Tool pushPostDetail:p andNavController:navController];
        }
            break;
            //博客
        case 3:
        {
            UITabBarController *blogTab = [[UITabBarController alloc] init];
            blogTab.title = @"博客详情";
            
            BlogDetail *blog = [[BlogDetail alloc] init];
            blog.blogID = [news.attachment intValue];
            blog.tabBarItem.image = [UIImage imageNamed:@"detail"];
            
            MessageSystemView * comments = [[MessageSystemView alloc] init];
            comments.parentAuthorUID = news.authoruid2;
            comments.tabBarItem.title = @"评论";
            comments.tabBarItem.image = [UIImage imageNamed:@"commentlist"];
            comments.attachment = blog;
            comments.pubButtonTitle = @"发表评论";
            comments.replyLabelTitle = @"评论此回帖";
            comments.commentType = 5;
            comments.parentID = blog.blogID;
            //软件更新
            ShareView * shareView = [[ShareView alloc] init];
            shareView.tabBarItem.image = [UIImage imageNamed:@"share"];
            blogTab.viewControllers = [NSArray arrayWithObjects:blog,comments,shareView, nil];
            blogTab.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:blogTab animated:YES];
        }
            break;
    }
}
+ (void)pushPostDetail:(Post *)post andNavController:(UINavigationController *)navController
{
    UITabBarController *postTab = [[UITabBarController alloc] init];
    postTab.title = @"问答详情";
    SinglePost * singlePost = [[SinglePost alloc] init];
    singlePost.tabBarItem.title = @"问答详情";
    singlePost.tabBarItem.image = [UIImage imageNamed:@"detail"];
    singlePost.postID = post._id;
    
    MessageSystemView *commentsView = [[MessageSystemView alloc] init];
    commentsView.tabBarItem.title = @"回帖";
    commentsView.tabBarItem.image = [UIImage imageNamed:@"commentlist"];
    commentsView.pubTitle = @"我要回帖";
    commentsView.pubButtonTitle = @"我要回帖";
    commentsView.replyLabelTitle = @"评论此回帖";
    commentsView.attachment = singlePost;
    commentsView.catalog = 2;
    commentsView.parentID = post._id;
    
    ShareView *shareView = [[ShareView alloc] init];
    shareView.tabBarItem.image = [UIImage imageNamed:@"share"];
    postTab.viewControllers = [NSArray arrayWithObjects:singlePost,commentsView,shareView, nil];
    postTab.hidesBottomBarWhenPushed = YES;
    [navController pushViewController:postTab animated:YES];
}
+ (void)pushTweetDetail:(Tweet *)tweet andNavController:(UINavigationController *)navController
{
    UITabBarController *tweetTab = [[UITabBarController alloc] init];
    TweetDetail *tweetDetail = [[TweetDetail alloc] init];
    tweetDetail.tweetID = tweet._id;
    tweetDetail.tabBarItem.image = [UIImage imageNamed:@"detail"];
    
    MessageSystemView *tweetComments = [[MessageSystemView alloc] init];
    tweetComments.isDisplayRepostToMyZone = YES;
    tweetComments.tabBarItem.title = @"评论";
    tweetComments.tabBarItem.image = [UIImage imageNamed:@"commentlist"];
    tweetComments.attachment = tweetDetail;
    tweetComments.replyLabelTitle = @"评论此回帖";
    tweetComments.catalog = 3;
    tweetComments.parentID = tweet._id;
    
    tweetTab.viewControllers = [NSArray arrayWithObjects:tweetDetail,tweetComments,nil];
    tweetTab.hidesBottomBarWhenPushed = YES;
    [navController pushViewController:tweetTab animated:YES];
}
+ (void)pushUserDetail:(int)uid andNavController:(UINavigationController *)navController
{
    //如果时匿名用户 则不进入
    if (uid <= 0) {
        return;
    }
    //老式实现
//    UserView *uv = [[UserView alloc] init];
//    uv.hisuid = uid;
//    uv.hidesBottomBarWhenPushed = YES;
//    [navController pushViewController:uv animated:YES];

    UserBlogsView *bv = [[UserBlogsView alloc] init];
    bv.authorUID = uid;
    bv.tabBarItem.title = @"博客";
    bv.tabBarItem.image = [UIImage imageNamed:@"info"];
    
    UserActiveView *av = [[UserActiveView alloc] init];
    av.hisUID = uid;
    av.tabBarItem.title = @"动态";
    av.tabBarItem.image = [UIImage imageNamed:@"active"];
    
    UITabBarController *userTab = [[UITabBarController alloc] init];
    userTab.hidesBottomBarWhenPushed = YES;
    userTab.viewControllers = [NSArray arrayWithObjects:av,bv, nil];
   
    [navController pushViewController:userTab animated:YES];
}
+ (void)pushUserDetailWithName:(NSString *)name andNavController:(UINavigationController *)navController
{
//    NSLog(@"执行一次");
//    UserView *uv = [[UserView alloc] init];
//    uv.hisName = name;
//    uv.hidesBottomBarWhenPushed = YES;
//    [navController pushViewController:uv animated:YES];
    
    UserBlogsView *bv = [[UserBlogsView alloc] init];
    bv.authorName = name;
    bv.tabBarItem.title = @"博客";
    bv.tabBarItem.image = [UIImage imageNamed:@"info"];
    
    UserActiveView *av = [[UserActiveView alloc] init];
    av.hisName = name;
    av.tabBarItem.title = @"动态";
    av.tabBarItem.image = [UIImage imageNamed:@"active"];
    
    UITabBarController *userTab = [[UITabBarController alloc] init];
    userTab.title = name;
    userTab.hidesBottomBarWhenPushed = YES;
    userTab.viewControllers = [NSArray arrayWithObjects:av,bv, nil];
    
    [navController pushViewController:userTab animated:YES];
}
+ (BOOL)analysis:(NSString *)url andNavController:(UINavigationController *)navController
{
    NSString *search = @"oschina.net";
    //判断是否包含 oschina.net 来确定是不是站内链接
    NSRange rng = [url rangeOfString:search];
    if (rng.length <= 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        return NO;
    }
    //站内链接
    else
    {
        url = [url substringFromIndex:7];
        NSString *prefix = [url substringToIndex:3];
        //此情况为 博客,动弹,个人专页
        if ([prefix isEqualToString:@"my."]) 
        {
            NSArray *array = [url componentsSeparatedByString:@"/"];
            //个人专页 用户名形式
            if ([array count] <= 2) {
                [Tool pushUserDetailWithName:[array objectAtIndex:1] andNavController:navController];
                return YES;
            }
            //个人专页 uid形式
            else if([array count] <= 3)
            {
                if ([[array objectAtIndex:1] isEqualToString:@"u"]) {
                    [Tool pushUserDetail:[[array objectAtIndex:2] intValue] andNavController:navController];
                    return YES;
                }
            }
            else if([array count] <= 4)
            {
                NSString *type = [array objectAtIndex:2];
                if ([type isEqualToString:@"blog"]) {
                    News *n = [[News alloc] init];
                    n.newsType = 3;
                    n.attachment = [array objectAtIndex:3];
                    [Tool pushNewsDetail:n andNavController:navController andIsNextPage:NO];
                    return YES;
                }
                else if([type isEqualToString:@"tweet"]){
                    Tweet *t = [[Tweet alloc] init];
                    t._id = [[array objectAtIndex:3] intValue];
                    [Tool pushTweetDetail:t andNavController:navController];
                    return YES;
                }
            }
            else if(array.count <= 5)
            {
                NSString *type = [array objectAtIndex:3];
                if ([type isEqualToString:@"blog"]) {
                    News *n = [[News alloc] init];
                    n.newsType = 3;
                    n.attachment = [array objectAtIndex:4];
                    [Tool pushNewsDetail:n andNavController:navController andIsNextPage:NO];
                    return YES;
                }
            }
        }
        //此情况为 新闻,软件,问答
        else if([prefix isEqualToString:@"www"])
        {
            NSArray *array = [url componentsSeparatedByString:@"/"];
            int count = [array count];
            if (count>=3) {
                NSString *type = [array objectAtIndex:1];
                if ([type isEqualToString:@"news"]) {

                    int newsid = [[array objectAtIndex:2] intValue];
                    News *n = [[News alloc] init];
                    n.newsType = 0;
                    n._id = newsid;
                    [Tool pushNewsDetail:n andNavController:navController andIsNextPage:YES];
                    return YES;
                }
                else if([type isEqualToString:@"p"]){
                    News *n = [[News alloc] init];
                    n.newsType = 1;
                    n.attachment = [array objectAtIndex:2];
                    [Tool pushNewsDetail:n andNavController:navController andIsNextPage:NO];
                    return YES;
                }
                else if([type isEqualToString:@"question"]){
                    if (count == 3) {
                        NSArray *array2 = [[array objectAtIndex:2] componentsSeparatedByString:@"_"];
                        if ([array2 count] >= 2) {
                            int _id = [[array2 objectAtIndex:1] intValue];
                            Post *p = [[Post alloc] init];
                            p._id = _id;
                            [Tool pushPostDetail:p andNavController:navController];
                            return YES;
                        }
                    }
                    else if(count >= 4)
                    {
//                        NSString *tag = [array objectAtIndex:3];
                        NSString *tag = @"";
                        if (array.count == 4) {
                            tag = [array objectAtIndex:3];
                        }
                        else
                        {
                            for (int i=3; i<count-1; i++) {
                                tag = [NSString stringWithFormat:@"%@/%@", [array objectAtIndex:i],[array objectAtIndex:i+1]];
                            }
                        }
                        NSString *tag2 = [tag stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        PostsView *pview = [PostsView new];
                        pview.tag = tag;
                        pview.navigationItem.title = [NSString stringWithFormat:@"%@", tag2];
                        [navController pushViewController:pview animated:YES];
                        return  YES;
                    }
                }
            }
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]]];
        return NO;
   }
}
+ (OSCNotice *)getOSCNotice:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    return [Tool getOSCNotice2:response];
}
+ (OSCNotice *)getOSCNotice2:(NSString *)response
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
    TBXMLElement *root = xml.rootXMLElement;  
    if (!root) {
        return nil;
    }
    TBXMLElement *notice = [TBXML childElementNamed:@"notice" parentElement:root];
    if (!notice) {
        [Config Instance].isLogin = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:@"0"];
        return nil;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:@"1"];
        [Config Instance].isLogin = YES;
    }
    TBXMLElement *atme = [TBXML childElementNamed:@"atmeCount" parentElement:notice];
    TBXMLElement *msg = [TBXML childElementNamed:@"msgCount" parentElement:notice];
    TBXMLElement *review = [TBXML childElementNamed:@"reviewCount" parentElement:notice];
    TBXMLElement *newFans = [TBXML childElementNamed:@"newFansCount" parentElement:notice];
    OSCNotice *oc = [[OSCNotice alloc] initWithParameters:[[TBXML textForElement:atme] intValue] andMsg:[[TBXML textForElement:msg] intValue] andReview:[[TBXML textForElement:review] intValue] andFans:[[TBXML textForElement:newFans] intValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_NoticeUpdate object:oc];
    return oc;
}
+ (void)playAudio:(BOOL)isAlert
{
    NSString * path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath], isAlert ? @"/alertsound.wav" : @"/soundeffect.wav"];
    SystemSoundID soundID;
    NSURL * filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
}
+ (UIColor *)getColorForCell:(int)row
{
    return row % 2 ?
    [UIColor colorWithRed:235.0/255.0 green:242.0/255.0 blue:252.0/255.0 alpha:1.0]:
    [UIColor colorWithRed:248.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
}
+ (void)clearWebViewBackground:(UIWebView *)webView
{
    UIWebView *web = webView;
    for (id v in web.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [v setBounces:NO];
        }
    }
}
+ (void)doSound:(id)sender
{
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"soundeffect" ofType:@"wav"]] error:&err];
    player.volume = 1;
    player.numberOfLoops = 1;
    [player prepareToPlay];
    [player play];
}
+ (void)pushTweetImgDetail:(NSString *)img andParent:(UIViewController *)parent
{
    TweetImgDetail *imgDetail = [[TweetImgDetail alloc] init];
    imgDetail.imgHref = img;
    [parent presentModalViewController:imgDetail animated:YES];
}
+ (NSString *)getTextViewString:(NSString *)author andObjectType:(int)objectType andObjectCatalog:(int)objectCatalog andObjectTitle:(NSString *)title  andMessage:(NSString *)message andPubDate:(NSString *)pubDate andReply:(ObjectReply *)reply
{
    NSString *_author = [NSString stringWithFormat:@"<color>%@</color>",author];
    NSString *_message = @"";
    NSString *_pubDate = [NSString stringWithFormat:@"<small>\n\n%@</small>",pubDate];
    NSString *_reply = @"";
    switch (objectType) {
        case 6:
        {
            _message = [NSString stringWithFormat:@"<light> 发布了一个职位 </light><color>%@</color>\n%@",title,message];
        }
            break;
        case 20:
        {
            _message = [NSString stringWithFormat:@"<light> 在职位 </light><color>%@</color><light> 发表评论:</light>\n%@",title,message];
        }
            break;
        case 32:
        {
            if (objectCatalog == 0) {
                _message = @"<light> 加入了开源中国</light>";
            }
        }
            break;
        case 1:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 添加了开源项目 </light><color>%@</color>\n%@",title,message];
            }
        }
            break;
        case 2:
        {
            if (objectCatalog == 1) {
                _message = [NSString stringWithFormat:@"<light> 在讨论区提问 </light>:<color>%@</color>\n%@",title,message];
            }
            else if(objectCatalog == 2){
                _message = [NSString stringWithFormat:@"<light> 发表了新话题:</light><color>%@</color>\n%@",title,message];
            }
        }
            break;
        case 3:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 发表了博客 </light><color>%@</color>\n%@",title,message];
            }
        }
            break;
        case 4:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 发表一篇新闻 </light><color>%@</color>\n%@",title,message];
            }
        }
            break;
        case 5:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 分享了一段代码 </light><color>%@</color>\n%@",title,message];
            }
        }
            break;
        case 16:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 在新闻 </light><color>%@</color><light> 发表评论</light>\n%@",title,message];
            }
        }
            break;
        case 17:
        {
            if (objectCatalog == 1) {
                _message = [NSString stringWithFormat:@"<light> 回答了问题:</light> <color>%@</color>\n%@",title,message];
            }
            else if(objectCatalog == 2){
                _message = [NSString stringWithFormat:@"<light> 回复了话题:</light> <color>%@</color>\n%@",title,message];
            }
            else if(objectCatalog == 3){
                _message = [NSString stringWithFormat:@"<light> 在 </light><color>%@</color><light> 对回帖发表评论</light>\n%@",title,message];
            }
        }
            break;
        case 18:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 在博客 </light><color>%@</color><light> 发表评论</light>\n%@",title,message];
            }
        }
            break;
        case 19:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 在代码 </light><color>%@</color><light> 发表评论</light>\n%@",title,message];
            }
        }
            break;
        case 100:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 更新了动态</light>\n%@", message];
            }
        }
            break;
        case 101:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<light> 回复了动态</light> \n%@",message];
            }
        }
            break;
    }
    //计算reply
    if (reply) {
        _reply = [NSString stringWithFormat:@"\n<reply>@%@: %@</reply>", reply.objectname, reply.objectbody];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@%@%@",_author,_message,_reply,_pubDate];
    return result;
}
+ (NSString *)getTextViewString2:(NSString *)author andObjectType:(int)objectType andObjectCatalog:(int)objectCatalog andObjectTitle:(NSString *)title andMessage:(NSString *)message andPubDate:(NSString *)pubDate andReply:(ObjectReply *)reply
{
    NSString *_author = @"";
    if (author != nil) {
        _author = [NSString stringWithFormat:@"<font size=14 color='#0D6DA8'>%@</font>",author];
    }
    NSString *_message = @"";
    NSString *_pubDate = @"";
    if (pubDate != nil) {
        _pubDate = [NSString stringWithFormat:@"<font size=12 color='#999999'>\n\n%@</font>",pubDate];
    }
    NSString *_reply = @"";
    switch (objectType) {
        case 6:
        {
            _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 发布了一个职位 </font><font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
        }
            break;
        case 20:
        {
            _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 在职位 </font><font size=14 color='#0D6DA8'>%@</font><font size=14 color='#999999'> 发表评论:</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
        }
            break;
        case 32:
        {
            if (objectCatalog == 0) {
                _message = @"<font size=14 color='#999999'> 加入了开源中国</font>";
            }
        }
            break;
        case 1:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 添加了开源项目 </font><font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 2:
        {
            if (objectCatalog == 1) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 在讨论区提问 </font>:<font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
            else if(objectCatalog == 2){
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 发表了新话题:</font><font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 3:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 发表了博客 </font><font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 4:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 发表一篇新闻 </font><font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 5:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 分享了一段代码 </font><font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 16:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 在新闻 </font><font size=14 color='#0D6DA8'>%@</font><font size=14 color='#999999'> 发表评论</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
            //锁定 objectCataog = 1
        case 17:
        {
            if (objectCatalog == 1) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 回答了问题:</font> <font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
            else if(objectCatalog == 2){
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 回复了话题:</font> <font size=14 color='#0D6DA8'>%@</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
            else if(objectCatalog == 3){
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 在 </font><font size=14 color='#0D6DA8'>%@</font><font size=14 color='#999999'> 对回帖发表评论</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 18:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 在博客 </font><font size=14 color='#0D6DA8'>%@</font><font size=14 color='#999999'> 发表评论</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 19:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 在代码 </font><font size=14 color='#0D6DA8'>%@</font><font size=14 color='#999999'> 发表评论</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",title,message];
            }
        }
            break;
        case 100:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 更新了动态</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>", message];
            }
        }
            break;
        case 101:
        {
            if (objectCatalog == 0) {
                _message = [NSString stringWithFormat:@"<font size=14 color='#999999'> 回复了动态</font>\n<font size=5>\n</font><font size=14><b>%@</b></font>",message];
            }
        }
            break;
    }
    //计算reply
    if (reply) {
        _reply = [NSString stringWithFormat:@"<font size=6>\n\n</font><font size=13 color='#FF4600'>@%@: %@</font>", reply.objectname, reply.objectbody];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@%@%@",_author,_message,_reply,_pubDate];
    return result;
}
+ (NSString *)getAppClientString:(int)appClient
{
    switch (appClient) {
        case 1:
            return @"";
        case 2:
            return @"来自手机";
        case 3:
            return @"来自Android";
        case 4:
            return @"来自iPhone";
        case 5:
            return @"来自Windows Phone";
        default:
            return @"";
    }
}
+ (void)ReleaseWebView:(UIWebView *)webView
{
    [webView stopLoading];
    [webView setDelegate:nil];
    webView = nil;
}
+ (NSString *)intervalSinceNow: (NSString *) theDate 
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        if (cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400>1&&cha/864000<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    else
    {
//        timeString = [NSString stringWithFormat:@"%d-%"]
        NSArray *array = [theDate componentsSeparatedByString:@" "];
//        return [array objectAtIndex:0];
        timeString = [array objectAtIndex:0];
    }
    return timeString;
}
+(int)getTextViewHeight:(UITextView *)txtView andUIFont:(UIFont *)font andText:(NSString *)txt
{
    float fPadding = 16.0;
    CGSize constraint = CGSizeMake(txtView.contentSize.width - 10 - fPadding, CGFLOAT_MAX);
    CGSize size = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float fHeight = size.height + 16.0;
    return fHeight;
}
+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day
{
    return year*365 + month * 31 + day;
}
+ (BOOL)isRepeatNews:(NSMutableArray *)all andNews:(News *)n
{
    if (all == nil) {
        return NO;
    }
    for (News * _n in all) {
        if (_n._id == n._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatPost:(NSMutableArray *)all andPost:(Post *)p
{
    if (all == nil) {
        return NO;
    }
    for (Post *_p in all) {
        if (p._id == _p._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatTweet:(NSMutableArray *)all andTweet:(Tweet *)t
{
    if (all == nil) {
        return NO;
    }
    for (Tweet *_t in all) {
        if (_t._id == t._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatMessage:(NSMutableArray *)all andMessage:(Message *)m
{
    if (all == nil) {
        return NO;
    }
    for (Message *_m in all) {
        if (_m._id == m._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatComment:(NSMutableArray *)all andComment:(Comment *)c
{
    if (all == nil) {
        return NO;
    }
    for (Comment *_c in all) {
        if (_c._id == c._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatActive:(NSMutableArray *)all andActive:(Activity *)a
{
    if (all == nil) {
        return NO;
    }
    for (Activity *_a in all) {
        if (_a._id == a._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatFavorite:(NSMutableArray *)all andFav:(Favorite *)f
{
    if (all == nil) {
        return NO;
    }
    for (Favorite *_f in all) {
        if (_f.objid == f.objid && _f.type == f.type) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatUserBlog:(NSMutableArray *)all andBlogUnit:(BlogUnit *)b
{
    if (all == nil) {
        return NO;
    }
    for (BlogUnit *_b in all) {
        if (_b._id == b._id) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatSearch:(NSMutableArray *)all andResult:(SearchResult *)s
{
    if (all == nil) {
        return NO;
    }
    for (SearchResult * _s in all) {
        if (_s.objid == s.objid && _s.type == s.type) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatFriend:(NSMutableArray *)all andFriend:(Friend *)f
{
    if (all == nil) {
        return NO;
    }
    for (Friend * _f in all) {
        if (_f.userID == f.userID) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatSoftware:(NSMutableArray *)all andSoftware:(SoftwareUnit *)s
{
    if (all == nil) {
        return  NO;
    }
    for (SoftwareUnit *_s in all) {
        if ([_s.name isEqualToString:s.name] && [_s.url isEqualToString:s.url]) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)isRepeatSoftwareCatalog:(NSMutableArray *)all andSoftwareCatalog:(SoftwareCatalog *)s
{
    if (!all) {
        return NO;
    }
    for (SoftwareCatalog *_s in all) {
        if (_s.tag == s.tag) {
            return  YES;
        }
    }
    return NO;
}
+ (UIColor *)getBackgroundColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}
+ (UIColor *)getCellBackgroundColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}
+ (SingleNews *)readStrNewsDetail:(NSString *)str
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *news = [TBXML childElementNamed:@"news" parentElement:root];
    if (news == nil) {
        return nil;
    }
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:news];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:news];
    TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:news];
    TBXMLElement *body = [TBXML childElementNamed:@"body" parentElement:news];
    TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:news];
    TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:news];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:news];
    TBXMLElement *commentCount = [TBXML childElementNamed:@"commentCount" parentElement:news];  
    TBXMLElement *softwarelink = [TBXML childElementNamed:@"softwarelink" parentElement:news];
    TBXMLElement *softwarename = [TBXML childElementNamed:@"softwarename" parentElement:news];
    TBXMLElement *fav = [TBXML childElementNamed:@"favorite" parentElement:news];
    SingleNews * singleNews = [[SingleNews alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url] andBody:[TBXML textForElement:body] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue] andFavorite:[[TBXML textForElement:fav] intValue] == 1];
    singleNews.relativies = [Tool getRelativeNews:str];
    singleNews.softwarelink = [TBXML textForElement:softwarelink];
    singleNews.softwarename = [TBXML textForElement:softwarename];
    
    return singleNews;
}
+ (SinglePostDetail *)readStrSinglePostDetail:(NSString *)str
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *post = [TBXML childElementNamed:@"post" parentElement:root];
    if (post == nil) {
        return nil;
    }
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:post];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:post];
    TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:post];
    TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:post];
    TBXMLElement *body = [TBXML childElementNamed:@"body" parentElement:post];
    TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:post];
    TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:post];
    TBXMLElement *answerCount = [TBXML childElementNamed:@"answerCount" parentElement:post];
    TBXMLElement *viewCount = [TBXML childElementNamed:@"viewCount" parentElement:post];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:post];
    TBXMLElement *fav = [TBXML childElementNamed:@"favorite" parentElement:post];
    
    NSMutableArray *_tags = [[NSMutableArray alloc] initWithCapacity:0];
    TBXMLElement *tags = [TBXML childElementNamed:@"tags" parentElement:post];
    if (tags != nil) {
        TBXMLElement *tag = [TBXML childElementNamed:@"tag" parentElement:tags];
        if (tag != nil) {
            [_tags addObject:[TBXML textForElement:tag]];
            while (tag != nil) {
                tag = [TBXML nextSiblingNamed:@"tag" searchFromElement:tag];
                if (tag != nil) {
                    [_tags addObject:[TBXML textForElement:tag]];
                }
                else 
                    break;
            }
        }
    }
    
    SinglePostDetail * singlePost = [[SinglePostDetail alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url] andPortrait:[TBXML textForElement:portrait] andBody:[TBXML textForElement:body] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andAnswer:[[TBXML textForElement:answerCount] intValue] andView:[[TBXML textForElement:viewCount] intValue] andFavorite:[[TBXML textForElement:fav] intValue] == 1 andTags:_tags];
    return singlePost;
}
+ (Software *)readStrSoftwareDetail:(NSString *)str
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *soft = [TBXML childElementNamed:@"software" parentElement:root];
    if (soft == nil) {
        return nil;
    }
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:soft];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:soft];
    if (!title) {
        return nil;
    }
    TBXMLElement *extensionTitle = [TBXML childElementNamed:@"extensionTitle" parentElement:soft];
    TBXMLElement *license = [TBXML childElementNamed:@"license" parentElement:soft];
    TBXMLElement *body = [TBXML childElementNamed:@"body" parentElement:soft];

    TBXMLElement *homePage = [TBXML childElementNamed:@"homepage" parentElement:soft];
    TBXMLElement *document = [TBXML childElementNamed:@"document" parentElement:soft];
    TBXMLElement *download = [TBXML childElementNamed:@"download" parentElement:soft];
    
    TBXMLElement *logo = [TBXML childElementNamed:@"logo" parentElement:soft];
    TBXMLElement *language = [TBXML childElementNamed:@"language" parentElement:soft];
    TBXMLElement *os = [TBXML childElementNamed:@"os" parentElement:soft];
    TBXMLElement *recordTime = [TBXML childElementNamed:@"recordtime" parentElement:soft];
    TBXMLElement *fav = [TBXML childElementNamed:@"favorite" parentElement:soft];
    Software *s = [[Software alloc] initWithParemters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andExtension:[TBXML textForElement:extensionTitle] andLicense:[TBXML textForElement:license] andBody:[TBXML textForElement:body] andHomepage:[TBXML textForElement:homePage] andDocument:[TBXML textForElement:document] andDownload:[TBXML textForElement:download] andLogo:[TBXML textForElement:logo] andLanguage:[TBXML textForElement:language] andOS:[TBXML textForElement:os] andRecordTime:[TBXML textForElement:recordTime] andFavorite:[[TBXML textForElement:fav] intValue] == 1];
    
    return s;
}
+ (Blog *)readStrBlogDetail:(NSString *)str
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *blog = [TBXML childElementNamed:@"blog" parentElement:root];
    if (blog == nil) {
        return nil;
    }
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:blog];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:blog];
    TBXMLElement *where = [TBXML childElementNamed:@"where" parentElement:blog];
    TBXMLElement *body = [TBXML childElementNamed:@"body" parentElement:blog];
    TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:blog];
    TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:blog];
    TBXMLElement *documentType = [TBXML childElementNamed:@"documentType" parentElement:blog];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:blog];
    TBXMLElement *fav = [TBXML childElementNamed:@"favorite" parentElement:blog];
    TBXMLElement *url = [TBXML childElementNamed:@"url;" parentElement:blog];
    TBXMLElement *commentCount = [TBXML childElementNamed:@"commentCount" parentElement:blog];
    
    
    Blog *b = [[Blog alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andWhere:[TBXML textForElement:where] andBody:[TBXML textForElement:body] andAuthor:[TBXML textForElement:author] andAuthorid:[[TBXML textForElement:authorid] intValue] andDocumentType:[[TBXML textForElement:documentType] intValue] andPubDate:[TBXML textForElement:pubDate] andFavorite:[[TBXML textForElement:fav] intValue] == 1 andUrl:[TBXML textForElement:url] andCommentCount:[[TBXML textForElement:commentCount] intValue]];
    
    return b;
}
+ (NSMutableArray *)readStrNewsArray:(NSString *)str andOld:(NSMutableArray *)olds
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    NSMutableArray *news = [[NSMutableArray alloc] initWithCapacity:20];
    if (!root) {
        return nil;
    }
    //显示
    TBXMLElement *newslist = [TBXML childElementNamed:@"newslist" parentElement:root];
    if (!newslist) {
        return nil;
    }
    TBXMLElement *first = [TBXML childElementNamed:@"news" parentElement:newslist];
    if (first == nil) {
        return news;
    }
    
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:first];
    TBXMLElement *commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
    TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
    TBXMLElement *authorID = [TBXML childElementNamed:@"authorid" parentElement:first];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
    TBXMLElement *newsType = [TBXML childElementNamed:@"newstype" parentElement:first];
    TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:first];
    TBXMLElement *type = [TBXML childElementNamed:@"type" parentElement:newsType];
    TBXMLElement *attachment = [TBXML childElementNamed:@"attachment" parentElement:newsType];
    TBXMLElement *authoruid2 = [TBXML childElementNamed:@"authoruid2" parentElement:newsType];
    
    News *n = [[News alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorID] intValue] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue]];
    n.newsType = [[TBXML textForElement:type] intValue];
    if (attachment) {
        n.attachment = [TBXML textForElement:attachment];
    }
    if (authoruid2) {
        n.authoruid2 = [[TBXML textForElement:authoruid2] intValue];
    }
    if (![Tool isRepeatNews:olds andNews:n]) {
        [news addObject:n];
    }
    while (first != nil) {
        first = [TBXML nextSiblingNamed:@"news" searchFromElement:first];
        if (first) {
            _id = [TBXML childElementNamed:@"id" parentElement:first];
            title = [TBXML childElementNamed:@"title" parentElement:first];
            commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
            author = [TBXML childElementNamed:@"author" parentElement:first];
            authorID = [TBXML childElementNamed:@"authorid" parentElement:first];
            pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
            newsType = [TBXML childElementNamed:@"newstype" parentElement:first];
            url = [TBXML childElementNamed:@"url" parentElement:first];
            type = [TBXML childElementNamed:@"type" parentElement:newsType];
            attachment = [TBXML childElementNamed:@"attachment" parentElement:newsType];
            authoruid2 = [TBXML childElementNamed:@"authoruid2" parentElement:newsType];
            
            n = [[News alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andUrl:[TBXML textForElement:url] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorID] intValue] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andCommentCount:[[TBXML textForElement:commentCount] intValue]];
            n.newsType = [[TBXML textForElement:type] intValue];
            if (attachment) {
                n.attachment = [TBXML textForElement:attachment];
            }
            if (authoruid2) {
                n.authoruid2 = [[TBXML textForElement:authoruid2] intValue];
            }
            if (![Tool isRepeatNews:olds andNews:n]) {
                [news addObject:n];
            }
        }
        else
        {
            break;
        }
    }
    return news;
}
+ (NSMutableArray *)readStrUserBlogsArray:(NSString *)str andOld:(NSMutableArray *)olds
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    NSMutableArray *blogs = [[NSMutableArray alloc] initWithCapacity:20];
    if (!root) {
        return nil;
    }
    //显示
    TBXMLElement *newslist = [TBXML childElementNamed:@"blogs" parentElement:root];
    if (!newslist) {
        return nil;
    }
    TBXMLElement *first = [TBXML childElementNamed:@"blog" parentElement:newslist];
    if (first == nil) {
        return blogs;
    }
    
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:first];
    TBXMLElement *commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
    TBXMLElement *author = [TBXML childElementNamed:@"authorname" parentElement:first];
    TBXMLElement *authorID = [TBXML childElementNamed:@"authoruid" parentElement:first];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
    TBXMLElement *url = [TBXML childElementNamed:@"url" parentElement:first];
    TBXMLElement *documentType = [TBXML childElementNamed:@"documentType" parentElement:first];
    
    BlogUnit *n = [[BlogUnit alloc] initWithParameters:[TBXML textForElement:_id].intValue andUrl:[TBXML textForElement:url] andTitle:[TBXML textForElement:title] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andAuthorName:[TBXML textForElement:author] andAuthorUID:[TBXML textForElement:authorID].intValue andCommentCount:[TBXML textForElement:commentCount].intValue andDocumentType:[TBXML textForElement:documentType].intValue];
    
    if (![Tool isRepeatUserBlog:olds andBlogUnit:n]) {
        [blogs addObject:n];
    }
    while (first != nil) {
        first = [TBXML nextSiblingNamed:@"blog" searchFromElement:first];
        if (first) {
            _id = [TBXML childElementNamed:@"id" parentElement:first];
            title = [TBXML childElementNamed:@"title" parentElement:first];
            commentCount = [TBXML childElementNamed:@"commentCount" parentElement:first];
            author = [TBXML childElementNamed:@"authorname" parentElement:first];
            authorID = [TBXML childElementNamed:@"authoruid" parentElement:first];
            pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
            url = [TBXML childElementNamed:@"url" parentElement:first];
            documentType = [TBXML childElementNamed:@"documentType" parentElement:first];
            
            n = [[BlogUnit alloc] initWithParameters:[TBXML textForElement:_id].intValue andUrl:[TBXML textForElement:url] andTitle:[TBXML textForElement:title] andPubDate:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andAuthorName:[TBXML textForElement:author] andAuthorUID:[TBXML textForElement:authorID].intValue andCommentCount:[TBXML textForElement:commentCount].intValue andDocumentType:[TBXML textForElement:documentType].intValue];

            if (![Tool isRepeatUserBlog:olds andBlogUnit:n]) {
                [blogs addObject:n];
            }
        }
        else
        {
            break;
        }
    }
    return blogs;
}
+ (NSMutableArray *)readStrPostArray:(NSString *)str andOld:(NSMutableArray *)olds
{
    NSMutableArray * newPosts = [[NSMutableArray alloc] initWithCapacity:20];
    TBXML *xml = [[TBXML alloc] initWithXMLString:str error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *postlist = [TBXML childElementNamed:@"posts" parentElement:root];
    TBXMLElement *first = [TBXML childElementNamed:@"post" parentElement:postlist];
    if (first == nil) {
        return nil;
    }
    TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
    TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
    TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:first];
    TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
    TBXMLElement *authorID = [TBXML childElementNamed:@"authorid" parentElement:first];
    TBXMLElement *answerCount = [TBXML childElementNamed:@"answerCount" parentElement:first];
    TBXMLElement *viewCount = [TBXML childElementNamed:@"viewCount" parentElement:first];
    TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
    Post *p = [[Post alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andAnswer:[[TBXML textForElement:answerCount] intValue] andView:[[TBXML textForElement:viewCount] intValue] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorID] intValue] andFromNowOn:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andImg:[TBXML textForElement:portrait]];
    if (![Tool isRepeatPost:olds andPost:p]) {
        [newPosts addObject:p];
    }
    while (first != nil) 
    {
        first = [TBXML nextSiblingNamed:@"post" searchFromElement:first];
        if (first) {
            _id = [TBXML childElementNamed:@"id" parentElement:first];
            portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
            title = [TBXML childElementNamed:@"title" parentElement:first];
            author = [TBXML childElementNamed:@"author" parentElement:first];
            authorID = [TBXML childElementNamed:@"authorid" parentElement:first];
            answerCount = [TBXML childElementNamed:@"answerCount" parentElement:first];
            viewCount = [TBXML childElementNamed:@"viewCount" parentElement:first];
            pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
            p = [[Post alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andTitle:[TBXML textForElement:title] andAnswer:[[TBXML textForElement:answerCount] intValue] andView:[[TBXML textForElement:viewCount] intValue] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorID] intValue] andFromNowOn:[Tool intervalSinceNow:[TBXML textForElement:pubDate]] andImg:[TBXML textForElement:portrait]];
            if (![Tool isRepeatPost:olds andPost:p]) {
                [newPosts addObject:p];
            }
        }
        else
        {
            break;
        }
    }
    return newPosts;
}
+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}
+ (void)saveSoftware:(NSString *)softwareName andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"detail-%d-%@",3, softwareName];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getSoftware:(NSString *)softwareName
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%d-%@",3, softwareName];
    
    NSString *value = [settings objectForKey:key];
    return value;
}
+ (void)deleteAllCache
{
}
+ (NSMutableArray *)getReplies:(TBXMLElement *)first
{
    TBXMLElement *replies = [TBXML childElementNamed:@"replies" parentElement:first];
    if (!replies) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    TBXMLElement *reply = [TBXML childElementNamed:@"reply" parentElement:replies];
    TBXMLElement *rauthor;
    TBXMLElement *rpubDate;
    TBXMLElement *rcontent;
    if (reply) {
        rauthor = [TBXML childElementNamed:@"rauthor" parentElement:reply];
        rpubDate = [TBXML childElementNamed:@"rpubDate" parentElement:reply];
        rcontent = [TBXML childElementNamed:@"rcontent" parentElement:reply];
        [result addObject:[NSString stringWithFormat:@"%@(%@): %@",[TBXML textForElement:rauthor], [Tool intervalSinceNow:[TBXML textForElement:rpubDate]], [TBXML textForElement:rcontent]]];
    }
    while (reply) {
        reply = [TBXML nextSiblingNamed:@"reply" searchFromElement:reply];
        if (reply) {
            rauthor = [TBXML childElementNamed:@"rauthor" parentElement:reply];
            rpubDate = [TBXML childElementNamed:@"rpubDate" parentElement:reply];
            rcontent = [TBXML childElementNamed:@"rcontent" parentElement:reply];
            [result addObject:[NSString stringWithFormat:@"%@(%@): %@",[TBXML textForElement:rauthor], [Tool intervalSinceNow:[TBXML textForElement:rpubDate]], [TBXML textForElement:rcontent]]];
        }
        else
        {
            break;
        }
    }
    return result;
}
+ (NSMutableArray *)getRefers:(TBXMLElement *)first
{
    TBXMLElement *refers = [TBXML childElementNamed:@"refers" parentElement:first];
    if (!refers) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:5];
    TBXMLElement *refer = [TBXML childElementNamed:@"refer" parentElement:refers];
    TBXMLElement *title;
    TBXMLElement *body;
    if (refer) {
        title = [TBXML childElementNamed:@"refertitle" parentElement:refer];
        body = [TBXML childElementNamed:@"referbody" parentElement:refer];
        [result addObject:[[CommentRefer alloc] initWithParamters:[TBXML textForElement:title] andBody:[TBXML textForElement:body]]];
    }
    while (refer) {
        title = body = nil;
        refer = [TBXML nextSiblingNamed:@"refer" searchFromElement:refer];
        if (refer) {
            title = [TBXML childElementNamed:@"refertitle" parentElement:refer];
            body = [TBXML childElementNamed:@"referbody" parentElement:refer];
            [result addObject:[[CommentRefer alloc] initWithParamters:[TBXML textForElement:title] andBody:[TBXML textForElement:body]]];
        }
        else
        {
            break;
        }
    }
    return result;
}
+ (UIView *)getReferView:(NSMutableArray *)refers
{
    if (refers == nil || refers.count == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(49, 23, 260, 3+36*(refers.count-1)+36)];
    view.backgroundColor = [UIColor colorWithRed:185.0/255 green:220.0/255 blue:1.0 alpha:1.0];
    for (int i=0; i<refers.count; i++) {
        
        CommentRefer *cr = (CommentRefer *)[refers objectAtIndex:i];
        
        UILabel *lbl_Title = [[UILabel alloc] initWithFrame:CGRectMake(3, 3+36*i, 254, 16)];
        lbl_Title.text = cr.title;
        lbl_Title.font = [UIFont boldSystemFontOfSize:12.0];
        lbl_Title.textColor = [UIColor colorWithRed:117.0/255 green:117.5/255 blue:117.0/255 alpha:1.0];
        lbl_Title.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:228.0/255 alpha:1.0];
        
        UILabel *lbl_Body = [[UILabel alloc] initWithFrame:CGRectMake(3, 3+36*i+19, 254, 16)];
        lbl_Body.text = cr.body;
        lbl_Body.textColor = [UIColor darkGrayColor];
        lbl_Body.font = [UIFont boldSystemFontOfSize:13.0];;
        lbl_Body.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        
        [view addSubview:lbl_Title];
        [view addSubview:lbl_Body];
    }
    
    return view;
}
+ (NSString *)getHTMLString:(NSString *)html
{
    return html;
}
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;
//    hud.dimBackground = YES;
    hud.square = YES;
    [hud show:YES];
}
+ (int)isListOver:(ASIHTTPRequest *)request
{
    return [Tool isListOver2:request.responseString];
}
+ (int)isListOver2:(NSString *)response
{
    TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *pageSize = [TBXML childElementNamed:@"pagesize" parentElement:root];
    int size = [[TBXML textForElement:pageSize] intValue];
    return size;
}
+ (void)doWithFavorite:(BOOL)addFavorite andUID:(int)uid andObjID:(int)objID andType:(int)type andDelegate:(UIViewController *)viewController andRequest:(ASIFormDataRequest *)request
{
    request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addFavorite ? api_favorite_add : api_favorite_delete]];
    request.attachment = addFavorite ? @"add" : @"delete";
    [request setUseCookiePersistence:[Config Instance].isCookie];
    [request setPostValue:[NSString stringWithFormat:@"%d", uid] forKey:@"uid"];
    [request setPostValue:[NSString stringWithFormat:@"%d", objID] forKey:@"objid"];
    [request setPostValue:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestFavoriteAction:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:viewController.view];
    [Tool showHUD:addFavorite ? @"正在添加收藏":@"正在删除收藏" andView:viewController.view andHUD:request.hud];
}
+ (UIImage *)scale:(UIImage *)sourceImg toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [sourceImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    }
    else
    {
        return CGSizeMake(800 * width / height, 800);
    }
}
+ (NSString *)getOSVersion
{
    return [NSString stringWithFormat:@"OSChina.NET/%@/%@/%@/%@",AppVersion,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion, [UIDevice currentDevice].model];
}
+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom
{
    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc] initWithText:text showActivity:isLoading inPresentationMode:isBottom?GCDiscreetNotificationViewPresentationModeBottom:GCDiscreetNotificationViewPresentationModeTop inView:view];
    [notificationView show:YES];
    [notificationView hideAnimatedAfter:2.6];
}
+ (void)CancelRequest:(ASIHTTPRequest *)request
{
    if (request != nil) {
        [request cancel];
        [request clearDelegatesAndCancel];
    }
}
+ (NSDate *)NSStringDateToNSDate:(NSString *)string
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * d = [f dateFromString:string];
    return d;
}
+ (NSString *)GenerateTags:(NSMutableArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    }
    else
    {
        NSString *result = @"";
        for (NSString *t in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;",result,t,t];
        }
        return result;
    }
}


@end












