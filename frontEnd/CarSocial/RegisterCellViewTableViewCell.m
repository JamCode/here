//
//  RegisterCellViewTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 9/2/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "RegisterCellViewTableViewCell.h"

@implementation RegisterCellViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    
    [self.imageView setFrame:CGRectMake(10, 5, 32, 32)];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
