//
//  TimeFunction.m
//  CarSocial
//
//  Created by wang jam on 10/11/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "TimeFunction.h"

@implementation TimeFunction

+ (NSString*)showTime:(long)timeStamp
{
    long nowTimeStamp = [[NSDate date] timeIntervalSince1970];
    long intervals = abs((int)timeStamp - (int)nowTimeStamp);
    long mins;
    long hours;
    long days;
    NSString* showTimeStr;
    
    if (intervals<3600) {
        mins = intervals/60;
        showTimeStr = [[NSString alloc] initWithFormat:@"%ld分钟前", mins];
    }
    else if (intervals<3600*24) {
        hours = intervals/3600;
        showTimeStr = [[NSString alloc] initWithFormat:@"%ld小时前", hours];
    }
    else{
        days = intervals/(3600*24);
        showTimeStr = [[NSString alloc] initWithFormat:@"%ld天前", days];
    }
    return showTimeStr;
}

@end
