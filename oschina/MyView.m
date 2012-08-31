//
//  MyView.m
//  oschina
//
//  Created by wangjun on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyView.h"

@implementation MyView
@synthesize imgGender;
@synthesize lblName;
@synthesize tableInformation;
@synthesize egoImgView;
@synthesize settings;
@synthesize settingsInSection;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"我的资料";
    self.lblName.font = [UIFont boldSystemFontOfSize:20.0];
    self.egoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(18, 16, 50, 50)];
    self.egoImgView.image = [UIImage imageNamed:@"big_avatar_loading.png"];
    [self.view addSubview:self.egoImgView];
    
    [self reload];

    self.settingsInSection = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    first = [[NSArray alloc] initWithObjects:
             [[SettingModel alloc] initWith:@"收藏" andImg:nil andTag:0 andTitle2:nil],
             nil];
    second = [[NSArray alloc] initWithObjects:
              [[SettingModel alloc] initWith:@"粉丝" andImg:nil andTag:1 andTitle2:nil],
              [[SettingModel alloc] initWith:@"关注" andImg:nil andTag:2 andTitle2:nil],
              nil];
    third = [[NSArray alloc] initWithObjects:
               [[SettingModel alloc] initWith:nil andImg:nil andTag:3 andTitle2:@"加入时间"],
               [[SettingModel alloc] initWith:nil andImg:nil andTag:4 andTitle2:@"所在地区"],
               [[SettingModel alloc] initWith:nil andImg:nil andTag:5 andTitle2:@"开发平台"],
               [[SettingModel alloc] initWith:nil andImg:nil andTag:6 andTitle2:@"专长领域"],
                nil];
    [self.settingsInSection setObject:first forKey:@"信息"];
    [self.settingsInSection setObject:second forKey:@"好友"];
    [self.settingsInSection setObject:third forKey:@"收藏"];
    self.settings = [[NSArray alloc] initWithObjects:@"信息",@"好友",@"收藏",nil];
}
#pragma mark 更新头像
- (IBAction)clickUpdatePortrait:(id)sender {
    
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
    UIImage * photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    SSPhotoCropperViewController *photoCropper =
    [[SSPhotoCropperViewController alloc] initWithPhoto:photo
                                               delegate:self
                                                 uiMode:SSPCUIModePresentedAsModalViewController
                                        showsInfoButton:NO];
    [photoCropper setMinZoomScale:0.25f];
    [photoCropper setMaxZoomScale:4.0f];
    [self.navigationController pushViewController:photoCropper animated:YES];
}
- (void) photoCropper:(SSPhotoCropperViewController *)photoCropper
         didCropPhoto:(UIImage *)photo
{
    [self.navigationController popViewControllerAnimated:YES];
    
    //对photo进行处理
    [[MyThread Instance] startUpdatePortrait:UIImageJPEGRepresentation(photo, 0.75f)];
    [Tool ToastNotification:@"正在上传您的头像" andView:self.view andLoading:YES andIsBottom:NO];
}

- (void) photoCropperDidCancel:(SSPhotoCropperViewController *)photoCropper
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)reload
{
    NSString * url = [NSString stringWithFormat:@"%@?uid=%d",api_my_information,[Config Instance].getUID];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在获取信息" andView:self.view andHUD:hud];
    [[AFOSCClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
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
            TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:user];
            TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:user];
            TBXMLElement *joinTime = [TBXML childElementNamed:@"jointime" parentElement:user];
            TBXMLElement *gender = [TBXML childElementNamed:@"gender" parentElement:user];
            TBXMLElement *from = [TBXML childElementNamed:@"from" parentElement:user];
            TBXMLElement *dev = [TBXML childElementNamed:@"devplatform" parentElement:user];
            TBXMLElement *expertise = [TBXML childElementNamed:@"expertise" parentElement:user];
            TBXMLElement *favoritecount = [TBXML childElementNamed:@"favoritecount" parentElement:user];
            TBXMLElement *fanscount = [TBXML childElementNamed:@"fanscount" parentElement:user];
            TBXMLElement *followerscount = [TBXML childElementNamed:@"followerscount" parentElement:user];
            
            fansCount = [[TBXML textForElement:fanscount] intValue];
            followersCount = [[TBXML textForElement:followerscount] intValue];
            
            //头像
            NSString *portrait_str = [TBXML textForElement:portrait];
            if ([portrait_str isEqualToString:@""]) 
            {
                self.egoImgView.image = [UIImage imageNamed:@"big_avatar.png"];
            }
            else
            {
                self.egoImgView.imageURL = [NSURL URLWithString:portrait_str];
            }  
            
            //性别于姓名
            self.lblName.text = [TBXML textForElement:name];
            if ([[TBXML textForElement:gender] intValue] == 1) {
                self.imgGender.image = [UIImage imageNamed:@"man.png"];
            }
            else {
                self.imgGender.image = [UIImage imageNamed:@"woman.png"];
            }
            first = [[NSArray alloc] initWithObjects:
                     [[SettingModel alloc] initWith:[NSString stringWithFormat:@"收藏 (%@)",[TBXML textForElement:favoritecount]] andImg:nil andTag:0 andTitle2:nil],
                     nil];
            second = [[NSArray alloc] initWithObjects:
                      [[SettingModel alloc] initWith:[NSString stringWithFormat:@"粉丝 (%@)",[TBXML textForElement:fanscount]] andImg:nil andTag:1 andTitle2:nil],
                      [[SettingModel alloc] initWith:[NSString stringWithFormat:@"关注 (%@)",[TBXML textForElement:followerscount]] andImg:nil andTag:2 andTitle2:nil],
                      nil];

            third = [[NSArray alloc] initWithObjects:
                     [[SettingModel alloc] initWith:[Tool intervalSinceNow:[TBXML textForElement:joinTime]] andImg:nil andTag:3 andTitle2:@"加入时间"],
                     [[SettingModel alloc] initWith:[TBXML textForElement:from] andImg:nil andTag:4 andTitle2:@"所在地区"],
                     [[SettingModel alloc] initWith:[TBXML textForElement:dev] andImg:nil andTag:5 andTitle2:@"开发平台"],
                     [[SettingModel alloc] initWith:[TBXML textForElement:expertise] andImg:nil andTag:6 andTitle2:@"专长领域"],
                     nil];
            [self.settingsInSection setObject:first forKey:@"信息"];
            [self.settingsInSection setObject:second forKey:@"好友"];
            [self.settingsInSection setObject:third forKey:@"收藏"];
            self.settings = [[NSArray alloc] initWithObjects:@"信息",@"好友",@"收藏",nil];
            [self.tableInformation reloadData];
        }
        @catch (NSException *exception) {
            [NdUncaughtExceptionHandler TakeException:exception];
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [Tool ToastNotification:@"网络连接错误" andView:self.view andLoading:NO andIsBottom:NO];
    }];
}
- (void)viewDidUnload
{
    [self setImgGender:nil];
    [self setLblName:nil];
    [self setTableInformation:nil];
    [super viewDidUnload];
}

#pragma TableView的处理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [indexPath section];
    NSString * key = [settings objectAtIndex:section];
    NSArray * sets = [settingsInSection objectForKey:key];
    SettingModel *action = [sets objectAtIndex:[indexPath row]];
    switch (action.tag) {
        //收藏
        case 0:
        {
            FavoritesView * favView = [[FavoritesView alloc] init];
            [self.navigationController pushViewController:favView animated:YES];
        }
            break;
        //粉丝
        case 1:
        {
            FriendsView * view = [[FriendsView alloc] init];
            view.isFansType = YES;
            view.fansCount = fansCount;
            view.followersCount = followersCount;
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        //关注者
        case 2:
        {
            FriendsView * view = [[FriendsView alloc] init];
            view.isFansType = NO;
            view.fansCount = fansCount;
            view.followersCount = followersCount;
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        default:
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [settings count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [settings objectAtIndex:section];
    NSArray *set = [settingsInSection objectForKey:key];
    return [set count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *key = [settings objectAtIndex:section];
    NSArray *sets = [settingsInSection objectForKey:key];
    SettingModel *model = [sets objectAtIndex:row];
    switch (section) {
        case 0:
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingTableIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingTableIdentifier];
            }
            cell.textLabel.text = model.title;
            cell.imageView.image = [UIImage imageNamed:model.img];
            cell.tag = model.tag;
            return cell;
        }
            break;
        case 2:
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
            cell.lblTitle.text = model.title2;
            cell.lblContent.font = [UIFont boldSystemFontOfSize:15.0];
            cell.lblContent.text = model.title;
            cell.tag = model.tag;
            return cell;
        }
            break;
        default:
            return nil;
    }
}
@end
