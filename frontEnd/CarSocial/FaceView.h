//
//  FaceView.h
//  CarSocial
//
//  Created by wang jam on 12/20/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

@interface FaceView : UIImageView

- (void)setUserInfo:(UserInfoModel*)userInfo nav:(UINavigationController*)nav;
- (void)forbiddenPress;
@property bool primsgButtonShow;

@end
