//
//  NearByTableViewController.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "NearByTableViewController.h"
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
@interface NearByTableViewController ()
{
    int farestDistance; //目前附近的人的最远距离
    NSMutableArray* nearByPersonArray;
    CLLocationManager* locationManager;
    UserInfoModel* myInfo;
    BOOL firstShowNearbyView;
    UIRefreshControl* refreshControl;
    UILabel* bottomLabel;//点击查看更多
    MBProgressHUD* loadingView;
    int locationTryCount;
}
@end

@implementation NearByTableViewController


#define nearbyCellHeight (ScreenHeight - 64)/6

//const int nearbyCellHeight = 88;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        locationTryCount = 0;
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)refreshNewInfo:(id)sender
{
//    if (refreshControl.refreshing == YES) {
//        return;
//    }
    
    NSLog(@"refreshNewInfo");
    
    [Tools startLocation:locationManager];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力加载中..."];
}

- (void)initActivityAndLabel
{
    //init update activity
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshNewInfo:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
    [self setRefreshControl:refreshControl];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //self.tableView.frame = CGRectMake(0, -64, self.tableView.frame.size.width, self.tableView.frame.size.height);
    firstShowNearbyView = false;
    nearByPersonArray = [[NSMutableArray alloc] init];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    myInfo = app.myInfo;
    
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"附近的人"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    
    [self initActivityAndLabel];
    
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled] == false) {
        alertMsg(@"定位服务无法使用");
        return;
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5.0f;
    [Tools startLocation:locationManager];
    
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    ++locationTryCount;
    if (locationTryCount>totalLocationTryCount) {
        alertMsg(@"无法获取地理位置信息可能导致相关功能不可用");
        [locationManager stopUpdatingLocation];
        
        
    }
    if (loadingView!=nil) {
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    
    [refreshControl endRefreshing];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    
    CLLocation* newLocation = [locations lastObject];
    
    myInfo.latitude = newLocation.coordinate.latitude;
    myInfo.longitude = newLocation.coordinate.longitude;
    NSLog(@"location update");
    [locationManager stopUpdatingLocation];
    
    //send new location to server
    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[myInfo.userID,[NSNumber numberWithDouble:myInfo.latitude],[NSNumber numberWithDouble:myInfo.longitude], @"/nearbyPerson"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(nearbySuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(nearbyError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(nearbyException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    NetWork* netWork = [[NetWork alloc] init];
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        
        if (loadingView!=nil) {
            [loadingView hide:YES];
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        
    } viewController:self];
    
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
    
    [refreshControl endRefreshing];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
    [self.tableView reloadData];
}

- (void)nearbyError:(id)sender
{
    alertMsg(@"网络问题");
    [refreshControl endRefreshing];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
}

- (void)nearbyException:(id)sender
{
    alertMsg(@"未知问题");
    [refreshControl endRefreshing];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"nearby view delloc");
        
        
        self.view = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (nearByPersonArray!=NULL) {
        return [nearByPersonArray count];
    }else{
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nearbyCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UserInfoModel* userInfo = [nearByPersonArray objectAtIndex:indexPath.row];
//    
//    
//    TalkViewController* talk = [[TalkViewController alloc] init];
//    
//    talk.counterInfo.userID = userInfo.userID;
//    talk.counterInfo.faceImageURLStr = userInfo.faceImageURLStr;
//    talk.counterInfo.faceImageThumbnailURLStr = userInfo.faceImageThumbnailURLStr;
//    talk.counterInfo.nickName = userInfo.nickName;
//    [self.navigationController pushViewController:talk animated:YES];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NearByTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearByTableViewCell"];
    
    // Configure the cell...
    // Configure the cell...
    if (cell==nil) {
        cell = [[NearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NearByTableViewCell"];
        NSLog(@"new cell");
    }
    
    //NSLog(@"set image");
    
    UserInfoModel* userInfo = (UserInfoModel*)[nearByPersonArray objectAtIndex:indexPath.row];
    
    
    [cell setUserInfo:userInfo];
    
    return cell;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
