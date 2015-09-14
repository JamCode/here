//
//  MessageTableViewController.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "socket.IO-objc/SocketIO.h"
@interface MessageTableViewController : UITableViewController<SocketIODelegate>
- (void)checkMissedMsg;

- (void)deleteMsg:(NSString*)user_id;

@end
