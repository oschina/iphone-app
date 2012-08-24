//
//  UserView2.h
//  oschina
//
//  Created by wangjun on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenu.h"
#import "QuadCurveMenuItem.h"
#import "UserActiveView.h"
#import "UserBlogsView.h"
#import "EGOImageView.h"
#import "SettingModel.h"
#import "MyInfoCell.h"

@interface UserView2 : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>

@property int hisUID;
@property (retain,nonatomic) NSString * hisName;

@property (strong,nonatomic) EGOImageView * egoImgView;
@property int relationShip;
@property (strong,nonatomic) UIBarButtonItem * btnRelation;
- (IBAction)click_AT:(id)sender;
- (IBAction)click_PubMesssge:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView * tableInfo;
@property (nonatomic, retain) NSArray * infos;
-(void)getUserInfo;

@end
