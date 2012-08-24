//
//  FriendCell.h
//  oschina
//
//  Created by wangjun on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (strong, nonatomic) IBOutlet UIImageView *imgGender;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UITextView *txtExpertise;

@end
