//
//  TalkCellViewTableViewCell.h
//  miniWeChat
//
//  Created by wang jam on 5/18/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"
#import "UserInfoModel.h"
#import "PriMsgModel.h"
#import "UUAVAudioPlayer.h"

@class TalkViewController;

@interface TalkTableViewCell : UITableViewCell<UUAVAudioPlayerDelegate, UIScrollViewDelegate>


@property FaceView* faceImage;
@property NSString* msg;
@property UIButton* msgButton;
@property UIActivityIndicatorView* activeLoadingView;
@property UINavigationController* parent;
@property UILabel* voiceTimelabel;
@property UIView* unreadNotify;
@property UIImageView* sendFailedIcon;

@property TalkViewController* parentViewCtrl;


- (void)setTalkCell:(UserInfoModel*)myInfo counter:(UserInfoModel*)counter msg:(PriMsgModel*)priMsg;
+ (CGFloat)getImageHeight:(NSData*)data;


+ (CGFloat)getCellHeight:(NSString*) msg msgButtonHeight:(CGFloat*)msgButtonHeight msgButtonWidth:(CGFloat*)msgButtonWidth;

@end
