//
//  SettingChildViewController.h
//  CarSocial
//
//  Created by wang jam on 9/24/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"

//用户资料编辑子页面
@interface SettingChildViewController : UIViewController<UITextViewDelegate>

@property NSMutableArray* settingStrArray;
@property NSMutableArray* settingTitleArray;
@property NSInteger index;
@property SettingViewController* parent;

@end
