//
//  RegisterPhoneNumViewController.h
//  CarSocial
//
//  Created by wang jam on 8/30/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

@interface RegisterPhoneNumViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property UserInfoModel* userInfo;
@end
