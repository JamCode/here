//
//  FollowUserCell.m
//  here_ios
//
//  Created by wang jam on 12/20/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "FollowUserCell.h"
#import "Constant.h"
#import "macro.h"
#import "Tools.h"
#import <Masonry.h>



@implementation FollowUserCell
{
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _faceView = [[FaceView alloc] init];
        _nickNameLabel = [[UILabel alloc] init];
        _userSignLabel = [[UILabel alloc] init];
        _followButton = [[UIButton alloc] init];
        
        
        [self addSubview:_faceView];
        [self addSubview:_nickNameLabel];
        [self addSubview:_userSignLabel];
        [self addSubview:_followButton];
    }
    return self;

}



- (void)configureCell:(UserInfoModel*)userInfo
{
    [_faceView setUserInfo:userInfo nav:[Tools curNavigator]];
    
    _nickNameLabel.text = userInfo.nickName;
    _userSignLabel.text = userInfo.sign;
    
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(minSpace);
        make.top.mas_equalTo(self.mas_top).offset(minSpace);
        make.size.mas_equalTo(CGSizeMake(6*minSpace, 6*minSpace));
    }];
    
    [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_faceView.mas_right).offset(minSpace);
        make.top.mas_equalTo(_faceView.mas_top);
        make.size.mas_equalTo(CGSizeMake(120, 2*minSpace));
    }];
    
    _nickNameLabel.font = [UIFont fontWithName:@"Arial" size:16];
    
    
    [_userSignLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_faceView.mas_right).offset(minSpace);
        make.top.mas_equalTo(_userSignLabel.mas_bottom).offset(minSpace);
        make.size.mas_equalTo(CGSizeMake(120, 2*minSpace));
    }];
    
    _userSignLabel.font = [UIFont fontWithName:@"Arial" size:14];
    _userSignLabel.textColor = [UIColor grayColor];
    
    
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (CGFloat)followUserCellHeight
{
    return 64;
}

@end
