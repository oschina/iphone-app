
#import "MyBubbleView.h"

@implementation MyBubbleView
@synthesize tableBubbles;
@synthesize friendID;
@synthesize friendName;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //数据集合初始化
    comments = [[NSMutableArray alloc] initWithCapacity:20];
    //标题
    self.navigationItem.title = self.friendName;
    //留言按钮
    UIBarButtonItem * bar = [[UIBarButtonItem alloc] initWithTitle:@"给Ta留言" style:UIBarButtonItemStyleBordered target:self action:@selector(clickPubMessage:)];
    self.navigationItem.rightBarButtonItem = bar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextBubble:) name:@"NextBubble" object:nil];
    
    //加载
    [self reload];
}

- (void)clickPubMessage:(id)sender
{
    PubMessage *pubMessage = [[PubMessage alloc] init];
    pubMessage.receiverid = self.friendID;
    pubMessage.receiver = self.friendName;
    [self.navigationController pushViewController:pubMessage animated:YES];
}

- (void)viewDidUnload
{
    [self setTableBubbles:nil];
    [super viewDidUnload];
}

- (void)reload
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
                                            [self.tableBubbles reloadData];
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
                                        
                                        //计算宽度
                                        for (Comment *c in newComments) {
                                            if (c.authorid == [Config Instance].getUID) {
//                                                ChatPopView *p = [[ChatPopView alloc] initWithFrame:CGRectMake(58, 23, 250, 80) popDirection:ePopDirectionRight];
//                                                c.width_bubble = p.frame.size.width;
//                                                contentLabel.font = [UIFont fontWithName:@"Arial" size:14];
//                                                contentLabel.numberOfLines = 0;
                                                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 250-15, 80)];
                                                l.font = [UIFont fontWithName:@"Arial" size:14];
                                                l.numberOfLines = 0;
                                                l.text = c.content;
                                                [l sizeToFit];
//                                                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentLabel.frame.size.width+30, contentLabel.frame.size.height + 15);
                                                c.width_bubble = l.frame.size.width + 30;
                                            }
                                        }
                                        
                                        [comments addObjectsFromArray:newComments];
                                    }
                                    @catch (NSException *exception) {
                                        [NdUncaughtExceptionHandler TakeException:exception];
                                    }
                                    @finally {
                                        [self.tableBubbles reloadData];
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
}

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadOver) {
        return comments.count == 0 ? 1 :comments.count;
    }
    else
        return comments.count + 1;
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    if (index < comments.count) {
        Comment *m = (Comment *)[comments objectAtIndex:index];
        return m.height+8;
//        ChatPopView * p = [[ChatPopView alloc] initWithFrame:CGRectMake(70, 7, 240, 80) popDirection:ePopDirectionRight];
//        [p setText:m.content];
//        return p.frame.size.height;
    }
    else
        return 62;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果有数据
    if (comments.count > 0) {
        if (indexPath.row < comments.count) 
        {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCellIdentifier];
            Comment *c = [comments objectAtIndex:indexPath.row];
            UILabel * lblTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            lblTime.font = [UIFont boldSystemFontOfSize:12.0];
            lblTime.textColor = [UIColor lightGrayColor];
            lblTime.textAlignment = UITextAlignmentCenter;
            lblTime.backgroundColor = [UIColor clearColor];
            lblTime.text = [Tool intervalSinceNow:c.pubDate];
            [cell.contentView addSubview:lblTime];
            ChatPopView *p;
            if (c.authorid == [Config Instance].getUID) {
//                p = [[ChatPopView alloc] initWithFrame:CGRectMake(58, 23, 250, 80) popDirection:ePopDirectionRight];
                float origin = 58;
                if (c.width_bubble < 250) {
                    origin = 58 + (250 - c.width_bubble);
                }
                p = [[ChatPopView alloc] initWithFrame:CGRectMake(origin, 23, 250, 80) popDirection:ePopDirectionRight];
            }
            else
            {
                p = [[ChatPopView alloc] initWithFrame:CGRectMake(2, 23, 250, 80) popDirection:ePopDirectionLeft];
            }
            [p setText:c.content];
            [cell.contentView addSubview:p];
            return  cell;
        }
        else
        {
            if ([Config Instance].isNetworkRunning)
            {
                return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:[Config Instance].isCookie ? (isLoading ? loadingTip : loadNext20Tip) : @"您还没有登录,无法查看" andIsLoading:isLoading];   
            }
            else
            {
                return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
            }
        }
    }
    //如果没有数据
    else 
    {
        if ([Config Instance].isNetworkRunning)
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"" andLoadingString:[Config Instance].isCookie ? (isLoading ? loadingTip : loadNext20Tip) : @"您还没有登录,无法查看" andIsLoading:isLoading];
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:noNetworkTip andLoadingString:noNetworkTip andIsLoading:isLoading];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= comments.count) 
    {
        [self reload];
    }
}
@end
