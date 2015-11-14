//
//  NearByTableViewController.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "NearByPersonAction.h"
#import "NearByTableViewCell.h"
#import <MBProgressHUD.h>
#import "Constant.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import "UserInfoModel.h"
#import "macro.h"
#import "NetWork.h"
#import "SettingViewController.h"
#import "NetWork.h"
#import "Tools.h"
#import "TalkViewController.h"
#import <MBProgressHUD.h>
#import "Constant.h"

@interface NearByPersonAction ()
{
    NSMutableArray* nearByPersonArray;
    CLLocationManager* locationManager;
    pullCompleted completed;
}
@end

@implementation NearByPersonAction


#define nearbyCellHeight (ScreenHeight - 64)/6

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        nearByPersonArray = [[NSMutableArray alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        
    }
    return self;
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    if ([CLLocationManager locationServicesEnabled] == false) {
        [Tools AlertMsg:@"定位服务无法使用"];
        return;
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5.0f;
}

- (void)pullDownAction:(pullCompleted)completedBlock //下拉响应函数
{
    [Tools startLocation:locationManager];
    completed = completedBlock;
}

- (NSInteger)rowNum
{
    return [nearByPersonArray count];
}

- (void)tableViewWillDisappear:(ComTableViewCtrl *)comTableViewCtrl
{
    [comTableViewCtrl.tableView deselectRowAtIndexPath:[comTableViewCtrl.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableViewWillAppear:(ComTableViewCtrl *)comTableViewCtrl
{
    //[comTableViewCtrl.tableView deselectRowAtIndexPath:[comTableViewCtrl.tableView indexPathForSelectedRow] animated:YES];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    NearByTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"NearByTableViewCell"];
    
    if (cell==nil) {
        cell = [[NearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NearByTableViewCell"];
            NSLog(@"new cell");
    }
    
    
    UserInfoModel* userInfo = (UserInfoModel*)[nearByPersonArray objectAtIndex:indexPath.row];
    
    
    [cell setUserInfo:userInfo];
        
    return cell;
}


- (void)updateLocationInfo
{
    NSLog(@"location update");
    //send new location to server
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[myInfo.userID,[NSNumber numberWithDouble:myInfo.latitude],[NSNumber numberWithDouble:myInfo.longitude], @"/updateLocation"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
    
    NetWork* netWork = [[NetWork alloc] init];
    [netWork message:message images:nil feedbackcall:nil complete:^{
    } callObject:self];
}


- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    UserInfoModel* userInfo = [nearByPersonArray objectAtIndex:indexPath.row];
    
    
    TalkViewController* talk = [[TalkViewController alloc] init];
    
    talk.counterInfo.userID = userInfo.userID;
    talk.counterInfo.faceImageURLStr = userInfo.faceImageURLStr;
    talk.counterInfo.faceImageThumbnailURLStr = userInfo.faceImageThumbnailURLStr;
    talk.counterInfo.nickName = userInfo.nickName;
    
    [comTableViewCtrl.navigationController pushViewController:talk animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorHeadingFailure) {
        [Tools AlertMsg:error.domain];
        [locationManager stopUpdatingLocation];
    }
    return;
}


- (void)nearbyPerson
{
    //send new location to server
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[myInfo.userID,[NSNumber numberWithDouble:myInfo.latitude],[NSNumber numberWithDouble:myInfo.longitude], @"/nearbyPerson"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(nearbySuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(nearbyError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(nearbyException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    NetWork* netWork = [[NetWork alloc] init];
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations lastObject];
    if (newLocation == nil) {
        [locationManager startUpdatingLocation];
        return;
    }
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    myInfo.latitude = newLocation.coordinate.latitude;
    myInfo.longitude = newLocation.coordinate.longitude;
    NSLog(@"location update");
    [locationManager stopUpdatingLocation];
    
    [self nearbyPerson];
    [self updateLocationInfo];
    
}

- (void)nearbySuccess:(id)sender
{
    //获取附近人成功
    NSDictionary* feedback = (NSDictionary*)sender;
    NSArray* userInfos = [feedback objectForKey:@"persons"];
    [nearByPersonArray removeAllObjects];
    
    for (NSDictionary* element in userInfos) {
        
        UserInfoModel* userInfo = [[UserInfoModel alloc] init];
        
        [userInfo fillWithData:element];
        [nearByPersonArray addObject:userInfo];
    }
}

- (void)nearbyError:(id)sender
{
    [Tools AlertMsg:@"网络问题"];
}

- (void)nearbyException:(id)sender
{
    [Tools AlertMsg:@"未知问题"];
}

#pragma mark - Table view data source


- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return nearbyCellHeight;
}

@end
