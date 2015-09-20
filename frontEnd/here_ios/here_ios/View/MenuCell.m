//
//  MenuCell.m
//  CarSocial
//
//  Created by wang jam on 3/24/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "MenuCell.h"
#import "Constant.h"

static const int commentCountLabelHeight = 20;

@implementation MenuCell
{
    UILabel* commentCountLabel;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setNoticeCount:(NSInteger)noticeCount
{
    if (commentCountLabel !=nil) {
        [commentCountLabel removeFromSuperview];
    }
    
    if (noticeCount<=0) {
        return;
    }
    
    commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, self.textLabel.frame.origin.y+32-commentCountLabelHeight/2, commentCountLabelHeight, commentCountLabelHeight)];
    commentCountLabel.layer.cornerRadius = commentCountLabelHeight/2;
    commentCountLabel.layer.masksToBounds = YES;
    commentCountLabel.text = [[NSString alloc] initWithFormat:@"%ld", noticeCount];
    commentCountLabel.font = [UIFont fontWithName:@"Arial" size:14];
    commentCountLabel.textAlignment = NSTextAlignmentCenter;
    commentCountLabel.textColor = [UIColor whiteColor];
    commentCountLabel.backgroundColor = [UIColor redColor];
    [self addSubview:commentCountLabel];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, ScreenWidth/5+ScreenWidth/2, 64)];
}

@end
