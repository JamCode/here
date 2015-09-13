//
//  ActiveModel.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

@interface ContentModel : NSObject


- (void)setContentModel:(NSDictionary*)element;

@property UserInfoModel* userInfo;
@property NSString* activeTitle;

@property NSString* startPosition;
@property NSString* endPosition;
@property NSString* startDate;
@property NSString* activeDesc;
@property NSString* activeType;


@property NSString* personCount;
@property NSInteger watchCount;
@property NSInteger goodCount;
@property NSInteger commentCount;
@property NSInteger registerCount;
@property NSInteger publishTimeStamp;

@property NSString* contentID;
@property int to_content;

@property double longitude;
@property double latitude;
@property int distanceMeters;



@property NSString* imageUrlStr;
@property NSMutableArray* imageModelArray;
@property NSString* contentStr;
@property NSInteger anonymous;

@property BOOL canBeDeleted;

@property NSString* address;

@property BOOL goodFlag;
@property BOOL commentFlag;


@property BOOL collectFlag;

@property NSMutableDictionary* contentImageDic; //content image thumbnail url ->content image url


@end
