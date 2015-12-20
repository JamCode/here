//
//  FollowUserCell.h
//  here_ios
//
//  Created by wang jam on 12/20/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"


@interface FollowUserCell : UITableViewCell


@property UIImageView* faceView;
@property UILabel* nickNameLabel;
@property UILabel* userSignLabel;
@property UIButton* followButton;

+ (CGFloat)followUserCellHeight;

- (void)configureCell:(UserInfoModel*)userInfo;


@end
