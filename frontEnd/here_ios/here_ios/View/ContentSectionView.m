//
//  ContentSectionView.m
//  here_ios
//
//  Created by wang jam on 11/27/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "ContentSectionView.h"
#import "FaceView.h"
#import <Masonry.h>
#import "UserInfoModel.h"
#import "Tools.h"
#import "ContentModel.h"
#import "macro.h"
#import "Constant.h"


@implementation ContentSectionView
{
    FaceView* faceView;
    UILabel* userNameLabel;
    UILabel* timeLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


static long contentSectionHeight = 54;
static long face_height = 34;
static long userNameFont = 14;
static long timeFont = 14;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        faceView = [[FaceView alloc] init];
        userNameLabel = [[UILabel alloc] init];
        timeLabel = [[UILabel alloc] init];
        
        [self addSubview:faceView];
        [self addSubview:userNameLabel];
        [self addSubview:timeLabel];
        
        self.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.9];
        
        CALayer *border = [CALayer layer];
        border.frame = CGRectMake(0.0f, frame.size.height - 0.1f, ScreenWidth, 0.1f);
        border.backgroundColor = [UIColor lightGrayColor].CGColor;
        [self.layer addSublayer:border];
        
        
    }
    return self;
}

- (void)configure:(ContentModel*)contentModel
{
    [faceView setUserInfo:contentModel.userInfo nav:[Tools curNavigator]];
    userNameLabel.text = contentModel.userInfo.nickName;
    timeLabel.text = [Tools showTime:contentModel.publishTimeStamp];
}

+ (NSInteger)contentSectionHeight
{
    return contentSectionHeight;
}

- (void)layoutSubviews
{
    [faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(10);
        make.left.mas_equalTo(self.mas_left).with.offset(10);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(face_height, face_height));
    }];
    
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(faceView.mas_right).offset(10);
        make.centerY.mas_equalTo(faceView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth*2/3, face_height));
    }];
    userNameLabel.textColor = subjectColor;
    userNameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:userNameFont];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(64, face_height));
        make.centerY.mas_equalTo(faceView.mas_centerY);
    }];
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.font = [UIFont fontWithName:@"Arial" size:timeFont];
}



@end
