//
//  FaceView.m
//  CarSocial
//
//  Created by wang jam on 12/20/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "FaceView.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SettingChildViewController.h"
#import "Tools.h"


@implementation FaceView
{
    UserInfoModel* myinfo;
    UINavigationController* parentNav;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}


- (void)setUserInfo:(UserInfoModel*)userInfo nav:(UINavigationController*)nav
{
    myinfo = userInfo;
    parentNav = nav;
    _primsgButtonShow = YES;
    
    self.userInteractionEnabled = YES;
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceViewPress:)]];
    
    
    
}

- (void)forbiddenPress
{
    self.userInteractionEnabled = NO;
}

- (void)faceViewPress:(id)sender
{
    SettingViewController* settingViewController = [[SettingViewController alloc] init:myinfo];
    settingViewController.hidesBottomBarWhenPushed = YES;
    settingViewController.priMsgShow = _primsgButtonShow;
    
    [[Tools curNavigator] pushViewController:settingViewController animated:YES];
}

@end
