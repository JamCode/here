//
//  NetWork.h
//  CarSocial
//
//  Created by wang jam on 8/27/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^messageComplete)(void);
typedef void(^msgCallback)(id);


@interface NetWork : NSObject
{
    
}

- (void)message:(NSDictionary*)message images:(NSDictionary*)images feedbackcall:(NSDictionary*)feedbackcall complete:(messageComplete)complete callObject:(id)callObject;


- (NSError*)sendMessageSyn:(NSURL*)url message:(NSDictionary*)message feedbackMessage:(NSMutableDictionary**)feedback;


- (NSError*)sendImageAndMessageSyn:(NSURL*)url message:(NSDictionary*)message feedbackMessage:(NSMutableDictionary**)feedback images:(NSMutableDictionary*)images;


@end

extern const NSString* domainServer;
