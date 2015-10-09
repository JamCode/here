//
//  NearByTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 8/22/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "NearByTableViewCell.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "UserInfoModel.h"
#import "Tools.h"

@implementation NearByTableViewCell
{
    UIImageView* faceImageView;
    
    UILabel* userNameLabel;
    
    UILabel* usersignLabel;
    
    UIImageView* carIcon;
    UIImageView* genderImage;
    UILabel* ageAndGenderLabel;
    UIView* ageAndGenderView;
    
    UILabel* updateTimeAndDistance;
    UILabel* updateDistance;
    
    UserInfoModel* myUserInfo;
    
    
}

static const int faceImageHeight = 68;
static const int faceImageWidth = 68;

static const int userNameLabelHeight = 20;
static const int userSignLabelHeight = 16;

static const int ageAndGenderHeight = 20;
static const int ageAndGenderWidth = 40;

static const int genderImageHeight = 12;

static const int ageHeight = 18;
static const int ageWidth = 18;

static const int updateTimeHeight = 18;
static const int updateTimeWidth = 100;




- (void)clickFace:(id)sender
{
    
    
    SettingViewController* settingViewController = [[SettingViewController alloc] init:myUserInfo];
    settingViewController.priMsgShow = true;
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UINavigationController* parentNav = (UINavigationController*)[app.tabBarViewController.viewControllers objectAtIndex:0];
    
    [parentNav pushViewController:settingViewController animated:YES];
    
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[self layer].shadowPath =[UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        // Initialization code
        faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, faceImageWidth, faceImageHeight)];
        faceImageView.contentMode =  UIViewContentModeScaleAspectFill;
        faceImageView.clipsToBounds  = YES;
        faceImageView.layer.cornerRadius = 6.0;
        faceImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickFace:)];
        [faceImageView addGestureRecognizer:tapGesture];
        
        
        
        //faceImageView.layer.masksToBounds = YES;
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+10+faceImageView.frame.size.width, faceImageView.frame.origin.y, 100, userNameLabelHeight)];
        
        
        
        ageAndGenderView = [[UIView alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+10+faceImageView.frame.size.width, userNameLabel.frame.origin.y+userNameLabel.frame.size.height+5, ageAndGenderWidth, ageAndGenderHeight)];
        ageAndGenderView.layer.cornerRadius = 4.0;
        //ageAndGenderView.layer.masksToBounds = YES;
        
        genderImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 4, genderImageHeight, genderImageHeight)];
        
        genderImage.contentMode = UIViewContentModeScaleAspectFill;
        
        
        [ageAndGenderView addSubview:genderImage];
        
        ageAndGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(genderImage.frame.origin.x+genderImage.frame.size.width, 2, ageWidth, ageHeight)];
        
        
        ageAndGenderLabel.textAlignment = NSTextAlignmentCenter;
        ageAndGenderLabel.font = [UIFont fontWithName:@"Arial" size:12];
        ageAndGenderLabel.textColor = [UIColor whiteColor];
        [ageAndGenderView addSubview: ageAndGenderLabel];
        
        
        usersignLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+10+faceImageView.frame.size.width, ageAndGenderView.frame.origin.y+ageAndGenderView.frame.size.height+5, 120, userSignLabelHeight)];
        usersignLabel.textColor = [UIColor grayColor];
        usersignLabel.font = [UIFont fontWithName:@"Arial" size:14];
        
        
//        carIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ageAndGenderView.frame.origin.x+ageAndGenderView.frame.size.width+5, ageAndGenderView.frame.origin.y, carIconWidth, carIconHeight)];
//        carIcon.contentMode = UIViewContentModeScaleAspectFill;
//        carIcon.clipsToBounds  = YES;
        
        updateTimeAndDistance = [[UILabel alloc] initWithFrame:CGRectMake(220, userNameLabel.frame.origin.y, updateTimeWidth, updateTimeHeight)];
        updateTimeAndDistance.textColor = [UIColor grayColor];
        updateTimeAndDistance.font = [UIFont fontWithName:@"Arial" size:12];
        
        //[self addSubview:carIcon];
        [self addSubview:ageAndGenderView];
        [self addSubview:userNameLabel];
        [self addSubview:usersignLabel];
        [self addSubview:faceImageView];
        [self addSubview:updateTimeAndDistance];
    }
    return self;
}

- (NSString*)showTime:(long)timeStamp
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
        showTimeStr = [[NSString alloc] initWithFormat:@"%d天前", days];
    }
    return showTimeStr;
}

- (NSString*)showDistance:(CLLocation*)location otherLocation:(CLLocation*)otherLocation
{
    
    double meters = [location distanceFromLocation:otherLocation];
    NSString* showDistanceStr;
    
    if (meters<1000) {
        showDistanceStr = [[NSString alloc] initWithFormat:@"%dm", (int)meters];
    }else{
        showDistanceStr = [[NSString alloc] initWithFormat:@"%dkm", ((int)meters)/1000];
    }
    return showDistanceStr;
}

- (void)setUserInfo:(UserInfoModel*)userInfo
{
    
    myUserInfo = userInfo;
    [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:userInfo.faceImageThumbnailURLStr]];
//
//
    userNameLabel.text = userInfo.nickName;
    
    
    
    usersignLabel.text = userInfo.sign;
    
//
    
    if (userInfo.gender==0) {
        genderImage.image = [UIImage imageNamed:@"woman32white.png"];
        ageAndGenderView.backgroundColor = genderPink;
    }else{
        genderImage.image = [UIImage imageNamed:@"man32white.png"];
        ageAndGenderView.backgroundColor = subjectColor;
    }
    
    ageAndGenderLabel.text = [[NSString alloc] initWithFormat:@"%ld", userInfo.age];
    
    
    CLLocation* userLocation = [[CLLocation alloc] initWithLatitude:userInfo.latitude longitude:userInfo.longitude];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CLLocation* myLocation = [[CLLocation alloc] initWithLatitude:app.myInfo.latitude longitude:app.myInfo.longitude];
    
    NSLog(@"%f, %f", userInfo.latitude, app.myInfo.latitude);
    updateTimeAndDistance.text = [[NSString alloc] initWithFormat:@"%@ | %@", [self showTime:userInfo.refresh_timestamp], [Tools showDistance:userLocation otherLocation:myLocation]];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
