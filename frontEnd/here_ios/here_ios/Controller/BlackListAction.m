//
//  BlackListAction.m
//  here_ios
//
//  Created by wang jam on 9/18/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "BlackListAction.h"
#import "ComTableViewCtrl.h"
#import "NetWork.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "macro.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "PriMsgTableViewCell.h"
#import "SettingViewController.h"
#import "Tools.h"


@implementation BlackListAction
{
    NSMutableArray* dataList;
    pullCompleted completed;
    ComTableViewCtrl* comtable;
    
}


- (void)pullDownAction:(pullCompleted)completedBlock; //下拉响应函数
{
    completed = completedBlock;
    [self getBlackList];
}


- (void)getBlackListSuccess:(id)sender
{
    [dataList removeAllObjects];
    
    NSDictionary* feedback = (NSDictionary*)sender;
    NSArray* contents = [feedback objectForKey:@"data"];
    for (NSDictionary* element in contents) {
        UserInfoModel* userModel = [[UserInfoModel alloc] init];
        [userModel fillWithData:element];
        [dataList addObject:userModel];
    }
    
    [comtable.tableView reloadData];
}

- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    UserInfoModel* userInfo = (UserInfoModel*)[dataList objectAtIndex:indexPath.row];

    SettingViewController* settingViewController = [[SettingViewController alloc] init:userInfo];
    settingViewController.hidesBottomBarWhenPushed = YES;
    
    [[Tools curNavigator] pushViewController:settingViewController animated:YES];
}

- (void)getBlackList
{
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, @"/getBlackList"] forKeys:@[@"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getBlackListSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
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

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    PriMsgTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"blackCell"];
    
    if (cell==nil) {
        cell = [[PriMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blackCell"];
        NSLog(@"new cell");
    }
    
    
    UserInfoModel* userInfo = (UserInfoModel*)[dataList objectAtIndex:indexPath.row];
    [cell.imageView sd_setImageWithURL:[[NSURL alloc] initWithString:userInfo.faceImageThumbnailURLStr]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    
    cell.textLabel.text = userInfo.nickName;
    cell.detailTextLabel.text = userInfo.sign;
    return cell;
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"黑名单"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    comTableViewCtrl.navigationItem.titleView = navTitle;
    comtable = comTableViewCtrl;
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return 64;
}

@end
