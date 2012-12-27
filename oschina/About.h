//
//  About.h
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesView.h"
#import "SearchView.h"
#import "Tool.h"
#import "FriendsView.h"
#import "SoftwareView.h"
#import "SoftwareTypeView.h"

@interface About : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblVersion;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblOSC;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblCopyright;
@property (strong, nonatomic) IBOutlet UIImageView *img;

@end
