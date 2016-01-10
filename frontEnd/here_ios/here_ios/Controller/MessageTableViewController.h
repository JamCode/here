//
//  MessageTableViewController.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
@interface MessageTableViewController : UITableViewController<SocketIODelegate, NSURLConnectionDelegate>
- (void)checkMissedMsg;

- (void)deleteMsg:(NSString*)user_id;

@end
