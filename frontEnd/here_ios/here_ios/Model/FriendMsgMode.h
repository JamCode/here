//
//  FriendMsgMode.h
//  CarSocial
//
//  Created by wang jam on 2/26/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"
#import "TalkViewController.h"

@interface FriendMsgMode : NSObject
@property UserInfoModel* userInfo;
@property NSString* message;

@property NSInteger lastTimeStamp; //priMsgList中最大的时间戳
//@property TalkViewController* talk;
@end
