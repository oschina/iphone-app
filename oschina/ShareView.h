//
//  ShareView.h
//  oschina
//
//  Created by wangjun on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "OAuthEngine.h"
//#import "WeiboClient.h"
//#import "OAuthController.h"
#import "Tool.h"
#import "ShareObject.h"
#import "UITap.h"

#define SinaAppKey @"3616966952"
#define SinaAppSecret @"fd81f6d31427b467f49226e48a741e28"

@interface ShareView : UIViewController
{
    NSString * url;
    NSString * content;
    
    UIAlertView *progressView;
    
    UITap *tapSina;
    UITap *tapQQ;
    
    BOOL isInitialize;
    
    MBProgressHUD * hud;
}
@property (strong, nonatomic) IBOutlet UIImageView *imgSina;
@property (strong, nonatomic) IBOutlet UIImageView *imgQQ;

@property (copy,nonatomic) NSString * url;
@property (copy,nonatomic) NSString * content;

- (IBAction)click_qqshare:(id)sender;
- (IBAction)click_weibo:(id)sender;

@end
