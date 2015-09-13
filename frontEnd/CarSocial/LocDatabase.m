//
//  LocDatabase.m
//  CarSocial
//
//  Created by wang jam on 9/26/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "LocDatabase.h"
#import <CoreData/CoreData.h>
#import "Pri_msg.h"
#import "PriMsgModel.h"
#import "Last_pri_msg.h"
#import "macro.h"

@implementation LocDatabase
{
    NSManagedObjectModel *model;
    NSPersistentStoreCoordinator *psc;
    NSPersistentStore *store;
    NSManagedObjectContext *context;
}

- (BOOL)connectToDatabase
{
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    //NSManagedObjectModel* model = [[NSManagedObjectModel alloc] init];
    
    // 传入模型对象，初始化NSPersistentStoreCoordinator
    psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 构建SQLite数据库文件的路径
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"carSocial.data"]];
    // 添加持久化存储库，这里使用SQLite作为存储库
    NSError *error = nil;
    store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    if (store == nil) { // 直接抛异常
        [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
        return false;
    }
    // 初始化上下文，设置persistentStoreCoordinator属性
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;

    return YES;
}


- (NSArray*) readPriMsgByUserID:(NSString*)userID otherUserID:(NSString*)otherUserID MinTimeStamp:(NSInteger)timeStamp LimitCount:(NSInteger)limitCount
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Loc_pri_msg" inManagedObjectContext:context]];
    [fetchRequest setFetchLimit:limitCount];
    
    //NSNumber* timeStamp_num = [[NSNumber alloc] initWithInteger:timeStamp];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"((receive_user_id = '%@' and sender_user_id='%@') or (receive_user_id = '%@' and sender_user_id='%@')) and send_timestamp<%ld", userID, otherUserID, otherUserID, userID, timeStamp]];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"send_timestamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError* error;
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    
    for (Pri_msg* msg in fetchController.fetchedObjects) {
        PriMsgModel* priMsg = [[PriMsgModel alloc] init];
        priMsg.message_content = msg.message_content;
        priMsg.receive_user_id = msg.receive_user_id;
        priMsg.sender_user_id = msg.sender_user_id;
        priMsg.send_timestamp = [msg.send_timestamp intValue];
        priMsg.msg_type = [msg.msg_type intValue];
        priMsg.voiceTime = [msg.voice_time doubleValue];
        priMsg.data = msg.data;
        priMsg.unread = [msg.unread intValue];
        priMsg.msg_srno = msg.msg_srno;
        priMsg.sendStatus = [msg.send_status integerValue];
        
        [temp insertObject:priMsg atIndex:0];
    }
    
    return temp;
}

- (BOOL)writeLastPriMsgToDatabase:(LastMsgModel*)priMsg
{
    //删除之前的最近记录
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Last_pri_msg" inManagedObjectContext:context]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"counter_user_id = '%@'", priMsg.counter_user_id]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time_stamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError* error;
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }
    
    for (Last_pri_msg* msg in fetchController.fetchedObjects) {
        if (msg.time_stamp>[[NSNumber alloc] initWithInteger:priMsg.time_stamp]) {
            return true;
        }
        [context deleteObject:msg];
    }
    
    
    //插入最新的最近记录
    Last_pri_msg* msg = [NSEntityDescription insertNewObjectForEntityForName:@"Last_pri_msg" inManagedObjectContext:context];
    msg.counter_user_id = priMsg.counter_user_id;
    msg.counter_face_image_url = priMsg.counter_face_image_url;
    msg.time_stamp = [[NSNumber alloc] initWithInteger:priMsg.time_stamp];
    msg.msg= priMsg.msg;
    msg.counter_nick_name = priMsg.counter_nick_name;
    msg.unreadCount = [[NSNumber alloc] initWithInteger:priMsg.unreadCount];
    msg.msg_type = [[NSNumber alloc] initWithInteger:priMsg.msg_type];
    msg.msg_srno = priMsg.msg_srno;
    
    NSLog(@"%ld", [msg.msg_type integerValue]);
    NSLog(@"%ld", [msg.unreadCount integerValue]);
    if (![context save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }
    
    return TRUE;
}

- (PriMsgModel*)getPriMsgByMsgID:(NSString*)msg_id
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Loc_pri_msg" inManagedObjectContext:context]];
    [fetchRequest setFetchLimit:1];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"msg_id = '%@'", msg_id]];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"send_timestamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }
    
    if ([fetchController.fetchedObjects count] == 0) {
        return nil;
    }
    
    Pri_msg* msg = [fetchController.fetchedObjects objectAtIndex:0];
    PriMsgModel* priMsg = [[PriMsgModel alloc] init];
    priMsg.message_content = msg.message_content;
    priMsg.receive_user_id = msg.receive_user_id;
    priMsg.sender_user_id = msg.sender_user_id;
    priMsg.send_timestamp = [msg.send_timestamp intValue];
    priMsg.data = msg.data;
    priMsg.msg_type = [msg.msg_type intValue];
    priMsg.unread = [msg.unread intValue];
    priMsg.msg_srno = msg.msg_srno;
    priMsg.sendStatus = [msg.send_status integerValue];
    
    return priMsg;

}

- (BOOL)writePriMsgToDatabase:(PriMsgModel*)priMsg
{
    NSLog(@"insert");

    NSError* error;
    Pri_msg* msg = [NSEntityDescription insertNewObjectForEntityForName:@"Loc_pri_msg" inManagedObjectContext:context];
    msg.msg_id = priMsg.msg_id;
    msg.sender_user_id = priMsg.sender_user_id;
    msg.receive_user_id = priMsg.receive_user_id;
    msg.send_timestamp = [[NSNumber alloc] initWithInteger:priMsg.send_timestamp];
    msg.message_content = priMsg.message_content;
    msg.msg_type = [[NSNumber alloc] initWithLong:priMsg.msg_type];
    msg.voice_time = [[NSNumber alloc] initWithInt:priMsg.voiceTime];
    msg.data = priMsg.data;
    msg.unread = [[NSNumber alloc] initWithInt:priMsg.unread];
    msg.send_status = [[NSNumber alloc] initWithInteger:priMsg.sendStatus];
    
    if ([priMsg.msg_srno isEqual:[NSNull null]]) {
        //previous version not have msg_srno
        priMsg.msg_srno = priMsg.msg_id;
    }
    msg.msg_srno = priMsg.msg_srno;
    
    if (![context save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }

    return TRUE;
}

- (PriMsgModel*)getRecentLastMsgFromDatabase:(NSString*)myuserID
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Loc_pri_msg" inManagedObjectContext:context]];
    [fetchRequest setFetchLimit:1];
    
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"send_timestamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"receive_user_id = '%@'", myuserID]];
    [fetchRequest setPredicate:predicate];
    
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError* error;
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }
    
    for (Pri_msg* msg in fetchController.fetchedObjects) {
        PriMsgModel* priMsg = [[PriMsgModel alloc] init];
        priMsg.message_content = msg.message_content;
        priMsg.receive_user_id = msg.receive_user_id;
        priMsg.sender_user_id = msg.sender_user_id;
        priMsg.send_timestamp = [msg.send_timestamp intValue];
        priMsg.msg_type = [msg.msg_type intValue];
        priMsg.data = msg.data;
        priMsg.unread = [msg.unread intValue];
        priMsg.msg_srno = msg.msg_srno;
        priMsg.sendStatus = [msg.send_status integerValue];
        
        return priMsg;
    }
    
    return nil;
}

- (LastMsgModel*)getLastMsgByUser:(NSString*)counterID;
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Last_pri_msg" inManagedObjectContext:context]];
    [fetchRequest setFetchLimit:1];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"counter_user_id = '%@'", counterID]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time_stamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    NSError* error;
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }
    
    for (Last_pri_msg* msg in fetchController.fetchedObjects) {
        LastMsgModel* priMsg = [[LastMsgModel alloc] init];
        priMsg.time_stamp =  [msg.time_stamp integerValue];
        priMsg.counter_nick_name = msg.counter_nick_name;
        priMsg.counter_user_id = msg.counter_user_id;
        priMsg.counter_face_image_url = msg.counter_face_image_url;
        priMsg.msg = msg.msg;
        priMsg.msg_type = [msg.msg_type integerValue];
        priMsg.msg_srno = msg.msg_srno;
        return priMsg;
    }
    
    return nil;
}

- (NSMutableArray*)getLastMsgFromDatabase
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Last_pri_msg" inManagedObjectContext:context]];
    
    
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time_stamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError* error;
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (Last_pri_msg* msg in fetchController.fetchedObjects) {
        LastMsgModel* priMsg = [[LastMsgModel alloc] init];
        priMsg.time_stamp =  [msg.time_stamp integerValue];
        priMsg.counter_nick_name = msg.counter_nick_name;
        priMsg.counter_user_id = msg.counter_user_id;
        priMsg.counter_face_image_url = msg.counter_face_image_url;
        priMsg.msg = msg.msg;
        priMsg.unreadCount = [msg.unreadCount integerValue];
        priMsg.msg_type = [msg.msg_type integerValue];
        priMsg.msg_srno = msg.msg_srno;
        [result addObject:priMsg];
    }
    return result;
}

- (BOOL)updatePriMsg:(PriMsgModel*)priMsg
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Loc_pri_msg" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"msg_srno = '%@'", priMsg.msg_srno]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:fetchRequest error:nil];
    
    if ([dataArray count]>0) {
        Pri_msg* msg = [dataArray objectAtIndex:0];
        msg.unread = [[NSNumber alloc] initWithInt:priMsg.unread];
        msg.send_status = [[NSNumber alloc] initWithInteger:priMsg.sendStatus];
        BOOL result = [context save:nil];
        return result;
    }
    
    return false;

}

- (BOOL)deleteMsg:(LastMsgModel*)lastMsg
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Last_pri_msg" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"counter_user_id = '%@'", lastMsg.counter_user_id]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time_stamp" ascending:NO];
    NSArray* desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    
    NSFetchedResultsController* fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError* error;
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }
    
    for (Last_pri_msg* msg in fetchController.fetchedObjects) {
        [context deleteObject:msg];
    }
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Loc_pri_msg" inManagedObjectContext:context]];
    predicate = [NSPredicate predicateWithFormat:[[NSString alloc] initWithFormat:@"receive_user_id = '%@' or sender_user_id = '%@'", lastMsg.counter_user_id, lastMsg.counter_user_id]];
    [fetchRequest setPredicate:predicate];
    sortDesc = [[NSSortDescriptor alloc] initWithKey:@"send_timestamp" ascending:NO];
    desc = [NSArray arrayWithObject:sortDesc];
    [fetchRequest setSortDescriptors:desc];
    fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    if (![fetchController performFetch:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }
    
    for (Pri_msg* msg in fetchController.fetchedObjects) {
        NSLog(@"%@", msg.message_content);
        [context deleteObject:msg];
    }
    
    
    if (![context save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
        return FALSE;
    }
    return true;
}



@end
