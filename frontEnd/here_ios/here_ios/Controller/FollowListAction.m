//
//  FollowListAction.m
//  here_ios
//
//  Created by wang jam on 12/20/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "FollowListAction.h"
#import "FollowUserCell.h"
#import "NetWork.h"
#import "SettingViewController.h"
#import "Tools.h"
#import "macro.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "UserSearchTableViewController.h"

@implementation FollowListAction
{
    NSMutableArray* dataList;
    pullCompleted completed;
    ComTableViewCtrl* comtable;
}


- (void)pullDownAction:(pullCompleted)completedBlock //下拉响应函数
{
    completed = completedBlock;
    
    [self getFollowList:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getFollowListSuccess:)];
}


- (void)pullUpAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    
    UserInfoModel* userInfo = [dataList lastObject];
    
    if (userInfo!=nil) {
        [self getFollowList:userInfo.follow_timestamp handleAction:@selector(getFollowListHisSuccess:)];
    }else{
        [self getFollowList:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getFollowListHisSuccess:)];
    }
    
}


- (void)getFollowListHisSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSArray* contents = [feedback objectForKey:@"data"];
    for (NSDictionary* element in contents) {
        UserInfoModel* userModel = [[UserInfoModel alloc] init];
        [userModel fillWithData:element];
        [dataList addObject:userModel];
    }
    
    [dataList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UserInfoModel* a = (UserInfoModel*)obj1;
        UserInfoModel* b = (UserInfoModel*)obj2;
        return a.follow_timestamp>b.follow_timestamp;
    }];
    
    [comtable.tableView reloadData];

}

- (void)getFollowListSuccess:(id)sender
{
    [dataList removeAllObjects];
    
    [self getFollowListHisSuccess:sender];
    
}

- (void)getFollowList:(NSInteger)timestamp handleAction:(SEL)handleAction
{
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID, [[NSNumber alloc] initWithInteger:timestamp],  @"/getfollowUser"] forKeys:@[@"user_id", @"follow_timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
    
}

- (NSInteger)rowNum
{
    return [dataList count];
}

- (NSInteger)sectionNum
{
    return 1;
}


- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    UserInfoModel* userInfo = (UserInfoModel*)[dataList objectAtIndex:indexPath.row];
    
    SettingViewController* settingViewController = [[SettingViewController alloc] init:userInfo];
    settingViewController.hidesBottomBarWhenPushed = YES;
    
    [[Tools curNavigator] pushViewController:settingViewController animated:YES];
    
    [comTableViewCtrl.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    FollowUserCell *cell = [tableview dequeueReusableCellWithIdentifier:@"FollowUserCell"];
    
    if (cell==nil) {
        cell = [[FollowUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FollowUserCell"];
        NSLog(@"new cell");
    }
    
    
    UserInfoModel* userInfo = (UserInfoModel*)[dataList objectAtIndex:indexPath.row];
    
    [cell configureCell:userInfo];
    
    return cell;
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"关注的人"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    comTableViewCtrl.navigationItem.titleView = navTitle;
    comtable = comTableViewCtrl;
    
    
    
}




- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return [FollowUserCell followUserCellHeight];
}


@end
