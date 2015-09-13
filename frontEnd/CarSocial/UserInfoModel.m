//
//  UserInfoModel.m
//  CarSocial
//
//  Created by wang jam on 8/12/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "UserInfoModel.h"
#import "Constant.h"
#import "SynthesizeSingleton.h"
#import "Tools.h"

@implementation UserInfoModel

- (id) init
{
    if (self = [super init]){
        self.nickName = [[NSString alloc] init];
        self.password = [[NSString alloc] init];
        self.company = @"";
        self.sign = @"";
        self.career = @"";
        self.interest = @"";
        self.gender = -1;
        self.email = [[NSString alloc] init];
        self.faceImage = [[UIImage alloc] init];
        _carInfoModel = [[CarInfoModel alloc] init];
        _userImageURLArray = [[NSMutableArray alloc] init];
    }
    return self;
}




-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


- (void)fillWithData:(NSDictionary*)data
{
    NSLog(@"%@", [data objectForKey:@"user_phone"]);
    
    _password = [data objectForKey:@"password"];
    _phoneNum = [data objectForKey:@"user_phone"];
    _userID = [data objectForKey:@"user_id"];
    _nickName = [data objectForKey:@"user_name"];
    _faceImageThumbnailURLStr = [data objectForKey:@"user_facethumbnail"];
    _faceImageURLStr = [data objectForKey:@"user_face_image"];
    
    
    
    _gender = [[data objectForKey:@"user_gender"] intValue];
    
    _career = [data objectForKey:@"user_career"] == [NSNull null]?@"":[data objectForKey:@"user_career"];
    _company = [data objectForKey:@"user_company"] == [NSNull null]?@"":[data objectForKey:@"user_company"];
    _sign = [data objectForKey:@"user_sign"] == [NSNull null]?@"":[data objectForKey:@"user_sign"];
    _interest = [data objectForKey:@"user_interest"] == [NSNull null]?@"":[data objectForKey:@"user_interest"];
    
    _certificateProcess = [[data objectForKey:@"user_certificated_process"] intValue];
    _carInfoModel.carBrandImageURL = [[data objectForKey:@"car_info"] objectForKey:@"car_brand_image_url"];
    _carInfoModel.carBrandDesc = [[data objectForKey:@"car_info"] objectForKey:@"car_brand_desc"];
    _carInfoModel.carTypeDesc = [[data objectForKey:@"car_info"] objectForKey:@"car_type_desc"];
    
    _user_background_image_url = [data objectForKey:@"user_background_image_url"];
    
    _birthday = [data objectForKey:@"user_birth_day"];
    _refresh_timestamp = [[data objectForKey:@"refresh_timestamp"] integerValue];
    
    _age = [Tools getAgeFromBirthDay:_birthday];
    
    _latitude = [[data objectForKey:@"location_latitude"] doubleValue];
    _longitude = [[data objectForKey:@"location_longitude"] doubleValue];
    
}

//data[‘user_phone’] = “登录电话”;
//data[‘code’] = {LOGIN_SUCCESS, LOGIN_FAIL, ERROR}
//LOGIN_SUCCESS: 1010,
//LOGIN_FAIL: 1011,
//ERROR: 1012
//Data[‘user_id’] = “用户id”;
//data[‘user_name’] = “昵称”;
//data[‘user_facethumbnail’] = “头像链接”;
//data[‘user_age’] = “年龄”;
//data[‘user_gender’] = “性别”;
//data[‘user_certificated_process’] = “认证情况”;
//data['car_info'] = {
//	//如果有认证
//	‘car_brand_image_url’:汽车品牌图片url
//	‘car_brand_desc’:汽车品牌描述
//	‘car_type_desc’:汽车类型描述
//}



@end
