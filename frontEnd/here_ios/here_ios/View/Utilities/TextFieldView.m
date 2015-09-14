//
//  TextFieldView.m
//  momo
//
//  Created by wang jam on 1/16/14.
//  Copyright (c) 2014 wang jam. All rights reserved.
//

#import "TextFieldView.h"

@implementation TextFieldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.autocorrectionType = NO;
        self.autocapitalizationType = NO;
    }
    return self;
}



- (CGRect)textRectForBounds:(CGRect)bounds
{
    int leftMargin = 15;
    CGRect inset = CGRectMake(bounds.origin.x+leftMargin, bounds.origin.y
                              , bounds.size.width-leftMargin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    int leftMargin = 15;
    CGRect inset = CGRectMake(bounds.origin.x+leftMargin, bounds.origin.y
                              , bounds.size.width-leftMargin, bounds.size.height);
    return inset;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
