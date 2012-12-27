//
//  UserView2.m
//  oschina
//
//  Created by wangjun on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserView2.h"

@implementation UserView2
@synthesize tableInfo;
@synthesize infos;
@synthesize hisUID;
@synthesize hisName;
@synthesize egoImgView;
@synthesize relationShip;
@synthesize btnRelation;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableInfo.hidden = YES;
    self.navigationItem.title = self.hisName;

    self.btnRelation = [[UIBarButtonItem alloc] initWithTitle:@"关注Ta" style:UIBarButtonItemStyleBordered target:self action:@selector(clickRelation:)];
    self.navigationItem.rightBarButtonItem = self.btnRelation;
    
    self.egoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(40, 25, 50, 50)];
    self.egoImgView.image = [UIImage imageNamed:@"big_avatar_loading.png"];
    [self.view addSubview:self.egoImgView];
    
    //信息初始化
    infos = [NSArray arrayWithObjects:
              [[SettingModel alloc] initWith:@"最近登录" andImg:nil andTag:0 andTitle2:nil],
              [[SettingModel alloc] initWith:@"性       别" andImg:nil andTag:0 andTitle2:nil],
              [[SettingModel alloc] initWith:@"来       自" andImg:nil andTag:0 andTitle2:nil],
              [[SettingModel alloc] initWith:@"加入时间" andImg:nil andTag:0 andTitle2:nil],
              [[SettingModel alloc] initWith:@"专长领域" andImg:nil andTag:0 andTitle2:nil],
              [[SettingModel alloc] initWith:@"开发平台" andImg:nil andTag:0 andTitle2:nil],nil];
    self.tableInfo.delegate = self;
    
    //加载
    [self getUserInfo];
}


-(void)getUserInfo
{
    NSString *url;
    if (self.hisName != nil && self.hisName.length > 0) {
        url = [NSString stringWithFormat:@"%@?uid=%d&hisname=%@&pageIndex=0&pageSize=1",api_user_information,[Config Instance].getUID, self.hisName];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?uid=%d&hisuid=%d&pageIndex=0&pageSize=1",api_user_information,[Config Instance].getUID,self.hisUID];
    }
    
    [[AFOSCClient sharedClient] getPath:url
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    self.tableInfo.hidden = NO;
                                    [Tool getOSCNotice2:operation.responseString];
                                    
                                    @try {
                                        TBXML *xml = [[TBXML alloc] initWithXMLString:operation.responseString error:nil];
                                        TBXMLElement *root = xml.rootXMLElement;
                                        if (root == nil) {
                                            [Tool ToastNotification:@"获取个人信息错误" andView:self.view andLoading:NO andIsBottom:NO];
                                            return;
                                        }
                                        TBXMLElement *user = [TBXML childElementNamed:@"user" parentElement:root];
                                        if (user == nil) {
                                            [Tool ToastNotification:@"获取个人信息错误" andView:self.view andLoading:NO andIsBottom:NO];
                                            return;
                                        }
                                        TBXMLElement *relation = [TBXML childElementNamed:@"relation" parentElement:user];
                                        TBXMLElement *hisportrait = [TBXML childElementNamed:@"portrait" parentElement:user];
                                        TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:user];
                                        self.hisName = [TBXML textForElement:name];
                                        TBXMLElement *uid = [TBXML childElementNamed:@"uid" parentElement:user];
                                        self.hisUID = [TBXML textForElement:uid].intValue;
                                        TBXMLElement *jointime = [TBXML childElementNamed:@"jointime" parentElement:user];
                                        TBXMLElement *from = [TBXML childElementNamed:@"from" parentElement:user];
                                        TBXMLElement *gender = [TBXML childElementNamed:@"gender" parentElement:user];
                                        TBXMLElement *devplatform = [TBXML childElementNamed:@"devplatform" parentElement:user];
                                        TBXMLElement *expertise = [TBXML childElementNamed:@"expertise" parentElement:user];
                                        TBXMLElement *latestoneline = [TBXML childElementNamed:@"latestonline" parentElement:user];
                                        
                                        SettingModel *m1 = [infos objectAtIndex:0];
                                        m1.title2 = [Tool intervalSinceNow:[TBXML textForElement:latestoneline]];
                                        
                                        SettingModel *m2 = [infos objectAtIndex:1];
                                        m2.title2 = [TBXML textForElement:gender];
                                        
                                        SettingModel *m3 = [infos objectAtIndex:2];
                                        m3.title2 = [TBXML textForElement:from];
                                        
                                        SettingModel *m4 = [infos objectAtIndex:3];
                                        m4.title2 = [TBXML textForElement:jointime];
                                        
                                        SettingModel *m5 = [infos objectAtIndex:4];
                                        m5.title2 = [TBXML textForElement:expertise];
                                        
                                        SettingModel *m6 = [infos objectAtIndex:5];
                                        m6.title2 = [TBXML textForElement:devplatform];
                                        [self.tableInfo reloadData];
                                        
                                        NSString *portrait_str = [TBXML textForElement:hisportrait];
                                        if ([portrait_str isEqualToString:@""]) 
                                        {
                                            self.egoImgView.image = [UIImage imageNamed:@"big_avatar.png"];
                                        }
                                        else
                                        {
                                            self.egoImgView.image = nil;
                                            self.egoImgView.imageURL = [NSURL URLWithString:portrait_str];
                                        }
                                        
                                        relationShip = [[TBXML textForElement:relation] intValue];
                                        //更改按钮的字符
                                        switch (relationShip) {
                                            case 1:
                                            {
                                                btnRelation.title = @"取消互粉";
                                            }
                                                break;
                                            case 2:
                                            {
                                                btnRelation.title = @"取消关注";
                                            }
                                                break;
                                            case 3:
                                            case 4:
                                            {
                                                btnRelation.title = @"关注Ta";
                                            }
                                                break;
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

-(void)clickRelation:(id)sender
{
    if ([Config Instance].isCookie == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@"请您先登录"];
        return;
    }
    //根据现在关系决定用户能做的操作 
    int newrelation = 0;
    switch (relationShip) {
        case 1:
        case 2:
            //进行取消关注操作
        {
            newrelation = 0;
        }
            break;
            //进行关注操作
        case 3:
        {
            newrelation = 1;
        }
            break;
    }
    NSString *url = [NSString stringWithFormat:@"%@?uid=%d&hisuid=%d&newrelation=%d",api_user_updaterelation,[Config Instance].getUID,hisUID,newrelation];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在载入信息" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient] getPath:url parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    [hud hide:YES];
                                    //重新刷新
                                    ApiError *error = [Tool getApiError2:operation.responseString];
                                    if (error == nil) {
                                        [Tool ToastNotification:operation.responseString andView:self.view andLoading:NO andIsBottom:NO];
                                        return ;
                                    }
                                    [Tool getOSCNotice2:operation.responseString];
                                    switch (error.errorCode) {
                                        case 1:
                                        {
                                            [self getUserInfo];
                                        }
                                            break;
                                        case 0:
                                        case -2:
                                        case -1:
                                        {
                                            [Tool ToastNotification:@"操作失败" andView:self.view  andLoading:self andIsBottom:NO];
                                            return;
                                        }
                                            break;
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [hud hide:YES];
                                    [Tool ToastNotification:@"网络连接故障" andView:self.view andLoading:NO andIsBottom:NO];
                                }];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.navigationController andParent:self];
}
- (void)viewDidUnload
{
    self.egoImgView = nil;
    [self setTableInfo:nil];
    [super viewDidUnload];
}

- (IBAction)click_AT:(id)sender {
    
    if (hisName == nil || [hisName isEqualToString:@""]) {
        return;
    }
    if ([Config Instance].isLogin == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@"请先登录后再发表动弹"];
        return;
    }
    PubTweet * pubTweet = [[PubTweet alloc] init];
    pubTweet.hidesBottomBarWhenPushed = YES;
    pubTweet.atSomebody = [NSString stringWithFormat:@"@%@ ", self.hisName];
    [self.navigationController pushViewController:pubTweet animated:YES];
}

- (IBAction)click_PubMesssge:(id)sender {
    if ([Config Instance].isCookie == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@"请先登录再发留言"];
        return;
    }
    PubMessage *pubMessage = [[PubMessage alloc] init];
    pubMessage.isFromUserView = YES;
    if (self.hisName != nil && self.hisName.length > 0) {
        pubMessage.receiver = hisName;
        pubMessage.receiverid = hisUID;
        [self.navigationController pushViewController:pubMessage animated:YES];
    }
}

#pragma TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:MyInfoCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyInfoCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[MyInfoCell class]]) {
                cell = (MyInfoCell *)o;
                break;
            }
        }
    }
    cell.lblTitle.font = [UIFont boldSystemFontOfSize:15.0];
    cell.lblContent.font = [UIFont boldSystemFontOfSize:15.0];
    SettingModel * m = [infos objectAtIndex:indexPath.row];
    if (m != nil) {
        cell.lblTitle.text = m.title;
        cell.lblContent.text = m.title2;
    }
    return cell;
}

@end
