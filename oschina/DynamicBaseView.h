//
//  DynamicBaseView.h
//  oschina
//
//  Created by wangjun on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivesView.h"

@interface DynamicBaseView : UIViewController
@property (strong, nonatomic) IBOutlet UIView *viewMain;

@property (strong, nonatomic) ActivesView * atme;
@property (strong, nonatomic) ActivesView * activesView;
- (IBAction)selector_ATme:(id)sender;
- (IBAction)selector_Actives:(id)sender;

@end
