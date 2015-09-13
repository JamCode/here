//
//  TalkViewController.h
//  miniWeChat
//
//  Created by wang jam on 5/12/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"
#import "socket.IO-objc/SocketIO.h"
#import <AVFoundation/AVFoundation.h>
#import "Mp3Recorder.h"
#import "PriMsgModel.h"

@class FriendMsgMode;
@class MessageTableViewController;
@interface TalkViewController : UIViewController<UITextViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate, SocketIODelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, Mp3RecorderDelegate>

- (void)sendDataToServer:(PriMsgModel*)priMsg;
- (UITableView*)getTableView;

@property UserInfoModel* counterInfo;

@property MessageTableViewController* parentCtrl;

@property AVAudioRecorder *recorder;

- (void)BackgroundViewButtonAction:(id)sender;

@end
