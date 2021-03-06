//
//  Tools.m
//  CarSocial
//
//  Created by wang jam on 12/14/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "Tools.h"
#import "macro.h"
#import "Constant.h"
#import <MBProgressHUD.h>
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "CocoaSecurity.h"


@implementation Tools
{
    NSMutableDictionary* imageDic;
}

- (id)init
{
    if (self = [super init]) {
        imageDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}


+ (NSString*)getJsonObject:(NSObject*)object
{
    if([object isKindOfClass:[NSNull class]]){
        return @"";
    }else{
        return (NSString*)object;
    }
}

+ (int)getJsonObjectInt:(NSObject*)object
{
    if([object isKindOfClass:[NSNull class]]){
        return 0;
    }else{
        return (int)object;
    }
}


+ (CGRect)relativeFrameForScreenWithView:(UIView *)v
{
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (!iOS7) {
        screenHeight -= 20;
    }
    UIView *view = v;
    CGFloat x = .0;
    CGFloat y = .0;
    while (view.frame.size.width != ScreenWidth || view.frame.size.height != screenHeight) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            x -= ((UIScrollView *) view).contentOffset.x;
            y -= ((UIScrollView *) view).contentOffset.y;
        }
    }
    return CGRectMake(x, y, v.frame.size.width, v.frame.size.height);
}


+ (NSString*)showTime:(long)timeStamp
{
    long nowTimeStamp = [[NSDate date] timeIntervalSince1970];
    int intervals = abs((int)timeStamp - (int)nowTimeStamp);
    int mins;
    int hours;
    int days;
    NSString* showTimeStr;
    
    if (intervals<3600) {
        mins = intervals/60;
        showTimeStr = [[NSString alloc] initWithFormat:@"%d分钟前", mins];
    }
    else if (intervals<3600*24) {
        hours = intervals/3600;
        showTimeStr = [[NSString alloc] initWithFormat:@"%d小时前", hours];
    }
    else{
        days = intervals/(3600*24);
        if (days>7) {
            showTimeStr = [[NSString alloc] initWithFormat:@"%d周前", days/7];
        }else{
            showTimeStr = [[NSString alloc] initWithFormat:@"%d天前", days];
        }
    }
    return showTimeStr;
}

+ (CLLocationManager*)initLocationManager:(id)delegate
{
    //获取用户地理信息
    if ([CLLocationManager locationServicesEnabled] == false) {
        //alertMsg(@"定位服务无法使用");
    }
    
    CLLocationManager* locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:delegate];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5.0f;
    return locationManager;
}

+ (void)startLocation:(CLLocationManager*)locationManager
{
    NSLog(@"startLocation");
    if (IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];

}


+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize
{
    if([[UIScreen mainScreen] scale] == 2.0){
        UIGraphicsBeginImageContextWithOptions(newsize, NO, 2.0);
    }else{
        UIGraphicsBeginImageContext(newsize);
    }
    
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    if (scaledImage == nil) {
        scaledImage = img;
    }
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize imageUrl:(NSString*)imageUrl
{
    if ([imageDic objectForKey:imageUrl]) {
        return [imageDic objectForKey:imageUrl];
    }
    
    if([[UIScreen mainScreen] scale] == 2.0){
        UIGraphicsBeginImageContextWithOptions(newsize, NO, 2.0);
    }else{
        UIGraphicsBeginImageContext(newsize);
    }
    
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    if (scaledImage == nil) {
        scaledImage = img;
    }
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    
    [imageDic setObject:scaledImage forKey:imageUrl];
    return scaledImage;
}

+ (NSInteger)getAgeFromBirthDay:(NSString*)birthday
{
    if(birthday == nil || [birthday isEqual:@""]){
        return 0;
    }
    
    NSDateComponents *curComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    
    NSDateFormatter*dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date =[dateFormatter dateFromString:birthday];
    
    NSDateComponents *birthComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    return [curComponents year] - [birthComponents year];
    
}

+ (NSString*)getStarDesc:(NSString*)birthday
{
    
    if (birthday == nil) {
        return @"";
    }
    
    NSDateFormatter*dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date =[dateFormatter dateFromString:birthday];
    NSDateComponents *birthComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    
    NSInteger month = [birthComponents month];
    NSInteger i_day = [birthComponents day];
    NSString* retStr = @"";
    
    switch (month) {
        case 1:
            if(i_day>=20 && i_day<=31){
                retStr=@"水瓶座";
            }
            if(i_day>=1 && i_day<=19){
                retStr=@"摩羯座";
            }
            break;
        case 2:
            if(i_day>=1 && i_day<=18){
                retStr=@"水瓶座";
            }
            if(i_day>=19 && i_day<=31){
                retStr=@"双鱼座";
            }
            break;
        case 3:
            if(i_day>=1 && i_day<=20){
                retStr=@"双鱼座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"白羊座";
            }
            break;
        case 4:
            if(i_day>=1 && i_day<=19){
                retStr=@"白羊座";
            }
            if(i_day>=20 && i_day<=31){
                retStr=@"金牛座";
            }
            break;
        case 5:
            if(i_day>=1 && i_day<=20){
                retStr=@"金牛座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"双子座";
            }
            break;
        case 6:
            if(i_day>=1 && i_day<=21){
                retStr=@"双子座";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"巨蟹座";
            }
            break;
        case 7:
            if(i_day>=1 && i_day<=22){
                retStr=@"巨蟹座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"狮子座";
            }
            break;
        case 8:
            if(i_day>=1 && i_day<=22){
                retStr=@"狮子座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"处女座";
            }
            break;
        case 9:
            if(i_day>=1 && i_day<=22){
                retStr=@"处女座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"天秤座";
            }
            break;
        case 10:
            if(i_day>=1 && i_day<=23){
                retStr=@"天秤座";
            }
            if(i_day>=24 && i_day<=31){
                retStr=@"天蝎座";
            }
            break;
        case 11:
            if(i_day>=1 && i_day<=21){
                retStr=@"天蝎座";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"射手座";
            }
            break;
        case 12:
            if(i_day>=1 && i_day<=21){
                retStr=@"射手座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"摩羯座";
            }
            break;
    }
    return retStr;
}


//+ (CGFloat)getContentHeight:(NSString*)textStr maxContentHeight:(float)maxContentHeight
//{
//    if (textStr == nil||[textStr isEqualToString:@""]) {
//        return 0;
//    }
//
//    CGSize boundSize = CGSizeMake(ScreenWidth - 20, maxContentHeight);
//
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};
//
//
//    CGRect requireSize = [textStr boundingRectWithSize:boundSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
//    return requireSize.size.height;
//
//}

+ (NSString*)showDistance:(CLLocation*)location otherLocation:(CLLocation*)otherLocation
{
    double meters = [location distanceFromLocation:otherLocation];
    NSString* showDistanceStr;
    
    if (meters<1000) {
        if(meters<100){
            showDistanceStr = [[NSString alloc] initWithFormat:@"%dm", 100];
        }else{
            showDistanceStr = [[NSString alloc] initWithFormat:@"%d00m", (int)meters/100];
        }
    }else{
        showDistanceStr = [[NSString alloc] initWithFormat:@"%dkm", ((int)meters)/1000];
    }
    return showDistanceStr;
}


+ (CGSize)getTextArrange:(NSString*)text maxRect:(CGSize)maxRect fontSize:(int)fontSize
{
    CGRect size = [text boundingRectWithSize:maxRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return CGSizeMake(size.size.width, size.size.height);
}


+(NSString *) md5: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


+ (void)resizeLabel:(UILabel*)label maxHeight:(int)maxHeight maxWidth:(int)maxWidth fontSize:(int)fontSize
{
    CGSize nameSize = [Tools getTextArrange:label.text maxRect:CGSizeMake(maxWidth, maxHeight) fontSize:fontSize];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, nameSize.width+2, nameSize.height);
}


+ (UINavigationController*)curNavigator
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return (UINavigationController*)app.tabBarViewController.selectedViewController;
}

+ (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

+ (void)AlertMsg:(NSString*)msg
{
    UIViewController* viewCtrl = [Tools appRootViewController];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewCtrl.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = msg;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

+ (void)AlertBigMsg:(NSString*)msg
{
    UIViewController* viewCtrl = [Tools appRootViewController];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewCtrl.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}



+ (NSString*)encodePassword:(NSString*)password
{
    CocoaSecurityResult* encodePassword = [CocoaSecurity md5:password];
    return encodePassword.hexLower;
}


//获得设备型号
+ (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone6";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

@end
