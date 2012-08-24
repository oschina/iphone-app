//
//  TweetCell.h
//  oschina
//
//  Created by wangjun on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UITextView *txt_Message;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Time;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Author;
@property (strong, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (strong, nonatomic) IBOutlet UIImageView *imgTweet;
//长按删除元素用
@property (nonatomic,assign) id delegate;
-(void)initGR;

@end
