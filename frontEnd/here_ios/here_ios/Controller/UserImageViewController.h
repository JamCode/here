//
//  UserImageViewController.h
//  CarSocial
//
//  Created by wang jam on 10/7/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"

@interface UserImageViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property NSURL* imageURL;
@property UIImage* imageThumbnail;
@property SettingViewController* parentView;
@property BOOL isFaceImage;
@end
