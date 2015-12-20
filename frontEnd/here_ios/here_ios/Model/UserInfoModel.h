//
//  UserInfoModel.h
//  CarSocial
//
//  Created by wang jam on 8/12/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UserInfoModel : NSObject
{
    
    
}

@property NSString* userID;
@property NSInteger age;
@property NSString* nickName;
@property NSString* email;
@property NSString* password;
@property UIImage* faceImage;
@property NSString* faceImageURLStr;
@property NSString* faceImageThumbnailURLStr;

@property NSString* deviceToken;


@property NSInteger gender; //0 for female 1 for male
@property NSString* certificateNo;//验证码
@property int certificateProcess;
@property NSString* career;
@property NSString* company;
@property NSString* interest;
@property NSString* userIntroduce;

@property NSString* lastMessage;
@property int lastMessageTimestamp;

@property BOOL isCertificated; //是否认证车型
@property NSString* sign; //个人签名

@property NSString* phoneNum;


@property long updateTime;//搜索时间

@property double latitude; //纬度
@property double longitude; //经度
@property NSInteger refresh_timestamp;

@property NSInteger locationTime;

@property NSMutableArray* userImageURLArray;

@property NSString* user_background_image_url;

@property NSString* birthday;


@property NSInteger user_fans_count;
@property NSInteger user_follow_count;

@property NSInteger follow_timestamp;

- (void)fillWithData:(NSDictionary*)data;


@end
