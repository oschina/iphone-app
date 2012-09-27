//
//  Tool.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Tool.h"
#import "ApiError.h"
#import "News.h"
#import "Post.h"
#import "Activity.h"
#import "ActivesView.h"
#import "SinglePost.h"
#import "NewsDetail.h"
#import "MessageSystemView.h"
#import "ShareView.h"
#import "Message.h"
#import "Comment.h"
#import "Tweet.h"
#import "TweetDetail.h"
#import "TweetBase2.h"
#import "OSCNotice.h"
#import "SoftwareDetail.h"
#import "BlogDetail.h"
#import <AVFoundation/AVFoundation.h>
#import "LoginView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RelativeNews.h"
#import "FTCoreTextView.h"
//#import "FTCoreTextStyle.h"
#import "Software.h"
#import "Blog.h"
#import "SingleNews.h"
#import "SinglePostDetail.h"
#import "ObjectReply.h"
#import "CommentRefer.h"
#import "MBProgressHUD.h"
#import "Favorite.h"
#import "SearchResult.h"
#import "Friend.h"
#import "SoftwareUnit.h"
#import "SoftwareCatalog.h"
#import "BlogUnit.h"
#import "UserView2.h"
#import "PostsView.h"
#import <CommonCrypto/CommonCryptor.h>

@interface Tool : NSObject

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message;

+ (ApiError *)getApiError:(ASIHTTPRequest *)request;
+ (ApiError *)getApiError2:(NSString *)response;
+ (Comment *)getMyLatestComment:(ASIHTTPRequest *)request;
+ (Comment *)getMyLatestComment2:(NSString *)response;

+ (void)pushNewsDetail:(News *)news andNavController:(UINavigationController *)navController andIsNextPage:(BOOL)isNextPage;
+ (void)pushPostDetail:(Post *)post andNavController:(UINavigationController *)navController;
+ (void)pushTweetDetail:(Tweet *)tweet andNavController:(UINavigationController *)navController;
+ (void)pushUserDetail:(int)uid andNavController:(UINavigationController *)navController;
+ (void)pushUserDetailWithName:(NSString *)name andNavController:(UINavigationController *)navController;
+ (BOOL)analysis:(NSString *)url andNavController:(UINavigationController *)navController;

+ (NSMutableArray *)getRelativeNews:(NSString *)request;
+ (NSString *)generateRelativeNewsString:(NSArray *)array;
+ (NSString *)generateCommentDetail:(Comment *)comment;

+ (OSCNotice *)getOSCNotice:(ASIHTTPRequest *)request;
+ (OSCNotice *)getOSCNotice2:(NSString *)response;

+ (UIColor *)getColorForCell:(int)row;

+ (void)clearWebViewBackground:(UIWebView *)webView;

+ (void)doSound:(id)sender;

+ (void)pushTweetImgDetail:(NSString *)img andParent:(UIViewController *)parent;

+ (NSString *)getBBSIndex:(int)index;

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom;

+ (void)roundTextView:(UITextView *)txtView;

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title;

+ (void)processLoginNotice:(UIActionSheet *)actionSheet andButtonIndex:(NSInteger)buttonIndex andNav:(UINavigationController *)nav andParent:(UIViewController *)parent;

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog;

+ (void)playAudio:(BOOL)isAlert;

+ (NSString *)getTextViewString:(NSString *)author andObjectType:(int)objectType andObjectCatalog:(int)objectCatalog andObjectTitle:(NSString *)title andMessage:(NSString *)message andPubDate:(NSString *)pubDate andReply:(ObjectReply *)reply;
+ (NSString *)getTextViewString2:(NSString *)author andObjectType:(int)objectType andObjectCatalog:(int)objectCatalog andObjectTitle:(NSString *)title andMessage:(NSString *)message andPubDate:(NSString *)pubDate andReply:(ObjectReply *)reply;

+ (NSString *)intervalSinceNow: (NSString *) theDate;

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day;

+ (NSArray *)coreTextStyle;

+ (NSString *)getAppClientString:(int)appClient;

+ (void)ReleaseWebView:(UIWebView *)webView;

+ (int)getTextViewHeight:(UITextView *)txtView andUIFont:(UIFont *)font andText:(NSString *)txt;

+ (UIColor *)getBackgroundColor;
+ (UIColor *)getCellBackgroundColor;


//重复性判断
+ (BOOL)isRepeatNews:(NSMutableArray *)all andNews:(News *)n;
+ (BOOL)isRepeatPost:(NSMutableArray *)all andPost:(Post *)p;
+ (BOOL)isRepeatTweet:(NSMutableArray *)all andTweet:(Tweet *)t;
+ (BOOL)isRepeatMessage:(NSMutableArray *)all andMessage:(Message *)m;
+ (BOOL)isRepeatComment:(NSMutableArray *)all andComment:(Comment *)c;
+ (BOOL)isRepeatActive:(NSMutableArray *)all andActive:(Activity *)a;
+ (BOOL)isRepeatFavorite:(NSMutableArray *)all andFav:(Favorite *)f;
+ (BOOL)isRepeatSearch:(NSMutableArray *)all andResult:(SearchResult *)s;
+ (BOOL)isRepeatFriend:(NSMutableArray *)all andFriend:(Friend *)f;
+ (BOOL)isRepeatSoftware:(NSMutableArray *)all andSoftware:(SoftwareUnit *)s;
+ (BOOL)isRepeatSoftwareCatalog:(NSMutableArray *)all andSoftwareCatalog:(SoftwareCatalog *)s;
+ (BOOL)isRepeatUserBlog:(NSMutableArray *)all andBlogUnit:(BlogUnit *)b;

+ (SingleNews *)readStrNewsDetail:(NSString *)str;
+ (SinglePostDetail *)readStrSinglePostDetail:(NSString *)str;
+ (Software *)readStrSoftwareDetail:(NSString *)str;
+ (Blog *)readStrBlogDetail:(NSString *)str;

+ (NSMutableArray *)readStrNewsArray:(NSString *)str andOld:(NSMutableArray *)olds;
+ (NSMutableArray *)readStrUserBlogsArray:(NSString *)str andOld:(NSMutableArray *)olds;
+ (NSMutableArray *)readStrPostArray:(NSString *)str andOld:(NSMutableArray *)olds;
/*
 注意此方法 可以存储所有的 detail 以及 news列表于 post列表
 type:
 1 -- news detail 
 2 -- post detail 
 3 -- software detail
 4 -- blog detail
 5 -- news 列表  其中 _id 表示 segementIndex
 6 -- post 列表  其中 _id 表示 segementIndex 
 */
+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str;
+ (void)saveSoftware:(NSString *)softwareName andString:(NSString *)str;
+ (NSString *)getSoftware:(NSString *)softwareName;
+ (NSString *)getCache:(int)type andID:(int)_id;

+ (void)deleteAllCache;

+ (NSMutableArray *)getReplies:(TBXMLElement *)first;
+ (NSMutableArray *)getRefers:(TBXMLElement *)first;
+ (UIView *)getReferView:(NSMutableArray *)refers;

+ (NSString *)getHTMLString:(NSString *)html;

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;

+ (int)isListOver:(ASIHTTPRequest *)request;
+ (int)isListOver2:(NSString *)response;

+ (void)doWithFavorite:(BOOL)addFavorite andUID:(int)uid andObjID:(int)objID andType:(int)type andDelegate:(UIViewController *)viewController andRequest:(ASIFormDataRequest *)request;

+ (UIImage *) scale:(UIImage *)sourceImg toSize:(CGSize)size;

+ (CGSize)scaleSize:(CGSize)sourceSize;

+ (NSString *)getOSVersion;

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom;

+ (void)CancelRequest:(ASIFormDataRequest *)request;

+ (NSDate *)NSStringDateToNSDate:(NSString *)string;

+ (NSString *)GenerateTags:(NSMutableArray *)tags;

@end
