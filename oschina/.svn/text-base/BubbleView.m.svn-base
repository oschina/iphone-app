//
//  BubbleView.m
//  oschina
//
//  Created by wangjun on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BubbleView.h"

@interface BubbleView ()

@end

@implementation BubbleView
@synthesize bubbleTable;
@synthesize friendID;
@synthesize friendName;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 130;
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    [bubbleTable reloadData];
    
    comments = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload];
    
    self.navigationItem.title = self.friendName;
    
    UIBarButtonItem * bar = [[UIBarButtonItem alloc] initWithTitle:@"给Ta留言" style:UIBarButtonItemStyleBordered target:self action:@selector(clickPubMessage:)];
    self.navigationItem.rightBarButtonItem = bar;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextBubble:) name:@"NextBubble" object:nil];
}

-(void)nextBubble:(NSNotification *)notification
{
    [self reload];
}

-(void)clickPubMessage:(id)sender
{
    PubMessage *pubMessage = [[PubMessage alloc] init];
    pubMessage.receiverid = self.friendID;
    pubMessage.receiver = self.friendName;
    [self.navigationController pushViewController:pubMessage animated:YES];
}

-(void)reload
{
    if (isLoading || isLoadOver) {
        return;
    }
    if ([Config Instance].isCookie == NO) {
        return;
    }
    int pageIndex = comments.count / 20;
    NSString *url = [NSString stringWithFormat:@"%@?catalog=4&id=%d&pageIndex=%d&pageSize=20", api_comment_list, self.friendID, pageIndex];
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    
    [[AFOSCClient sharedClient] getPath:url parameters:nil
     
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    [hud hide:YES];
                                    
                                    isLoading = NO;
                                    NSString *response = operation.responseString;  
                                    [Tool getOSCNotice2:response];

                                    @try {
                                        
                                        TBXML *xml = [[TBXML alloc] initWithXMLString:response error:nil];
                                        int count = [Tool isListOver2:operation.responseString];
                                        allCount += count;
                                        if (count < 20) {
                                            isLoadOver = YES;
                                        }
                                        TBXMLElement *root = xml.rootXMLElement;
                                        TBXMLElement *commentlist = [TBXML childElementNamed:@"comments" parentElement:root];
                                        TBXMLElement *first = [TBXML childElementNamed:@"comment" parentElement:commentlist];
                                        if (!first) {
                                            [self.bubbleTable reloadData];
                                            isLoadOver = YES;
                                            return;
                                        }
                                        
                                        NSMutableArray *newComments = [[NSMutableArray alloc] initWithCapacity:20];
                                        TBXMLElement *_id = [TBXML childElementNamed:@"id" parentElement:first];
                                        TBXMLElement *portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                        TBXMLElement *author = [TBXML childElementNamed:@"author" parentElement:first];
                                        TBXMLElement *authorid = [TBXML childElementNamed:@"authorid" parentElement:first];
                                        TBXMLElement *content = [TBXML childElementNamed:@"content" parentElement:first];
                                        TBXMLElement *pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                        TBXMLElement *appclient = [TBXML childElementNamed:@"appclient" parentElement:first];

                                        Comment *c = [[Comment alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andContent:[TBXML textForElement:content]  andPubDate:[TBXML textForElement:pubDate] andReplies:Nil andRefers:Nil andAppClient:appclient == nil ? 1 : [TBXML textForElement:appclient].intValue];
                                        //判断是否
                                        if (![Tool isRepeatComment: comments andComment:c]) {
                                            [newComments addObject:c];
                                        }
                                        
                                        while (first) {
                                            first = [TBXML nextSiblingNamed:@"comment" searchFromElement:first];
                                            if (first) {
                                                _id = [TBXML childElementNamed:@"id" parentElement:first];
                                                portrait = [TBXML childElementNamed:@"portrait" parentElement:first];
                                                author = [TBXML childElementNamed:@"author" parentElement:first];
                                                authorid = [TBXML childElementNamed:@"authorid" parentElement:first];
                                                content = [TBXML childElementNamed:@"content" parentElement:first];
                                                pubDate = [TBXML childElementNamed:@"pubDate" parentElement:first];
                                                appclient = nil;
                                                appclient = [TBXML childElementNamed:@"appclient" parentElement:first];
                                                c = [[Comment alloc] initWithParameters:[[TBXML textForElement:_id] intValue] andImg:[TBXML textForElement:portrait] andAuthor:[TBXML textForElement:author] andAuthorID:[[TBXML textForElement:authorid] intValue] andContent:[TBXML textForElement:content]  andPubDate:[TBXML textForElement:pubDate] andReplies:Nil andRefers:Nil andAppClient:appclient == nil ? 1 :[TBXML textForElement:appclient].intValue];
                                                if (![Tool isRepeatComment:  comments andComment:c]) {
                                                    [newComments addObject:c];
                                                }
                                            }
                                            else
                                            {
                                                break;
                                            }
                                        }
                                        [comments addObjectsFromArray:newComments];
                                        [self.bubbleTable reloadData];
                                    }
                                    @catch (NSException *exception) {
                                        [NdUncaughtExceptionHandler TakeException:exception];
                                    }
                                    @finally {
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [hud hide:YES];
                                    NSLog(@"聊天气泡列表获取出错");
                                    isLoading = NO;
                                    if ([Config Instance].isNetworkRunning) {
                                        [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                    }
                                }];                                                  
    isLoading = YES;
    [self.bubbleTable reloadData];
    
}

- (void)viewDidUnload
{
    [self setBubbleTable:nil];
    [super viewDidUnload];

}

#pragma TableView

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return comments.count+1;
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    if (row >= comments.count) {
        NSBubbleData *b = [[NSBubbleData alloc] initWithText:@"" andDate:[NSDate date] andType:NSBubbleTypingTypeNobody];
        return b;
    }
    Comment *c = [comments objectAtIndex:row];

    NSBubbleData * b = [NSBubbleData dataWithText:c.content andDate:[Tool NSStringDateToNSDate:c.pubDate] andType:c.authorid == [Config Instance].getUID?BubbleTypeMine:BubbleTypeSomeoneElse];
    return b;
    
}

@end
