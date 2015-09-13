//
//  CommentDetailViewCtrl.m
//  CarSocial
//
//  Created by wang jam on 3/25/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "CommentDetailViewCtrl.h"
#import "macro.h"
#import "Constant.h"
#import "CBStoreHouseRefreshControl.h"
#import "NetWork.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "CommentDetailCell.h"
#import "CommentModel.h"
#import "ContentDetailViewController.h"
#import "Tools.h"
#import "GoodModel.h"

@interface CommentDetailViewCtrl ()
{
    //UIScrollView* mainScroll;
    //BOOL reloading;
    
    NSMutableArray* dataList;
    UIActivityIndicatorView* bottomActive;
    Tools* tool;
    
    BOOL noMoreData;
    
    
}

@end

@implementation CommentDetailViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = @"评论";
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"评论"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    
    
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    
    NSLog(@"%f", self.navigationController.navigationBar.frame.size.height);
    
    
    dataList = [[NSMutableArray alloc] init];
    
    bottomActive = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    bottomActive.frame = CGRectMake(0, 0, 30, 30);
    [bottomActive setCenter:CGPointMake(200, 15)];//指定进度轮中心点
    [bottomActive hidesWhenStopped];
    [bottomActive stopAnimating];
    
    
    tool = [[Tools alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTriggered:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
    
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
    
    noMoreData = false;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([dataList count] == 0) {
        return;
    }
    
    if (scrollView == self.tableView) {
        
        CGPoint offset = scrollView.contentOffset;
        
        CGRect bounds = scrollView.bounds;
        
        CGSize size = scrollView.contentSize;
        
        CGFloat currentOffset = offset.y + bounds.size.height;
        
        CGFloat maximumOffset = size.height;
        
        NSLog(@"currentOffset %f",currentOffset);
        NSLog(@"maximumOffset %f", maximumOffset);
        
        if((maximumOffset - currentOffset)<-88.0&&![bottomActive isAnimating]&&noMoreData == false){
            NSLog(@"-----我要刷新数据-----");
            
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
            
            [self.tableView.tableFooterView addSubview:bottomActive];
            [bottomActive setCenter:CGPointMake(ScreenWidth/2, 22)];
            [bottomActive setColor:[UIColor grayColor]];
            [bottomActive startAnimating];
            
            
            
            CommentModel* commentModel = [dataList lastObject];
            
            if (_handle == comment) {
                [self getComment:(int)commentModel.publish_time handleAction:@selector(getCommentHisSuccess:)];
            }
            
            if (_handle == good) {
                [self getGood:(int)commentModel.publish_time handleAction:@selector(getGoodHisSuccess:)];
            }
        }
    }
}



- (void)refreshTriggered:(id)sender
{
    if (_handle == comment) {
        [self getComment:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getCommentSuccess:)];
    }
    
    if (_handle == good) {
        [self getGood:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getGoodSuccess:)];
    }
    
}

- (void)getGood:(int)lastTimestamp handleAction:(SEL)handleAction
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, [NSNumber numberWithInt:lastTimestamp], @"/getUnreadGood"] forKeys:@[@"user_id", @"timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getCommentError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getCommentException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [bottomActive stopAnimating];
        [bottomActive removeFromSuperview];
        
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
        
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
        
    } viewController:self];
}

- (void)getComment:(int)lastTimestamp handleAction:(SEL)handleAction
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, [NSNumber numberWithInt:lastTimestamp], @"/getUnreadComments"] forKeys:@[@"user_id", @"timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getCommentError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getCommentException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        
        [bottomActive stopAnimating];
        [bottomActive removeFromSuperview];
        
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
        
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
        
    } viewController:self];
}

- (void)getCommentException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)getCommentError:(id)sender
{
    alertMsg(@"获取评论出错");
}


- (void)getGoodSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* data = [feedback objectForKey:@"data"];
    
    if ([data count]<=0) {
        return;
    }
    
    [dataList removeAllObjects];
    
    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        GoodModel* goodModel = [[GoodModel alloc] init];
        [goodModel setGoodModel:element];
        [dataList addObject:goodModel];
    }
    
    [self.tableView reloadData];

}


- (void)getGoodHisSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* data = [feedback objectForKey:@"data"];
    
    if ([data count]<=0) {
        noMoreData = true;
        return;
    }
    
    //[commentList removeAllObjects];
    
    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        GoodModel* goodModel = [[GoodModel alloc] init];
        [goodModel setGoodModel:element];
        [dataList addObject:goodModel];
    }
    
    [self.tableView reloadData];
}

- (void)getCommentSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* data = [feedback objectForKey:@"data"];
    
    if ([data count]<=0) {
        return;
    }
    
    [dataList removeAllObjects];
    
    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        CommentModel* comModel = [[CommentModel alloc] init];
        [comModel setCommentModel:element];
        [dataList addObject:comModel];
    }
    
    [self.tableView reloadData];
}

- (void)getCommentHisSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* data = [feedback objectForKey:@"data"];
    
    if ([data count]<=0) {
        noMoreData = true;
        return;
    }
    
    //[commentList removeAllObjects];
    
    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        CommentModel* comModel = [[CommentModel alloc] init];
        [comModel setCommentModel:element];
        [dataList addObject:comModel];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    
    ContentDetailViewController* contentDetailView = [[ContentDetailViewController alloc] init];

    CommentModel* commentModel = [dataList objectAtIndex:indexPath.row];
    
    contentDetailView.contentModel = commentModel.contentModel;
    //contentDetailView.contentID = commentModel.contentID;
    
    contentDetailView.hidesBottomBarWhenPushed = YES;

    
    [self.navigationController pushViewController:contentDetailView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CommentDetailCell getUnreadCommentCellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if (cell == nil) {
        cell = [[CommentDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
    }
    
    
    cell.tool = tool;
    if (_handle == comment) {
        CommentModel* commentmodel = [dataList objectAtIndex:indexPath.row];
        [cell setUnreadCommentModel:commentmodel];
    }
    
    if (_handle == good) {
        GoodModel* goodModel = [dataList objectAtIndex:indexPath.row];
        [cell setUnreadGoodModel:goodModel];
    }
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
