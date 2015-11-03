//
//  AppDelegate.m
//  CarSocial
//
//  Created by wang jam on 8/5/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "AppDelegate.h"
#import "Constant.h"
#import "TabBarViewController.h"
#import "StartViewController.h"
#import "UserInfoModel.h"
#import "RegisterConfirmViewController.h"
#import "SignInViewController.h"
#import "CoreDataTestViewController.h"
#import "NetWork.h"
#import "ContentDetailViewController.h"
#import "MessageTableViewController.h"
#import <FIR/FIR.h>
#import "Tools.h"
#import "ConfigAccess.h"

@implementation AppDelegate





- (NSString*)getMyID
{
    return _myInfo.userID;
}

- (void)backToStartView
{
    [(UINavigationController*)self.window.rootViewController popToRootViewControllerAnimated:YES];
}

- (void)startView
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    UINavigationController* rootNav = [[UINavigationController alloc] initWithRootViewController:[[StartViewController alloc] init]];
    
    rootNav.navigationBar.translucent = NO;
    rootNav.navigationBar.barTintColor = [UIColor blackColor];
    rootNav.navigationBar.tintColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    
    self.window.rootViewController = rootNav;
    
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    //get config
    NSString* serverDomain = [ConfigAccess serverDomain];
    
    NSLog(@"%@", serverDomain);
    
    _tabBarViewController = nil;
    _myInfo = [[UserInfoModel alloc] init];
    
    _myInfo.phoneNum = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"phone"];
    _myInfo.password = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    _mysocket = [[SocketIO alloc] initWithDelegate:self];
    
    if (_myInfo.phoneNum == nil||_myInfo.password == nil
        ||_myInfo.phoneNum.length == 0||_myInfo.password.length == 0) {
        [self startView];
    }else{
        //login
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        StartViewController* startView = [[StartViewController alloc] init];
        SignInViewController* signInView = [[SignInViewController alloc] init];
        UINavigationController* rootNav = [[UINavigationController alloc] initWithRootViewController:startView];
        [rootNav pushViewController:signInView animated:NO];
        
        rootNav.navigationBar.translucent = NO;
        rootNav.navigationBar.barTintColor = [UIColor blackColor];
        rootNav.navigationBar.tintColor = [UIColor whiteColor];
        
        self.window.rootViewController = rootNav;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        signInView.view.hidden = YES;
        [signInView sendLoginMessage:_myInfo];
        [self.window makeKeyAndVisible];
    }
    
    
    //禁止旋转
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    
    
    //高德地图key
    //[MAMapServices sharedServices].apiKey = @"b72db2635a1fac3e3b89a2bea45f8a13";
    
    //高德地图key for ad version
    
    //bug 跟踪
    [FIR handleCrashWithKey:@"93fe308e58239051b512b539beccc87b"];
    
    
    
    
    return YES;
}


+ (SocketIO*) getMySocket
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return app.mysocket;
}

+ (UserInfoModel*)getMyUserInfo
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return app.myInfo;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"regisger success:%@",deviceToken);
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _myInfo.deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    //注册成功，将deviceToken保存到应用服务器数据库中
    if (_myInfo.userID!=nil) {
        
        NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[_myInfo.userID, _myInfo.deviceToken, @"/updateDeviceToken"]forKeys:@[@"user_id", @"device_token", @"childpath"]];
        
        NetWork* netWork = [[NetWork alloc] init];
        [netWork message:message images:nil feedbackcall:nil complete:^{
        } callObject:nil];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // 处理推送消息
    NSLog(@"userinfo:%@",userInfo);
    
    
    
    //    NSLog(@"收到推送消息:%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    //    NSString* msgtype = [userInfo objectForKey:@"msgtype"];
    //
    //    if (_tabBarViewController!=nil) {
    //        if([msgtype isEqual:@"msg"]){
    //            _tabBarViewController.selectedIndex = 2;
    //            UINavigationController* selectedNav = (UINavigationController*)_tabBarViewController.selectedViewController;
    //            [selectedNav popToRootViewControllerAnimated:NO];
    //        }
    //
    ////        if([msgtype isEqual:@"comment"]){
    ////
    ////            NSString* contentID = [userInfo objectForKey:@"content_id"];
    ////            app.tabBarViewController.selectedIndex = 0;
    ////            UINavigationController* selectedNav = (UINavigationController*)app.tabBarViewController.selectedViewController;
    ////            [selectedNav popToRootViewControllerAnimated:NO];
    ////            ContentDetailViewController* contentDetailView = [[ContentDetailViewController alloc] init];
    ////
    ////            contentDetailView.contentID = contentID;
    ////            contentDetailView.hidesBottomBarWhenPushed = YES;
    ////
    ////            [selectedNav pushViewController:contentDetailView animated:NO];
    ////        }
    //    }
    
    
    //    if(_myInfo.deviceToken!=nil){
    //        NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[_myInfo.userID, _myInfo.deviceToken, @"/updateDeviceToken"]forKeys:@[@"user_id", @"device_token", @"childpath"]];
    //
    //        NetWork* netWork = [[NetWork alloc] init];
    //        [netWork message:message images:nil feedbackcall:nil complete:^{
    //        } viewController:nil];
    //    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Registfail%@",error);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    //    [application beginBackgroundTaskWithExpirationHandler:^{
    //        ;
    //    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"applicationDidBecomeActive");
    
    if(_myInfo.deviceToken!=nil){
        NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[_myInfo.userID, _myInfo.deviceToken, @"/updateDeviceToken"]forKeys:@[@"user_id", @"device_token", @"childpath"]];
        
        NetWork* netWork = [[NetWork alloc] init];
        [netWork message:message images:nil feedbackcall:nil complete:^{
        } callObject:nil];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    //get missed msg
    if (_tabBarViewController != nil&&_tabBarViewController.selectedIndex!=2) {
        UINavigationController* msgNav = (UINavigationController*)[_tabBarViewController.viewControllers objectAtIndex:2];
        [msgNav popToRootViewControllerAnimated:NO];
        MessageTableViewController* msgTableViewCtrl = (MessageTableViewController*)msgNav.topViewController;
        [msgTableViewCtrl checkMissedMsg];
    }
    
    //    if(_tabBarViewController!=nil){
    //        UINavigationController* contentNav = (UINavigationController*)[_tabBarViewController.viewControllers objectAtIndex:0];
    //        [contentNav popToRootViewControllerAnimated:NO];
    //        ContentViewController* content = (ContentViewController*)contentNav.topViewController;
    //        [content checkUnreadMsg];
    //    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"applicationWillTerminate");
}

@end
