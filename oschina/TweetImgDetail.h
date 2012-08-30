//
//  TweetImgDetail.h
//  oschina
//
//  Created by wangjun on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"

@interface TweetImgDetail : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy,nonatomic) NSString * imgHref;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)clickCloseThis:(id)sender;

@end
