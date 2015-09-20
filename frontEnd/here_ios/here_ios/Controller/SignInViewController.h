//
//  SignInViewController.h
//  CarSocial
//
//  Created by wang jam on 8/31/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UserInfoModel.h"
@interface SignInViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIApplicationDelegate>

- (void)sendLoginMessage:(UserInfoModel*)userInfo;
@end
