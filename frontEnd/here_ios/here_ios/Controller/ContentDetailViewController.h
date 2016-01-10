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
#import "InputToolbar.h"
#import "CommentModel.h"

@interface ContentDetailViewController : UITableViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UITextViewDelegate, UIAlertViewDelegate, MBProgressHUDDelegate, UITextViewDelegate, InputToolbarDelegate>

@property ContentModel* contentModel;


- (void)addNewCommentCell:(CommentModel*)commentModel;


@end
