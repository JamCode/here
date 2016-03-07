//
//  FollowedContentAction.m
//  here_ios
//
//  Created by wang jam on 12/4/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "FollowedContentAction.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "ContentModel.h"
#import "NetWork.h"
#import "Constant.h"
#import "macro.h"
#import "ContentTableViewCell.h"
#import "ContentDetailViewController.h"
#import "SettingViewController.h"
#import "UserSearchTableViewController.h"

@implementation FollowedContentAction
{
    UserInfoModel* myInfo;
    ComTableViewCtrl* comTable;
    NSMutableArray* contentModeArray;
    LocDatabase* locDatabase;
    
    pullCompleted completed;
    
}


- (void)pullUpAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    
    ContentModel* lastModel = [contentModeArray lastObject];
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    if (lastModel != nil) {
        lastTimestamp = lastModel.publishTimeStamp;
    }
    
    
    [self getfollowContent:myInfo.userID timestamp:lastTimestamp handleAction:@selector(getfollowContentHisSuccess:)];
}

- (void)pullDownAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    [self getfollowContent:myInfo.userID timestamp:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getfollowContentSuccess:)];
}


- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    ContentDetailViewController* contentDetail = [[ContentDetailViewController alloc] init];
    
    contentDetail.contentModel = model;
    contentDetail.hidesBottomBarWhenPushed = YES;
    [comTableViewCtrl.navigationController pushViewController:contentDetail animated:YES];
}


- (void)getfollowContentHisSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSDictionary* contentsDic = [feedback objectForKey:@"contents"];
    NSArray* contents = [contentsDic allValues];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserInfoModel* myinfo = app.myInfo;
    
    for (NSDictionary* element in contents) {
        ContentModel* contentMode = [[ContentModel alloc] init];
        [contentMode setContentModel:element];
        
        CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myinfo.latitude longitude:myinfo.longitude];
        CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:contentMode.latitude longitude:contentMode.longitude];
        CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
        contentMode.distanceMeters = meters;
        
        
        NSInteger goodCount = [locDatabase getCountContentGoodInfo:contentMode.contentID];
        contentMode.goodFlag = goodCount;
        
        [contentModeArray addObject:contentMode];
        
    }
    
    [contentModeArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContentModel* element1 = (ContentModel*)obj1;
        ContentModel* element2 = (ContentModel*)obj2;
        return element1.publishTimeStamp<element2.publishTimeStamp;
    }];
    
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    return [ContentTableViewCell getTotalHeight:model maxContentHeight:ScreenHeight];
}


- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    return [ContentTableViewCell generateCell:tableview cellId:@"FollowContentTableViewCell" contentList:contentModeArray indexPath:indexPath];
}

- (NSInteger)sectionNum
{
    return 1;
}

- (NSInteger)rowNum
{
    return [contentModeArray count];
}

- (void)getfollowContentSuccess:(id)sender
{
    [contentModeArray removeAllObjects];
    [self getfollowContentHisSuccess:sender];
}


- (void)getfollowContent:(NSString*)user_id timestamp:(NSInteger)timestamp handleAction:(SEL)handleAction
{
    NetWork* netWork = [[NetWork alloc] init];
    
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, [[NSNumber alloc] initWithInteger:timestamp], @"/getfollowContent"] forKeys:@[@"user_id", @"timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
    
}




- (void)pullDown
{
    [comTable refreshNew];
}


- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    
    myInfo = [AppDelegate getMyUserInfo];
    
    comTable = comTableViewCtrl;
    
    
    contentModeArray = [[NSMutableArray alloc] init];
    
    locDatabase = [[LocDatabase alloc] init];
    if(![locDatabase connectToDatabase:myInfo.userID]){
        [Tools AlertBigMsg:@"本地数据库问题"];
        return;
    }
    
    
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"关注"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    comTable.navigationItem.titleView = navTitle;
    
    comTableViewCtrl.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"找人" style:UIBarButtonItemStylePlain target:self action:@selector(searchPeopleAction:)];

    
    //    UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    //    rightBar.frame = CGRectMake(0, 0, 24, 24);
    //    [rightBar setBackgroundImage:[UIImage imageNamed:@"publishActivity48.png"] forState:UIControlStateNormal];
    //    [rightBar addTarget:self action:@selector(publishActivity:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    //    comTable.navigationItem.rightBarButtonItem = rightitem;
    
    
    //    leftBar = [UIButton buttonWithType:UIButtonTypeCustom];
    //    leftBar.frame = CGRectMake(0, 0, leftbarWidth, leftbarWidth);
    //    [leftBar setBackgroundImage:[UIImage imageNamed:@"info-icon.png"] forState:UIControlStateNormal];
    //
    //    [leftBar addTarget:self action:@selector(sideMenuOpen) forControlEvents:UIControlEventTouchUpInside];
    //    comTable.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBar];
    
    
    //注册右滑动事件
    //    UISwipeGestureRecognizer *swapRight = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(sideMenuOpen)];
    //    swapRight.direction = UISwipeGestureRecognizerDirectionRight;
    //    [comTableViewCtrl.view addGestureRecognizer:swapRight];
    //
    //    //注册左滑动事件
    //    UISwipeGestureRecognizer *swapLeft = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(sideMenuClose)];
    //    swapLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    //    [comTableViewCtrl.view addGestureRecognizer:swapLeft];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pullDown) name:@"pullDown" object:nil];
    
}

- (void)searchPeopleAction:(id)sender
{
    UserSearchTableViewController* userSearch = [[UserSearchTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    userSearch.hidesBottomBarWhenPushed = YES;
    [comTable.navigationController pushViewController:userSearch animated:YES];
}


@end