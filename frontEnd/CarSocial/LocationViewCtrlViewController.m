////
////  LocationViewCtrlViewController.m
////  CarSocial
////
////  Created by wang jam on 5/5/15.
////  Copyright (c) 2015 jam wang. All rights reserved.
////
//
//#import "LocationViewCtrlViewController.h"
//#import "Constant.h"
//#import "macro.h"
//#import "UserInfoModel.h"
//#import "AppDelegate.h"
//#import "SDWebImage/UIImageView+WebCache.h"
//#import "Tools.h"
//#import <MBProgressHUD.h>
//#import "NetWork.h"
//#import "MapPointModel.h"
//#import "NearByTableViewController.h"
//#import "CustomAnnotationView.h"
//
//
//@interface LocationViewCtrlViewController ()
//{
//    MAMapView *myMapView;
//    MBProgressHUD* loading;
//    BOOL searchFirst;
//    NSDictionary* persons;
//}
//@end
//
//@implementation LocationViewCtrlViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    
//    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//    [navTitle setTextColor:[UIColor whiteColor]];
//    [navTitle setText:@"位置"];
//    navTitle.textAlignment = NSTextAlignmentCenter;
//    navTitle.font = [UIFont boldSystemFontOfSize:20];
//    self.navigationItem.titleView = navTitle;
//    
//    UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBar.frame = CGRectMake(0, 0, 64, 44);
//    [rightBar setTitle:@"列表" forState:UIControlStateNormal];
//    [rightBar setTintColor:[UIColor whiteColor]];
//    [rightBar addTarget:self action:@selector(listButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
//    self.navigationItem.rightBarButtonItem = rightitem;
//    
//    
//    self.view.backgroundColor = activeViewControllerbackgroundColor;
//    
//    searchFirst = false;
//    
//    
//    myMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
//    
//    myMapView.showsUserLocation = YES;
//    [myMapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
//    NSLog(@"%f", [myMapView maxZoomLevel]);
//    NSLog(@"%f", [myMapView minZoomLevel]);
//    [myMapView setZoomLevel:11.1 animated:YES];
//    [self.view addSubview:myMapView];
//    
//    
//    
//    myMapView.delegate = self;
//    
//    
//    loading = [[MBProgressHUD alloc] initWithView:self.view];
//    
//    loading.labelText = @"搜索附近的人";
//    [self.view addSubview:loading];
//    [loading show:YES];
//    
//    //[self searchNearbyPerson];
//    persons = [[NSDictionary alloc] init];
//}
//
//
//- (void)listButtonAction:(id)sender
//{
////    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
////    
////    UINavigationController* nav =  (UINavigationController*)[app.tabBarViewController.viewControllers objectAtIndex:0];
////    
////    NearByTableViewController* nearbyPersonViewCtrl = [[NearByTableViewController alloc] init];
////    nearbyPersonViewCtrl.persons = [[NSMutableArray alloc] init];
////    for (NSDictionary* element in persons) {
////        [nearbyPersonViewCtrl.persons addObject:element];
////    }
////    
////    //contentView.hidesBottomBarWhenPushed = YES;
////    [nav pushViewController:nearbyPersonViewCtrl animated:YES];
//}
//
//- (void)addUserToMap:(NSDictionary*)person
//{
//    MapPointModel *pointAnnotation = [[MapPointModel alloc] init];
//    pointAnnotation.coordinate = CLLocationCoordinate2DMake([[person objectForKey:@"location_latitude"] floatValue], [[person objectForKey:@"location_longitude"] floatValue]);
//    pointAnnotation.title = [person objectForKey:@"user_name"];
//    pointAnnotation.user_id = [person objectForKey:@"user_id"];
//    pointAnnotation.gender = [[person objectForKey:@"user_gender"] integerValue];
//    pointAnnotation.refreshTime = [[person objectForKey:@"refresh_timestamp"] intValue];
//    pointAnnotation.faceUrl = [person objectForKey:@"user_facethumbnail"];
//    pointAnnotation.nickName = [person objectForKey:@"user_name"];
//    //pointAnnotation.subtitle = @"阜通东大街6号";
//    
//    [myMapView addAnnotation:pointAnnotation];
//}
//
//- (void)searchNearbyPerson
//{
//    
//    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
//    //send new location to server
//    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[myInfo.userID,[NSNumber numberWithDouble:myInfo.latitude],[NSNumber numberWithDouble:myInfo.longitude], @"/nearbyPerson"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
//    
//    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getNearbyPersonSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(getNearbyPersonError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(getNearbyPersonException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
//    
//    NetWork* netWork = [[NetWork alloc] init];
//    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
//        [loading hide:YES];
//    } viewController:self];
//}
//
//
//- (NSURL*)getUserFaceUrl:(NSString*)user_id
//{
//    for (NSDictionary* person in persons) {
//        if ([[person objectForKey:@"user_id"] isEqualToString:user_id]) {
//            return [[NSURL alloc] initWithString:[person objectForKey:@"user_facethumbnail"]];
//        }
//    }
//    return nil;
//}
//
//- (void)getNearbyPersonSuccess:(id)sender
//{
//    NSDictionary* feedback = (NSDictionary*)sender;
//    
//    persons = [feedback objectForKey:@"persons"];
//    
//    for (NSDictionary* person in persons) {
//        [self addUserToMap:person];
//    }
//    
//}
//
//- (void)getNearbyPersonError:(id)sender
//{
//    alertMsg(@"获取附近人信息失败");
//    
//}
//
//- (void)getNearbyPersonException:(id)sender
//{
//    alertMsg(@"网络异常");
//}
//
//
//
//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MapPointModel class]])
//    {
//        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
//        CustomAnnotationView* myAnnotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
//        if (myAnnotationView == nil)
//        {
//            myAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
//        }
//        
//        MapPointModel* point = annotation;
//        
//        
//        
//        myAnnotationView.contentMode = UIViewContentModeScaleAspectFit;
//        //myAnnotationView.frame = CGRectMake(myAnnotationView.frame.origin.x, myAnnotationView.frame.origin.y, 33, 33);
//        UIImage* image = [UIImage imageNamed:@"manlocation.png"];
//        
//        if (point.gender == 1) {
//            myAnnotationView.image = [Tools scaleToSize:[UIImage imageNamed:@"manlocation.png"] size:CGSizeMake(image.size.width*33/image.size.height, 33)];
//        }else{
//            myAnnotationView.image = [Tools scaleToSize:[UIImage imageNamed:@"womanlocation.png"] size:CGSizeMake(image.size.width*33/image.size.height, 33)];
//        }
//        
//        //myAnnotationView.clipsToBounds = YES;
//        
//        [myAnnotationView setModel:point];
//        
//        //myAnnotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//
//        //myAnnotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//        return myAnnotationView;
//    }
//    return nil;
//}
//
//
//
//-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
//{
//    if(updatingLocation){
//        //取出当前位置的坐标
//        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
//        UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
//        myInfo.latitude = userLocation.coordinate.latitude;
//        myInfo.longitude = userLocation.coordinate.longitude;
//        if (searchFirst == false) {
//            searchFirst = true;
//            [self searchNearbyPerson];
//        }
//    }
//}
//
//
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
