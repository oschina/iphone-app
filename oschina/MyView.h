//
//  MyView.h
//  oschina
//
//  Created by wangjun on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "FavoritesView.h"
#import "FriendsView.h"
#import "MyInfoCell.h"
#import "MyPortraitCell.h"
#import "SSPhotoCropperViewController.h"

@interface MyView : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,SSPhotoCropperDelegate>
{
    NSArray * first;
    NSArray * second;
    NSArray * third;
    
    int fansCount;
    int followersCount;
}

@property (strong,nonatomic) EGOImageView * egoImgView;
- (IBAction)clickUpdatePortrait:(id)sender;

-(void)reload;
@property (strong, nonatomic) IBOutlet UIImageView *imgGender;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UITableView *tableInformation;

@property (retain,nonatomic) NSArray * settings;
@property (retain,nonatomic) NSMutableDictionary * settingsInSection;

@end
