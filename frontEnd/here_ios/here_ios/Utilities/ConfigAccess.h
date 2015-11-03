//
//  ConfigAccess.h
//  here_ios
//
//  Created by wang jam on 11/3/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigAccess : NSObject

+ (NSString*)serverDomain;
+ (NSString*)socketIP;
+ (NSInteger)socketPort;

@end
