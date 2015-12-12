//
//  AppDelegate.h
//  CarSocial
//
//  Created by wang jam on 8/5/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"
#import "SocketIO.h"
//#import "socket.IO-objc/SocketIO.h"
#import "TWTSideMenuViewController.h"
#import "LocDatabase.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate>

@property (strong, nonatomic) UIWindow *window;

@property UserInfoModel* myInfo;
@property LocDatabase* locdatabase;

@property SocketIO* mysocket;
@property UITabBarController* tabBarViewController;
@property TWTSideMenuViewController* sideMenu;


@property NSString* serverDomain;
@property NSString* socketIP;
@property NSInteger socketPort;


+ (SocketIO*) getMySocket;
+ (UserInfoModel*)getMyUserInfo;
- (NSString*)getMyID;
- (void)backToStartView;

@end
