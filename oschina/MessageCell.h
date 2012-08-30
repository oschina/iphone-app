//
//  MessageCell.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextView *txtContent;
@property (strong, nonatomic) IBOutlet UILabel *lblFromNowOn;
@property (strong, nonatomic) IBOutlet UILabel *lblCount;
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
//长按删除元素用
@property (nonatomic,assign) id delegate;
- (void)initGR;

@end
