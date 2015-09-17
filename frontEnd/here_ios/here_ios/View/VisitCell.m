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
#import "visitView.h"
#import "VisitModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Tools.h"

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
            VisitView* visitView = [[VisitView alloc] init];
            
            visitView.faceView = [[FaceView alloc] initWithFrame:CGRectMake(i*(imageWidth+spaceWidth)+spaceWidth, spaceWidth, imageWidth, imageWidth)];
            visitView.faceView.layer.masksToBounds = YES;
            visitView.faceView.layer.cornerRadius = imageWidth/2;
            visitView.faceView.contentMode = UIViewContentModeScaleAspectFill;
            
            visitView.nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(visitView.faceView.frame.origin.x, visitView.faceView.frame.origin.y+visitView.faceView.frame.size.height+5, imageWidth+20, visitView.faceView.frame.size.height/3)];
            visitView.nickNameLabel.center = CGPointMake(visitView.faceView.center.x, visitView.nickNameLabel.center.y);
            visitView.nickNameLabel.font = [UIFont fontWithName:@"Arial" size:16];
            
            visitView.visitTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(visitView.faceView.frame.origin.x, visitView.nickNameLabel.frame.origin.y+visitView.nickNameLabel.frame.size.height+5, imageWidth, visitView.faceView.frame.size.height/3)];
            visitView.visitTimeLabel.center = CGPointMake(visitView.faceView.center.x, visitView.visitTimeLabel.center.y);
            visitView.visitTimeLabel.textColor = [UIColor grayColor];
            visitView.visitTimeLabel.font = [UIFont fontWithName:@"Arial" size:15];
            
            
            [self addSubview:visitView.faceView];
            [self addSubview:visitView.nickNameLabel];
            [self addSubview:visitView.visitTimeLabel];
            
            [visitViewArray addObject:visitView];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModels:(NSMutableArray*)visitModels{
    for (int i=0; i<[visitModels count]&&i<[visitViewArray count]; ++i) {
        VisitModel* model = [visitModels objectAtIndex:i];
        VisitView* visitView = [visitViewArray objectAtIndex:i];
        [visitView.faceView sd_setImageWithURL:[[NSURL alloc] initWithString:model.thumbnailStr]];
        UserInfoModel* userInfo = [[UserInfoModel alloc] init];
        userInfo.userID = model.userID;
        [visitView.faceView setUserInfo:userInfo nav:nil];
        visitView.nickNameLabel.text = model.nickName;
        visitView.nickNameLabel.textAlignment = NSTextAlignmentCenter;
        
        visitView.visitTimeLabel.text = [Tools showTime:model.visitTimeStamp];
        visitView.visitTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
}

+(CGFloat)cellHeight{
    return ScreenHeight/4;
}

@end
