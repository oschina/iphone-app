//
//  SettingView.m
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingView.h"


@implementation SettingView
@synthesize tableSettings;
@synthesize settings;
@synthesize settingsInSection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"更多";
        self.tabBarItem.title = @"更多";
        self.tabBarItem.image = [UIImage imageNamed:@"more"];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.settingsInSection = [[NSMutableDictionary alloc] initWithCapacity:3];
    BOOL isLogin = [Config Instance].isCookie;
    NSArray *first = [[NSArray alloc] initWithObjects:
                      [[SettingModel alloc] initWith:isLogin ? @"我的资料 (收藏/关注/粉丝)":@"登录" andImg:@"account" andTag:1 andTitle2:nil],
                      [[SettingModel alloc] initWith: @"注销" andImg:@"exit" andTag:2 andTitle2:nil],
                      nil];
    NSArray *second = [[NSArray alloc] initWithObjects:
                       [[SettingModel alloc] initWith:@"软件" andImg:@"software" andTag:3 andTitle2:nil],
                       [[SettingModel alloc] initWith:@"搜索" andImg:@"search" andTag:4 andTitle2:nil],
                       nil];
    NSArray *third = [[NSArray alloc] initWithObjects:
                      [[SettingModel alloc] initWith:@"意见反馈" andImg:@"feedback" andTag:5 andTitle2:nil],
                      [[SettingModel alloc] initWith:@"官方微博" andImg:@"weibo" andTag:6 andTitle2:nil], 
                      [[SettingModel alloc] initWith:@"关于我们" andImg:@"logo" andTag:7 andTitle2:nil],
                      [[SettingModel alloc] initWith:@"检测更新" andImg:@"setting" andTag:8 andTitle2:nil],
                      [[SettingModel alloc] initWith:@"给我评分" andImg:@"rating" andTag:9 andTitle2:nil],
                      nil];
    [self.settingsInSection setObject:first forKey:@"帐号"];
    [self.settingsInSection setObject:second forKey:@"反馈"];
    [self.settingsInSection setObject:third forKey:@"关于"];
    self.settings = [[NSArray alloc] initWithObjects:@"帐号",@"反馈",@"关于",nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:[Config Instance].isCookie ? @"1" : @"0"];
    [self refresh];
}
- (void)viewDidUnload
{
    [self setTableSettings:nil];
    [super viewDidUnload];
}
- (void)refresh
{
    NSArray *first = [self.settingsInSection objectForKey:@"帐号"];
    SettingModel *firstLogin = [first objectAtIndex:0];
    firstLogin.title = [Config Instance].isCookie ? @"我的资料 (收藏/关注/粉丝)" : @"登录";
    [self.tableSettings reloadData];
}
#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [indexPath section];
    NSString *key = [settings objectAtIndex:section];
    NSArray *sets = [settingsInSection objectForKey:key];
    SettingModel *action = [sets objectAtIndex:[indexPath row]];
    //开始处理
    switch (action.tag) {
            //帐号管理
        case 1:
        {
            if ([Config Instance].isCookie) 
            {
                //进入资料页
                MyView * myView = [[MyView alloc] init];
                myView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:myView animated:YES];
            }
            else
            {
                LoginView *login = [[LoginView alloc] init];
                login.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:login animated:YES];
            }
        }
            break;
            //注销
        case 2:
        {
            if ([Config Instance].isCookie == NO) {
                [Tool ToastNotification:@"错误 您还没有登录,注销无效" andView:self.view andLoading:NO andIsBottom:NO];
                return;
            }

            [ASIHTTPRequest setSessionCookies:nil];
            [ASIHTTPRequest clearSession];
            [Config Instance].isLogin = NO;
            [[Config Instance] saveCookie:NO];
            
            [self refresh];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:@"0"];
            [Tool ToastNotification:@"注销成功" andView:self.view andLoading:NO andIsBottom:NO];
        }
            break;
        case 3:
        {
            SoftwaresBase * s = [[SoftwaresBase alloc] init];
            s.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:s animated:YES];
        }
            break;
        case 4:
        {
            SearchView * sView = [[SearchView alloc] init];
            sView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:sView animated:YES];
        }
            break;
            //关注微博
        case 6:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.weibo.com/oschina2010"]];
        }
            break;
            //发送邮件
        case 5:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:oschina.net@gmail.com"]];
        }
            break;
        case 7:
        {
            About *about = [About new];
            about.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:about animated:YES];
        }
            break;
        case 8:
        {
            [self checkVersionNeedUpdate];
        }
            break;
        case 9:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=524298520"]];
        }
            break;
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [settings count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [settings objectAtIndex:section];
    NSArray *set = [settingsInSection objectForKey:key];
    return [set count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *key = [settings objectAtIndex:section];
    NSArray *sets = [settingsInSection objectForKey:key];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingTableIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingTableIdentifier];
    }
    SettingModel *model = [sets objectAtIndex:row];
    cell.textLabel.text = model.title;
    cell.imageView.image = [UIImage imageNamed:model.img];
    cell.tag = model.tag;
    return cell;
}

#pragma 按钮点击后的API方法

- (void)checkVersionNeedUpdate
{
    [[AFOSCClient sharedClient] getPath:@"http://www.oschina.net/MobileAppVersion.xml" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSLog(operation.responseString);
            TBXML *xml = [[TBXML alloc] initWithXMLString:operation.responseString error:nil];
            TBXMLElement *root = xml.rootXMLElement;
            if (root == nil) {
                [Tool ToastNotification:@"获取版本信息错误" andView:self.view andLoading:NO andIsBottom:NO];
                return;
            }
            TBXMLElement *update = [TBXML childElementNamed:@"update" parentElement:root];
            if (update == nil) {
                [Tool ToastNotification:@"获取个人信息错误" andView:self.view andLoading:NO andIsBottom:NO];
                return;
            }
            TBXMLElement *ios = [TBXML childElementNamed:@"ios" parentElement:update];
            
            NSString * version = [TBXML textForElement:ios];
            if ([SettingView getVersionNumber:version]>[SettingView getVersionNumber:AppVersion]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"开源中国iPhone客户端有新版了\n您需要下载吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                [alert show];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您当前已经是最新版本" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        @catch (NSException *exception) {
            [NdUncaughtExceptionHandler TakeException:exception];
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
    }];
    
}
+ (int)getVersionNumber:(NSString *)version
{
    NSArray * arr = [version componentsSeparatedByString:@"."];
    if (arr.count >= 3) {
        NSString * a = [arr objectAtIndex:0];
        NSString * b = [arr objectAtIndex:1];
        NSString * c = [arr objectAtIndex:2];
        return a.intValue * 100 + b.intValue * 10 + c.intValue;
    }
    else
        return 0;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //下载
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=524298520"]];
    }
}
@end
