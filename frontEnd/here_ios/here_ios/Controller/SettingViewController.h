//
//  SettingViewController.h
//  CarSocial
//
//  Created by wang jam on 9/13/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

@interface SettingViewController : UITableViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIActionSheetDelegate>

@property BOOL changedFlag;
@property BOOL deleteUserImageFlag;
@property BOOL priMsgShow;

@property UserInfoModel* userInfo;


- (id)init:(UserInfoModel*)whoInfo;
- (void)setFaceImageView:(NSURL*)url;
- (NSMutableArray*)getUserImageArray;

@end






