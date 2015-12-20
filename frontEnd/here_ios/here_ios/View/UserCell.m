//
//  UserCell.m
//  here_ios
//
//  Created by wang jam on 12/13/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "UserCell.h"
#import <Masonry.h>
#import "Constant.h"

@implementation UserCell


const int faceHeight = 48;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _faceImageView = [[UIImageView alloc] init];
        _userSign = [[UILabel alloc] init];
        _nickNameLabel = [[UILabel alloc] init];
        
        [self addSubview:_faceImageView];
        [self addSubview:_userSign];
        [self addSubview:_nickNameLabel];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self.faceImageView setFrame:CGRectMake(2*minSpace, minSpace, faceHeight, faceHeight)];
//    
//    [self.textLabel setFrame:CGRectMake(self.faceImageView.frame.size.width+self.faceImageView.frame.origin.x+2*minSpace, minSpace, 160, 20)];
    
    [self.faceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(2*minSpace);
        make.top.mas_equalTo(self.mas_top).offset(minSpace);
        make.size.mas_equalTo(CGSizeMake(faceHeight, faceHeight));
    }];
    
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.faceImageView.mas_right).offset(minSpace);
        make.top.mas_equalTo(self.faceImageView.mas_top).offset(minSpace);
        make.size.mas_equalTo(CGSizeMake(160, 20));
    }];
    
    [self.userSign mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nickNameLabel.mas_left);
        make.top.mas_equalTo(self.nickNameLabel.mas_bottom).offset(minSpace);
        make.size.mas_equalTo(CGSizeMake(220, 15));
    }];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
