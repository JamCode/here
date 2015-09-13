//
//  PriMsgTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 9/17/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "PriMsgTableViewCell.h"

@implementation PriMsgTableViewCell
{

}

static const int noticeLabelHeight = 20;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _lastTime = [[UILabel alloc] init];
        [self addSubview:_lastTime];
        _noticeCount = nil;
        _noticeCount = [[UILabel alloc] init];
        [self addSubview:_noticeCount];

    }
    return self;
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

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(10, 10, 45, 45)];
    [self.textLabel setFrame:CGRectMake(70, 10, 160, 20)];
    [self.detailTextLabel setFrame:CGRectMake(70, 10+20+10, 220, 15)];
    [_lastTime setFrame:CGRectMake(250, 10, 66, 22)];
    [_noticeCount setFrame:CGRectMake(self.imageView.frame.origin.x+self.imageView.frame.size.width - noticeLabelHeight/2, self.imageView.frame.origin.y - noticeLabelHeight/2, noticeLabelHeight, noticeLabelHeight)];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
}

@end
