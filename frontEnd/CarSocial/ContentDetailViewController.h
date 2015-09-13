//
//  ActiveDetailViewController.h
//  CarSocial
//
//  Created by wang jam on 12/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentModel.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ContentViewController.h"

@interface ContentDetailViewController : UITableViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UITextViewDelegate, UIAlertViewDelegate, MBProgressHUDDelegate, UITextViewDelegate>

@property ContentModel* contentModel;
@property ContentViewController* parentCtrl;
- (void)showCommentInputView;

@end
