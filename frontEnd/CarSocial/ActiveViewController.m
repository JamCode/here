//
//  ActiveViewController.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "ActiveViewController.h"
#import<MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ActiveView.h"
#import "Constant.h"
#import "PublishActivityViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "NetWork.h"
#import "macro.h"

@interface ActiveViewController ()
{
    UIScrollView* mainScroll;
    MBProgressHUD* loadingView;
    EGORefreshTableHeaderView *refreshTableHeaderView;
    BOOL reloading;
    NSMutableArray* activeModeArray;
    CLLocationManager* locationManager;
    
}
@end

@implementation ActiveViewController

static const float activeViewHeight = 540/2;
static const float activeViewDistance = 10;
static const float activeViewUpBottomDistance = 15;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    activeModeArray = [[NSMutableArray alloc] init];
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"活动"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBar.frame = CGRectMake(0, 0, 24, 24);
    [rightBar setBackgroundImage:[UIImage imageNamed:@"publishActivity48.png"] forState:UIControlStateNormal];
    [rightBar addTarget:self action:@selector(publishActivity:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    
    
    self.navigationItem.rightBarButtonItem = rightitem;
    
    
    
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    mainScroll.contentSize = CGSizeMake(ScreenWidth, 0);
    mainScroll.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [mainScroll setPagingEnabled:NO];
    
    [mainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    mainScroll.delegate = self;
    [self.view addSubview:mainScroll];
    
    
    //获取用户地理信息
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled] == false) {
        alertMsg(@"定位服务无法使用");
        return;
    }
    
    [locationManager setDelegate:self];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5.0f;
    
    
    refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    refreshTableHeaderView.delegate = self;
    refreshTableHeaderView.backgroundColor = activeViewControllerbackgroundColor;
    [refreshTableHeaderView refreshLastUpdatedDate];
    
    [mainScroll addSubview:refreshTableHeaderView];
    [mainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [refreshTableHeaderView egoRefreshScrollViewDidEndDragging:mainScroll autoUpdate:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    alertMsg(@"无法获取地理位置信息可能导致相关功能不可用");
    [locationManager stopUpdatingLocation];
    [self doneLoadingTableViewData];
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations lastObject];
    
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    app.myInfo.latitude = newLocation.coordinate.latitude;
    app.myInfo.longitude = newLocation.coordinate.longitude;
    NSLog(@"location update");
    //send new location to server
    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[app.myInfo.userID,[NSNumber numberWithDouble:app.myInfo.latitude],[NSNumber numberWithDouble:app.myInfo.longitude], @"/updateLocation"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
    
    
    
    
    NetWork* netWork = [[NetWork alloc] init];
    [netWork message:message images:nil feedbackcall:nil complete:^{
    } viewController:self];
    
    [locationManager stopUpdatingLocation];
    
    [self getActive];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}


- (void)publishActivity:(id)sender
{
    NSLog(@"publishActivity");
    
    
    PublishActivityViewController* publish = [[PublishActivityViewController alloc] init];
    publish.activeViewController = self;
    [self presentViewController:publish animated:YES completion:nil];
    //[self.navigationController pushViewController:publish animated:YES];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"activeview didReceiveMemoryWarning");
    
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"activeview delloc");
        
        mainScroll = nil;
        self.view = nil;
    }
}

- (void)doneLoadingTableViewData{
    
    //model should call this when its done loading
    reloading = NO;
    [refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mainScroll];
    
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    if (reloading == NO) {
        reloading = YES;
        [locationManager startUpdatingLocation];
    }
}


- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView autoUpdate:false];
    
}

- (void)getActive
{
    
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[[NSNumber alloc] initWithDouble:app.myInfo.latitude], [[NSNumber alloc] initWithDouble:app.myInfo.longitude], [[NSNumber alloc] initWithInt:0], @"/getActive"] forKeys:@[@"user_latitude", @"user_longitude", @"last_active_timestamp", @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getActiveSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } viewController:self];
    
}


- (void)getException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)getActiveError:(id)sender
{
    alertMsg(@"获取活动失败");
}

- (NSInteger)getActiveLastTimestamp
{
    if ([activeModeArray count] == 0) {
        return 0;
    }else{
        NSInteger lastTimestamp = 0;
        for (int i=0; i<[activeModeArray count]; ++i) {
            ActiveModel* active = [activeModeArray objectAtIndex:i];
            if (lastTimestamp<active.publishTimeStamp) {
                lastTimestamp = active.publishTimeStamp;
            }
        }
        return lastTimestamp;
    }
}


- (void)removeAllViews:(NSArray*)array
{
    for (int i=0; i<[array count]; ++i) {
        UIView* view = [array objectAtIndex:i];
        if ([view isKindOfClass:[ActiveView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)getActiveSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* actives = [feedback objectForKey:@"actives"];
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    UserInfoModel* myinfo = app.myInfo;
    
    
    [activeModeArray removeAllObjects];
    [self removeAllViews:mainScroll.subviews];
    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, refreshTableHeaderView.frame.size.height);
    
    
    for (NSDictionary* element in actives) {
        ActiveModel* activeMode = [[ActiveModel alloc] init];
        activeMode.userInfo.nickName = [element objectForKey:@"user_name"];
        activeMode.userInfo.sign = [element objectForKey:@"user_sign"];
        activeMode.personCount = [element objectForKey:@"active_count"];
        activeMode.userInfo.faceImageURLStr = [element objectForKey:@"user_facethumbnail"];
        activeMode.userInfo.userID = [element objectForKey:@"user_id"];
        //activeMode.userInfo.isCertificated = TRUE;
        
        activeMode.activeID = [element objectForKey:@"active_id"];
        activeMode.activeType = [element objectForKey:@"active_type"];
        activeMode.activeDesc = [element objectForKey:@"active_desc_detail"];
        activeMode.latitude = [[element objectForKey: @"active_publish_latitude"] doubleValue];
        activeMode.longitude = [[element objectForKey: @"active_publish_longitude"] doubleValue];
        activeMode.publishTimeStamp = [[element objectForKey:@"active_publish_timestamp"] intValue];
        activeMode.watchCount = [[element objectForKey:@"active_see_count"] intValue];
        
        
        CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myinfo.latitude longitude:myinfo.longitude];
        CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:activeMode.latitude longitude:activeMode.longitude];
        
        
        CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
        activeMode.distanceMeters = meters;
        
        
        
        NSDate *activeTime = [NSDate dateWithTimeIntervalSince1970:[[element objectForKey:@"active_time"] intValue]];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:activeTime];
        NSInteger day = [components day];
        NSInteger month= [components month];
        NSInteger year= [components year];
        
        activeMode.startDate = [NSString stringWithFormat:@"%ld-%ld-%ld", year, month, day];
        
        activeMode.endPosition = [element objectForKey:@"active_location_desc"];
        [activeModeArray addObject:activeMode];
        
        ActiveView* activeView = [[ActiveView alloc] initWithFrame:CGRectMake(activeViewDistance, activeViewUpBottomDistance+mainScroll.contentSize.height, ScreenWidth-2*activeViewDistance, activeViewHeight)];
        activeView.parentViewController = self;
        [activeView setActiveModel:activeMode];
        
        
        mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, mainScroll.contentSize.height+activeView.frame.size.height+activeViewUpBottomDistance);
        
        [mainScroll addSubview:activeView];
    }
    
    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, mainScroll.contentSize.height+64);
    [mainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

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
