//
//  ActiveModel.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

@interface ActiveModel : NSObject

@property UserInfoModel* userInfo;
@property NSString* activeTitle;

@property NSString* startPosition;
@property NSString* endPosition;
@property NSString* startDate;
@property NSString* activeDesc;
@property NSString* activeType;


@property NSString* personCount;
@property NSInteger watchCount;
@property NSInteger commentCount;
@property NSInteger registerCount;
@property NSInteger publishTimeStamp;

@property NSString* activeID;


@property double longitude;
@property double latitude;
@property int distanceMeters;





@end
