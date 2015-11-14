//
//  LocDatabase.h
//  CarSocial
//
//  Created by wang jam on 9/26/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pri_msg.h"
#import "PriMsgModel.h"
#import "LastMsgModel.h"
@interface LocDatabase : NSObject




- (BOOL)connectToDatabase:(NSString*)fileName;

- (NSArray*) readPriMsgByUserID:(NSString*)userID otherUserID:(NSString*)otherUserID MinTimeStamp:(NSInteger)timeStamp LimitCount:(NSInteger)limitCount;

- (BOOL)writePriMsgToDatabase:(PriMsgModel*)priMsg;

- (BOOL)writeLastPriMsgToDatabase:(LastMsgModel*)priMsg;

- (NSMutableArray*)getLastMsgFromDatabase;

- (PriMsgModel*)getRecentLastMsgFromDatabase;

- (LastMsgModel*)getLastMsgByUser:(NSString*)counterID;

- (PriMsgModel*)getPriMsgByMsgID:(NSString*)msg_id;

- (BOOL)deleteMsg:(LastMsgModel*)lastMsg;

- (BOOL)updatePriMsg:(PriMsgModel*)priMsg;

//- (BOOL)deleteUserAllMsg:(NSString*)user_id;


@end
