//
//  CarInfoModel.h
//  CarSocial
//
//  Created by wang jam on 8/15/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarInfoModel : NSObject

@property NSString* carBrandDesc;  //车型
@property NSString* carTypeDesc;  //车系

@property NSString* carBrandImageURL;
@property NSString* carTypeURL;
@property UIImage* carBrandImage; //车标图片
@property UIImage* carTypeImage; //车系图片
@end
