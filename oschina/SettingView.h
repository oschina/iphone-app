//
//  SettingView.h
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingModel.h"
#import "About.h"
#import "LoginView.h"
#import "SearchView.h"
#import "SoftwareView.h"
#import "SoftwareTypeView.h"
#import "SoftwaresBase.h"
#import "MyView.h"

@interface SettingView : UIViewController<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray * settings;
    NSMutableDictionary * settingsInSection;
}

@property (strong, nonatomic) IBOutlet UITableView *tableSettings;
@property (retain,nonatomic) NSArray * settings;
@property (retain,nonatomic) NSMutableDictionary * settingsInSection;

- (void)refresh;

- (void)checkVersionNeedUpdate;

+ (int)getVersionNumber:(NSString *)version;

@end
