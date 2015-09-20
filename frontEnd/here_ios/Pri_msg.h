//
//  Pri_msg.h
//  CarSocial
//
//  Created by wang jam on 7/12/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pri_msg : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * message_content;
@property (nonatomic, retain) NSString * msg_id;
@property (nonatomic, retain) NSNumber * msg_type;
@property (nonatomic, retain) NSString * receive_user_id;
@property (nonatomic, retain) NSNumber * send_status;
@property (nonatomic, retain) NSNumber * send_timestamp;
@property (nonatomic, retain) NSString * sender_user_id;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSNumber * voice_time;
@property (nonatomic, retain) NSString * msg_srno;

@end
