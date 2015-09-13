//
//  CarSelectTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 8/17/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "CarSelectTableViewCell.h"

@implementation CarSelectTableViewCell


const int carBrandImageWeight = 34;
const int carBrandimageHeight = 34;

const int carDescWeight = 90;
const int carDescHeight = carBrandimageHeight*1/2;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.carBrandIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, carBrandImageWeight, carBrandimageHeight)];
        self.carBrandIcon.contentMode =  UIViewContentModeScaleAspectFit;
        self.carBrandIcon.clipsToBounds  = YES;
        
        
        
        [self addSubview:self.carBrandIcon];
        
        self.carBrandDesc = [[UILabel alloc] initWithFrame:CGRectMake(self.carBrandIcon.frame.origin.x+self.carBrandIcon.frame.size.width+20, 15, carDescWeight, carDescHeight)];
        self.carBrandDesc.font = [UIFont fontWithName:@"Arial" size:17];
        [self addSubview:self.carBrandDesc];
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, carBrandimageHeight+10)];
        
        
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

@end
