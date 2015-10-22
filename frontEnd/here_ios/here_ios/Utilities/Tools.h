//
//  Tools.h
//  CarSocial
//
//  Created by wang jam on 12/14/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface Tools : NSObject

+ (NSString*)getJsonObject:(NSObject*)object;
+ (CGRect)relativeFrameForScreenWithView:(UIView *)v;
+ (NSString*)showTime:(long)timeStamp;
+ (CLLocationManager*)initLocationManager:(id)delegate;
+ (void)startLocation:(CLLocationManager*)locationManager;
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize imageUrl:(NSString*)imageUrl;
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize;

+ (NSInteger)getAgeFromBirthDay:(NSString*)birthday;

+ (NSString*)getStarDesc:(NSString*)birthday;


+ (CGSize)getTextArrange:(NSString*)text maxRect:(CGSize)maxRect fontSize:(int)fontSize;

+ (int)getJsonObjectInt:(NSObject*)object;

+ (NSString*)showDistance:(CLLocation*)location otherLocation:(CLLocation*)otherLocation;

+ (void)resizeLabel:(UILabel*)label maxHeight:(int)maxHeight maxWidth:(int)maxWidth fontSize:(int)fontSize;

+ (UIViewController *)appRootViewController;

+ (void)AlertMsg:(NSString*)msg;
+ (void)AlertBigMsg:(NSString*)msg;


+ (UINavigationController*)curNavigator;


+ (NSString *)getCurrentDeviceModel;

+ (NSString*)encodePassword:(NSString*)password;


@end
