//
//  VisitCell.m
//  here_ios
//
//  Created by wang jam on 9/15/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "VisitCell.h"
#import "Constant.h"
#import "macro.h"

@implementation VisitCell
{
    NSMutableArray* faceImageViewArray;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModels:(NSMutableArray*)visitModels{
    
}

-(CGFloat)cellHeight{
    return ScreenHeight/4;
}

@end
