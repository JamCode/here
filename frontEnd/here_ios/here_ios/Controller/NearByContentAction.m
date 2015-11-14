//
//  NearByContentAction.m
//  CarSocial
//
//  Created by wang jam on 9/7/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "NearByContentAction.h"
#import "ContentModel.h"
#import "ContentTableViewCell.h"
#import "Constant.h"
#import "macro.h"
#import "Tools.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import "ContentDetailViewController.h"
#import "MenuViewCtrl.h"
#import "CommentModel.h"
#import "PublishContentViewController.h"


static const int noticeLabelHeight = 10;
static const int leftbarWidth = 20;

@implementation NearByContentAction
{
    NSMutableArray* contentModeArray;
    CLLocationManager* locationManager;
    pullCompleted completed;
    ComTableViewCtrl* comTable;
    UIButton* leftBar;
    UILabel* noticelabel;
    UserInfoModel* myInfo;
}

- (void)pullUpAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    
    ContentModel* lastModel = [contentModeArray lastObject];
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    if (lastModel != nil) {
        lastTimestamp = lastModel.publishTimeStamp;
    }
    
    [self getNearbyContent:lastTimestamp handleAction:@selector(getContentHisSuccess:)];
}

- (void)pullDownAction:(pullCompleted)completedBlock
{
    [Tools startLocation:locationManager];
    completed = completedBlock;
}

- (NSInteger)rowNum
{
    return [contentModeArray count];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"NearContentTableViewCell";
    ContentTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSLog(@"new cell");
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.tableView = comTable.tableView;
    
    ContentModel* contentmodel = [contentModeArray objectAtIndex:indexPath.row];
    [cell setContentModel:contentmodel];
    return cell;
}

- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    ContentDetailViewController* contentDetail = [[ContentDetailViewController alloc] init];
    
    contentDetail.contentModel = model;
    contentDetail.hidesBottomBarWhenPushed = YES;
    [comTableViewCtrl.navigationController pushViewController:contentDetail animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorHeadingFailure) {
        [Tools AlertMsg:error.domain];
        [locationManager stopUpdatingLocation];
    }
    return;
}


//set to red notice
- (void)setLeftBarNotice
{
    if (noticelabel != nil) {
        [noticelabel removeFromSuperview];
    }
    
    noticelabel = [[UILabel alloc] initWithFrame:CGRectMake(leftbarWidth -noticeLabelHeight/2, -noticeLabelHeight/2, noticeLabelHeight, noticeLabelHeight)];
    
    noticelabel.backgroundColor = [UIColor redColor];
    noticelabel.layer.cornerRadius = noticeLabelHeight/2;
    noticelabel.layer.masksToBounds = YES;
    [leftBar addSubview:noticelabel];
}

- (void)removeLeftBarNotice
{
    if (noticelabel != nil) {
        [noticelabel removeFromSuperview];
    }
}

- (void)fillContentList:(id)sender
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
        
        [contentModeArray addObject:contentMode];
        
    }
    
    [contentModeArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContentModel* element1 = (ContentModel*)obj1;
        ContentModel* element2 = (ContentModel*)obj2;
        return element1.publishTimeStamp<element2.publishTimeStamp;
    }];
}

- (void)getContentHisSuccess:(id)sender
{
    [self fillContentList:sender];
}




- (void)checkUnreadMsg
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, @"/getNoticeMsgCount"] forKeys:@[@"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(checkUnreadMsgSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(checkUnreadMsgError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(checkUnreadMsgException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        ;
    } callObject:self];
}

- (void)checkUnreadMsgSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSInteger count = [[feedback objectForKey:@"data"] integerValue];
    if (count > 0) {
        [self setLeftBarNotice];
    }else{
        [self removeLeftBarNotice];
    }
}

- (void)checkUnreadMsgError:(id)sender
{
    NSLog(@"checkUnreadMsgError");
}

- (void)checkUnreadMsgException:(id)sender
{
    NSLog(@"checkUnreadMsgException");
}


- (void)updateLocationInfo
{
    NSLog(@"location update");
    //send new location to server
    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[myInfo.userID,[NSNumber numberWithDouble:myInfo.latitude],[NSNumber numberWithDouble:myInfo.longitude], @"/updateLocation"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
    
    NetWork* netWork = [[NetWork alloc] init];
    [netWork message:message images:nil feedbackcall:nil complete:^{
    } callObject:self];
}

- (void)getNearbyContent:(NSInteger)lastTimestamp handleAction:(SEL)handleAction
{
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[[NSNumber alloc] initWithDouble:myInfo.latitude], [[NSNumber alloc] initWithDouble:myInfo.longitude], [[NSNumber alloc] initWithInteger:lastTimestamp] , @"/getNearbyContent"] forKeys:@[@"user_latitude", @"user_longitude", @"last_timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getContentError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getContentException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
    
}

- (void)getContentException:(id)sender
{
    [Tools AlertMsg:@"getContentException"];
}

- (void)getContentError:(id)sender
{
    [Tools AlertMsg:@"getContentError"];
}

- (void)getContentSuccess:(id)sender
{
    [contentModeArray removeAllObjects];
    [self fillContentList:sender];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations == nil) {
        [locationManager startUpdatingLocation];
        return;
    }
    
    CLLocation* newLocation = [locations lastObject];
    
    if (fabs(newLocation.coordinate.latitude) < 0.001||fabs(newLocation.coordinate.longitude) < 0.001) {
        [locationManager startUpdatingLocation];
        return;
    }
    
    myInfo.latitude = newLocation.coordinate.latitude;
    myInfo.longitude = newLocation.coordinate.longitude;
    NSLog(@"location update");
    [locationManager stopUpdatingLocation];
    
    [self getNearbyContent:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getContentSuccess:)];
    
    [self updateLocationInfo];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    myInfo = [AppDelegate getMyUserInfo];
    
    comTable = comTableViewCtrl;
    
    contentModeArray = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    
    if ([CLLocationManager locationServicesEnabled] == false) {
        [Tools AlertMsg:@"定位服务无法使用"];
        return;
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5.0f;
    
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"附近"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    comTable.navigationItem.titleView = navTitle;
    
    
    UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBar.frame = CGRectMake(0, 0, 24, 24);
    [rightBar setBackgroundImage:[UIImage imageNamed:@"publishActivity48.png"] forState:UIControlStateNormal];
    [rightBar addTarget:self action:@selector(publishActivity:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    comTable.navigationItem.rightBarButtonItem = rightitem;
    
    
    leftBar = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBar.frame = CGRectMake(0, 0, leftbarWidth, leftbarWidth);
    [leftBar setBackgroundImage:[UIImage imageNamed:@"info-icon.png"] forState:UIControlStateNormal];
    
    [leftBar addTarget:self action:@selector(sideMenuOpen) forControlEvents:UIControlEventTouchUpInside];
    comTable.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBar];
    
    
    //注册右滑动事件
    UISwipeGestureRecognizer *swapRight = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(sideMenuOpen)];
    swapRight.direction = UISwipeGestureRecognizerDirectionRight;
    [comTableViewCtrl.view addGestureRecognizer:swapRight];
    
    //注册左滑动事件
    UISwipeGestureRecognizer *swapLeft = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(sideMenuClose)];
    swapLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [comTableViewCtrl.view addGestureRecognizer:swapLeft];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pullDown) name:@"pullDown" object:nil];
    
}

- (void)pullDown
{
    [comTable refreshNew];
}

- (void)publishActivity:(id)sender
{
    NSLog(@"publishActivity");
    PublishContentViewController* publish = [[PublishContentViewController alloc] init];
    //publish.contentViewController = self;
    [comTable presentViewController:publish animated:YES completion:nil];
    
}

- (void)sideMenuClose
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.sideMenu closeMenuAnimated:YES completion:nil];
}

- (void)sideMenuOpen
{
    NSLog(@"sideMenuOpen");
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [(MenuViewCtrl*)app.sideMenu.menuViewController getUnreadNoticeMsgCount];
    [app.sideMenu openMenuAnimated:YES completion:nil];
    
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    return [ContentTableViewCell getTotalHeight:model maxContentHeight:ScreenHeight];
}

- (void)tableViewWillAppear:(ComTableViewCtrl*)comTableViewCtrl
{
    [self checkUnreadMsg];
}

- (void)tableViewWillDisappear:(ComTableViewCtrl*)comTableViewCtrl
{
    
}

@end
