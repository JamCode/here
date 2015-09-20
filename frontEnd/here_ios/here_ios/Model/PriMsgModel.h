//
//  PriMsgModel.h
//  CarSocial
//
//  Created by wang jam on 9/26/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

@interface PriMsgModel : NSObject


@property long msg_type; //消息类型,时间戳，消息，loading，图片，语音

@property NSString* msg_id;
@property NSString* sender_user_id;
@property NSString* receive_user_id;
@property NSString* message_content;
@property NSInteger send_timestamp;
@property NSInteger sendStatus;
@property NSData* data;
@property int voiceTime;
@property BOOL voiceStart;
@property int unread;
@property NSString* msg_srno;

@end
