//
//  Last_pri_msg.h
//  CarSocial
//
//  Created by wang jam on 7/12/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Last_pri_msg : NSManagedObject

@property (nonatomic, retain) NSString * my_user_id;
@property (nonatomic, retain) NSString * counter_face_image_url;
@property (nonatomic, retain) NSString * counter_nick_name;
@property (nonatomic, retain) NSString * counter_user_id;
@property (nonatomic, retain) NSString * msg;
@property (nonatomic, retain) NSNumber * msg_type;
@property (nonatomic, retain) NSNumber * send_status;
@property (nonatomic, retain) NSNumber * time_stamp;
@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic, retain) NSString * msg_srno;

@end
