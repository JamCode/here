//
//  ActiveView.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "ActiveView.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "ActiveDetailViewController.h"


@implementation ActiveView
{
    UIImageView* faceImageView;
    
    UIView* bottomView;
    UIView* contentView;
    
    UILabel* userNameLabel;
    UILabel* usersignLabel;
    
    UILabel* activeTypeAndPersonCount;
    
    UIImageView* carIcon;
    UIImageView* genderImage;
    UILabel* ageAndGenderLabel;
    UIView* ageAndGenderView;

    UILabel* endPositionLabel;
    UILabel* activeDescLabel;
    UILabel* startDateLabel;
    
    
    
    UILabel* watchCountLabel;
    UIImageView* watchCountIcon;
    
    UILabel* registerCountLabel;
    UIImageView* registerCountIcon;
    
    UILabel* commentCountLabel;
    UIImageView* commentCountIcon;
    
    
    UIView* firstSeperateLine;
    
    UIImageView* activeTypeIcon;
    UIImageView* dateIcon;
    UIImageView* locationIcon;
    UIImageView* descIcon;
    
    UILabel* distanceLabel;
    UIView* backgroundView;
    BOOL enlargeImage;
    UIImageView* enlargeFaceView;
    
    ActiveModel* myActiveModel;
}


const int fontSize = 16;

static const int faceImageHeight = 68;
static const int faceImageWidth = 68;

const int activeTitleViewHeight = 0;

const int userNameLabelHeight = 20;
const int userSignLabelHeight = 16;


const int carIconHeight = 22;
const int carIconWidth = 22;

const int bottomViewHeight = 35;

const int contentLabelHeight = 20;

const int ageAndGenderHeight = 20;
const int ageAndGenderWidth = 36;

const int genderImageHeight = 12;
const int ageHeight = 18;
const int ageWidth = 18;



const int watchCountIconHeight = 18;

const int locationHeight = 18;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 4.0;
        //self.layer.masksToBounds = YES;
        
        //设置阴影
        //CALayer* layer = [self layer];
        [self layer].shadowPath =[UIBezierPath bezierPathWithRect:self.bounds].CGPath;

        [[self layer] setShadowOffset:CGSizeMake(0, 3)];
        [[self layer] setShadowRadius:4.0];
        [[self layer] setShadowOpacity:1];
        [[self layer] setShadowColor:layerColor.CGColor];
        [self setClipsToBounds:NO];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, self.frame.size.height - bottomView.frame.size.height)];
        contentView.userInteractionEnabled = YES;
        [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewPress:)]];
        
        
        NSLog(@"%f", frame.size.height);
        
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-bottomViewHeight, frame.size.width, bottomViewHeight)];
        
        
        
        //[self addSubview:activeTitleView];
        [self addSubview:bottomView];
        [self addSubview:contentView];
        
        
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.3;
        self.layer.borderColor = sepeartelineColor.CGColor;
        enlargeImage = false;
        backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        backgroundView.backgroundColor = [UIColor blackColor];
        
        backgroundView.userInteractionEnabled = YES;
        [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewPress:)]];
        
    }
    return self;
}


- (void)contentViewPress:(id)sender
{
    ActiveDetailViewController* activeDetailView = [[ActiveDetailViewController alloc] init];
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    activeDetailView.activeView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    activeDetailView.activeMode = myActiveModel;
    activeDetailView.hidesBottomBarWhenPushed = YES;

    [_parentViewController.navigationController pushViewController:activeDetailView animated:YES];
    NSLog(@"contentViewPress");
}

- (void)backgroundViewPress:(id)sender
{
    // animations settings
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.3 animations:^{
        enlargeFaceView.frame = [Tools relativeFrameForScreenWithView:faceImageView];
        [backgroundView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [enlargeFaceView removeFromSuperview];
        [backgroundView removeFromSuperview];
    }];
    
}

- (void)drawAgeAndGenderView:(ActiveModel*) activeModel
{
    ageAndGenderView = [[UIView alloc] initWithFrame:CGRectMake(userNameLabel.frame.origin.x, usersignLabel.frame.origin.y+usersignLabel.frame.size.height+6, ageAndGenderWidth, ageAndGenderHeight)];
    ageAndGenderView.layer.cornerRadius = 4.0;
    //ageAndGenderView.layer.masksToBounds = YES;
    
    genderImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 4, genderImageHeight, genderImageHeight)];
    
    genderImage.contentMode = UIViewContentModeScaleAspectFill;
    //genderImage.clipsToBounds  = YES;
    
    //activeModel.userInfo.gender = 0;
    
    if (activeModel.userInfo.gender==0) {
        genderImage.image = [UIImage imageNamed:@"womanwhite32px.png"];
        ageAndGenderView.backgroundColor = genderPink;
    }else{
        genderImage.image = [UIImage imageNamed:@"manwhite32px.png"];
        ageAndGenderView.backgroundColor = subjectColor;
    }
    [ageAndGenderView addSubview:genderImage];
    
    ageAndGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(genderImage.frame.origin.x+10, 2, ageWidth, ageHeight)];
    

    ageAndGenderLabel.text = @"25";
    ageAndGenderLabel.textAlignment = NSTextAlignmentCenter;
    ageAndGenderLabel.font = [UIFont fontWithName:@"Arial" size:12];
    ageAndGenderLabel.textColor = [UIColor whiteColor];
    [ageAndGenderView addSubview: ageAndGenderLabel];
    
    [contentView addSubview:ageAndGenderView];

}

//- (void)drawActiveTitle:(ActiveModel*)activeModel
//{
//    activeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, activeTitleView.frame.size.width-10, activeTitleView.frame.size.height)];
//    
//    activeTitleLabel.text = activeModel.activeTitle;
//    activeTitleLabel.font = [UIFont fontWithName:@"Arial" size:18];
//    activeTitleLabel.textColor = subjectColor;
//    [activeTitleView addSubview:activeTitleLabel];
//}


- (void)faceImageViewPress:(id)sender
{
    NSLog(@"faceImageViewPress");
    
    if(enlargeFaceView == nil){
        enlargeFaceView = [[UIImageView alloc] initWithImage:faceImageView.image];
    }
    
    
    enlargeFaceView.frame = [Tools relativeFrameForScreenWithView:faceImageView];
    
    //enlargeFaceView.frame = faceImageView.frame;
    [backgroundView addSubview:enlargeFaceView];
    [backgroundView setAlpha:0.0];
    [_parentViewController.view addSubview:backgroundView];
    
    // animations settings
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.3 animations:^{
        [backgroundView setAlpha:1.0];
        enlargeFaceView.frame = CGRectMake(0, ScreenHeight/2 - ScreenWidth/2, ScreenWidth, ScreenWidth);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)drawFaceImage:(ActiveModel*)activeModel
{
    faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, faceImageWidth, faceImageHeight)];
    [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:activeModel.userInfo.faceImageURLStr]];
    
    faceImageView.contentMode =  UIViewContentModeScaleAspectFill;
    faceImageView.clipsToBounds  = YES;
    faceImageView.layer.cornerRadius = 6.0;
    //faceImageView.layer.masksToBounds = YES;
    
    faceImageView.userInteractionEnabled = YES;
    [faceImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceImageViewPress:)]];

    
    [contentView addSubview:faceImageView];
}


- (void)drawUserInfo:(ActiveModel*)activeModel
{
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+10+faceImageView.frame.size.width, faceImageView.frame.origin.y, 100, userNameLabelHeight)];
    userNameLabel.text = activeModel.userInfo.nickName;
    [contentView addSubview:userNameLabel];
    
    usersignLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+10+faceImageView.frame.size.width, userNameLabel.frame.origin.y+userNameLabel.frame.size.height+5, 120, userSignLabelHeight)];
    usersignLabel.text = activeModel.userInfo.sign;
    usersignLabel.textColor = [UIColor grayColor];
    usersignLabel.font = [UIFont fontWithName:@"Arial" size:14];
    [contentView addSubview: usersignLabel];
}

- (void)drawCarBrandIcon:(ActiveModel*)activeModel
{
    if (activeModel.userInfo.isCertificated==TRUE) {
        NSLog(@"%f", genderImage.frame.origin.y);
        carIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ageAndGenderView.frame.origin.x+ageAndGenderView.frame.size.width+5, ageAndGenderView.frame.origin.y, carIconWidth, carIconHeight)];
        carIcon.contentMode = UIViewContentModeScaleAspectFill;
        carIcon.clipsToBounds  = YES;
        carIcon.image = activeModel.userInfo.carInfoModel.carBrandImage;
        [contentView addSubview: carIcon];
    }
}

- (void)drawActiveTypePersonCount:(ActiveModel*) activeModel
{
    activeTypeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, firstSeperateLine.frame.origin.y+15, locationHeight, locationHeight)];
    activeTypeIcon.image = [UIImage imageNamed:@"star.png"];
    activeTypeIcon.contentMode = UIViewContentModeScaleAspectFill;
    [contentView addSubview:activeTypeIcon];
    
    activeTypeAndPersonCount = [[UILabel alloc] initWithFrame:CGRectMake(activeTypeIcon.frame.origin.x+activeTypeIcon.frame.size.width+15, activeTypeIcon.frame.origin.y, 160, 16)];
    activeTypeAndPersonCount.text = [[NSString alloc] initWithFormat:@"%@(%@)", activeModel.activeType, activeModel.personCount];
    [contentView addSubview: activeTypeAndPersonCount];
}

- (void)drawActiveDate:(ActiveModel*) activeModel
{
    dateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, activeTypeIcon.frame.origin.y+activeTypeIcon.frame.size.height+15, locationHeight, locationHeight)];
    dateIcon.image = [UIImage imageNamed:@"date.png"];
    dateIcon.contentMode = UIViewContentModeScaleAspectFill;
    [contentView addSubview:dateIcon];
    
    startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateIcon.frame.origin.x+dateIcon.frame.size.width+15, dateIcon.frame.origin.y, 200, 16)];
    
    startDateLabel.text = activeModel.startDate;
    [contentView addSubview: startDateLabel];
}

- (void)drawLocation:(ActiveModel*) activeModel
{
    locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, dateIcon.frame.origin.y+dateIcon.frame.size.height+15, locationHeight, locationHeight)];
    locationIcon.image = [UIImage imageNamed:@"location.png"];
    locationIcon.contentMode = UIViewContentModeScaleAspectFill;
    [contentView addSubview:locationIcon];
    
    endPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(locationIcon.frame.origin.x+dateIcon.frame.size.width+15, locationIcon.frame.origin.y, 200, 16)];
    endPositionLabel.text = activeModel.endPosition;
    [contentView addSubview: endPositionLabel];
}

- (void)drawActiveDesc:(ActiveModel*) activeModel
{
    descIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, locationIcon.frame.origin.y+locationIcon.frame.size.height+15, locationHeight, locationHeight)];
    descIcon.image = [UIImage imageNamed:@"description.png"];
    descIcon.contentMode = UIViewContentModeScaleAspectFill;
    [contentView addSubview:descIcon];
    
    
    activeDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(descIcon.frame.origin.x+dateIcon.frame.size.width+15, descIcon.frame.origin.y, 200, 16)];
    activeDescLabel.text = activeModel.activeDesc;
    [contentView addSubview: activeDescLabel];
}

- (void)drawWatchRegisterComment:(ActiveModel*)activeModel
{
    //查看人数
    watchCountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, watchCountIconHeight, watchCountIconHeight)];
    watchCountIcon.image = [UIImage imageNamed:@"watch.png"];
    [bottomView addSubview:watchCountIcon];
    
    watchCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(watchCountIcon.frame.origin.x+watchCountIcon.frame.size.width+5, watchCountIcon.frame.origin.y, 40, watchCountIconHeight)];
    watchCountLabel.text = [[NSString alloc] initWithFormat:@"%d", activeModel.watchCount];
    watchCountLabel.font = [UIFont fontWithName:@"Arial" size:14];
    watchCountLabel.textColor = [UIColor grayColor];
    [bottomView addSubview:watchCountLabel];
    
    //竖分割线

    
    //报名人数
    registerCountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(140, watchCountIcon.frame.origin.y, watchCountIconHeight, watchCountIconHeight)];
    registerCountIcon.image = [UIImage imageNamed:@"registerCountIcon.png"];
    [bottomView addSubview:registerCountIcon];
    
    registerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(registerCountIcon.frame.origin.x+registerCountIcon.frame.size.width+5, watchCountIcon.frame.origin.y, 40, watchCountIconHeight)];
    registerCountLabel.text = @"1234";
    registerCountLabel.font = [UIFont fontWithName:@"Arial" size:14];
    registerCountLabel.textColor = [UIColor grayColor];
    [bottomView addSubview:registerCountLabel];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(registerCountLabel.frame.origin.x+watchCountLabel.frame.size.width+5, watchCountLabel.frame.origin.y, 0.3, watchCountLabel.frame.size.height)];
    line.backgroundColor = [UIColor grayColor];
    [bottomView addSubview:line];
    
    //评论数
    commentCountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(line.frame.origin.x+20, watchCountIcon.frame.origin.y, watchCountIconHeight, watchCountIconHeight)];
    commentCountIcon.image = [UIImage imageNamed:@"commentCount.png"];
    [bottomView addSubview:commentCountIcon];
    
    
    commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentCountIcon.frame.origin.x+registerCountIcon.frame.size.width+5, watchCountIcon.frame.origin.y, 40, watchCountIconHeight)];
    commentCountLabel.text = @"1234";
    commentCountLabel.font = [UIFont fontWithName:@"Arial" size:14];
    commentCountLabel.textColor = [UIColor grayColor];
    [bottomView addSubview:commentCountLabel];
    
}

- (void)drawRegister:(ActiveModel*)activeModel
{
    
}

- (void)drawCommentCount:(ActiveModel*)activeModel
{
    
}

- (void)drawDistance:(ActiveModel*)activeModel
{
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-2*10) - 44, faceImageView.frame.origin.y - 10, 44, 36)];
    
    if (activeModel.distanceMeters<100) {
        activeModel.distanceMeters = 100;
    }
    
    if (activeModel.distanceMeters<1000) {
        distanceLabel.text = [[NSString alloc] initWithFormat:@"%d00m", activeModel.distanceMeters/100];
    }else{
        distanceLabel.text = [[NSString alloc] initWithFormat:@"%dkm", activeModel.distanceMeters/1000];
    }
    
    distanceLabel.font = [UIFont fontWithName:@"Arial" size:14];
    distanceLabel.textColor = [UIColor grayColor];
    [contentView addSubview:distanceLabel];
}

- (void)setActiveModel:(ActiveModel*) activeModel
{
    myActiveModel = activeModel;
    //头像
    [self drawFaceImage:activeModel];
    //昵称和签名
    [self drawUserInfo:activeModel];
    //性别和年龄
    [self drawAgeAndGenderView:activeModel];
    //车标
    [self drawCarBrandIcon:activeModel];
    
    //分割线
    firstSeperateLine = [[UIView alloc]initWithFrame:CGRectMake(10, faceImageView.frame.origin.y+faceImageView.frame.size.height+10, self.frame.size.width-20, 0.3)];
    firstSeperateLine.backgroundColor = sepeartelineColor;
    [contentView addSubview:firstSeperateLine];
    
    //旅行类别和人数
    [self drawActiveTypePersonCount:activeModel];
    
    //日期
    [self drawActiveDate:activeModel];
    
    //地点
    [self drawLocation:activeModel];
    
    //描述
    [self drawActiveDesc:activeModel];
    
    //分割线
    firstSeperateLine = [[UIView alloc]initWithFrame:CGRectMake(10, descIcon.frame.origin.y+descIcon.frame.size.height+10, self.frame.size.width-20, 0.3)];
    firstSeperateLine.backgroundColor = sepeartelineColor;
    [contentView addSubview:firstSeperateLine];
    
    
    
    //查看次数,参与人数,评论数
    [self drawWatchRegisterComment:activeModel];
    
    
    [self drawDistance:activeModel];
    
    
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
