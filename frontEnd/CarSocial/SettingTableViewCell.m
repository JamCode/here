//
//  SettingTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 9/16/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.detailTextLabel setFrame:CGRectMake(80, 0, 200, 20)];
        self.detailTextLabel.numberOfLines = 0;
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
    
    //self.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
}

@end
