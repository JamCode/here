//
//  PublishCommentViewController.h
//  CarSocial
//
//  Created by wang jam on 12/28/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentModel.h"
#import "UserInfoModel.h"
#import "ContentDetailViewController.h"

@interface PublishCommentViewController : UIViewController<UITextViewDelegate, MBProgressHUDDelegate>

@property ContentModel* contentModel;
@property UserInfoModel* toCommentUser;
@property ContentDetailViewController* contentDetail;

@end
