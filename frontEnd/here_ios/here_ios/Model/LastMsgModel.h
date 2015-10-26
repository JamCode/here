//
//  LastMsgModel.h
//  CarSocial
//
//  Created by wang jam on 3/2/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastMsgModel : NSObject

@property (nonatomic, retain) NSString* my_user_id;
@property (nonatomic, retain) NSString * counter_face_image_url;
@property (nonatomic, retain) NSString * msg;
@property (nonatomic, retain) NSString * counter_nick_name;
@property (nonatomic, retain) NSString * counter_user_id;
@property NSInteger time_stamp;
@property NSInteger unreadCount;
@property NSInteger msg_type;
@property NSString* msg_srno;

@end
