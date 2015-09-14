//
//  PublishActivityViewController.h
//  CarSocial
//
//  Created by wang jam on 11/20/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface PublishContentViewController : UIViewController<UITextViewDelegate,UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MBProgressHUDDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, MAMapViewDelegate, AMapSearchDelegate>

@property ContentViewController* contentViewController;

@property NSString* address;


@end
