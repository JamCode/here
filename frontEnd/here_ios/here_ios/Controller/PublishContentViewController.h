//
//  PublishActivityViewController.h
//  CarSocial
//
//  Created by wang jam on 11/20/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <CoreLocation/CoreLocation.h>

@interface PublishContentViewController : UIViewController<UITextViewDelegate,UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MBProgressHUDDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>


@property NSString* address;


@end
