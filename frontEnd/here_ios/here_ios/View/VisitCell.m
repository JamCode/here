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
    NSMutableArray* visitViewArray;
}

static int spaceWidth = 10;


- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        visitViewArray = [[NSMutableArray alloc] init];
        int imageWidth = (ScreenWidth-5*spaceWidth)/4;
        
        for (int i=0; i<4; ++i) {
//            VisitView* visitView = [[VisitView alloc] init];
//            visitView.faceView = [[FaceView alloc] initWithFrame:CGRectMake(i*(imageWidth+spaceWidth)+spaceWidth, 0, imageWidth, imageWidth)];
//            
//            [self addSubview:visitView.faceView];
//            [visitViewArray addObject:visitView];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModels:(NSMutableArray*)visitModels{
    
}

+(CGFloat)cellHeight{
    return ScreenHeight/4;
}

@end
