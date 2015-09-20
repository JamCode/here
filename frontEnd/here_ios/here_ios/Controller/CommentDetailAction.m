//
//  CommentDetailViewCtrl.m
//  CarSocial
//
//  Created by wang jam on 3/25/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "CommentDetailAction.h"
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

@interface CommentDetailAction ()
{
    NSMutableArray* dataList;
}

@end

@implementation CommentDetailAction



- (void)pullUpAction:(pullCompleted)completedBlock; //上拉响应函数
{
    CommentModel* commentModel = [dataList lastObject];
    if (commentModel == nil) {
        completedBlock();
    }else{
        [self getComment:commentModel.publish_time handleAction:@selector(getCommentHisSuccess:) pullComplete:completedBlock];
    }
    
}

- (void)pullDownAction:(pullCompleted)completedBlock; //下拉响应函数
{
    [self getComment:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getCommentSuccess:) pullComplete:completedBlock];
}

- (NSInteger)rowNum
{
    return [dataList count];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    CommentDetailCell *cell = [tableview dequeueReusableCellWithIdentifier:@"commentCell"];
    if (cell == nil) {
        cell = [[CommentDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
    }
    
    
    CommentModel* commentmodel = [dataList objectAtIndex:indexPath.row];
    [cell setUnreadCommentModel:commentmodel];
    
    return cell;
}

- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    ContentDetailViewController* contentDetailView = [[ContentDetailViewController alloc] init];
    
    CommentModel* commentModel = [dataList objectAtIndex:indexPath.row];
    
    contentDetailView.contentModel = commentModel.contentModel;
    
    contentDetailView.hidesBottomBarWhenPushed = YES;
    
    [comTableViewCtrl.navigationController pushViewController:contentDetailView animated:YES];
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return [CommentDetailCell getUnreadCommentCellHeight];
}

- (void)tableViewWillAppear:(ComTableViewCtrl*)comTableViewCtrl
{
    
}

- (void)tableViewWillDisappear:(ComTableViewCtrl*)comTableViewCtrl
{
    [comTableViewCtrl.tableView deselectRowAtIndexPath:[comTableViewCtrl.tableView indexPathForSelectedRow] animated:YES];
}

- (void)getComment:(long)lastTimestamp handleAction:(SEL)handleAction pullComplete:(pullCompleted)pullComplete
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, [NSNumber numberWithLong:lastTimestamp], @"/getUnreadComments"] forKeys:@[@"user_id", @"timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getCommentError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getCommentException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        pullComplete();
    } callObject:self];
}

- (void)getCommentException:(id)sender
{
    [Tools AlertMsg:@"未知问题"];
}

- (void)getCommentError:(id)sender
{
    [Tools AlertMsg:@"获取评论出错"];
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
}

- (void)getCommentHisSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* data = [feedback objectForKey:@"data"];
    
    if ([data count]<=0) {
        return;
    }
    
    //[commentList removeAllObjects];
    
    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        CommentModel* comModel = [[CommentModel alloc] init];
        [comModel setCommentModel:element];
        [dataList addObject:comModel];
    }
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
