//
//  MapPointModel.h
//  CarSocial
//
//  Created by wang jam on 5/5/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface MapPointModel : MAPointAnnotation

@property NSString* user_id;
@property NSInteger gender;
@property NSString* faceUrl;
@property NSString* nickName;
@property NSInteger refreshTime;
@property NSInteger age;
@property NSString* sign;

@end
