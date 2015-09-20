////
////  ActiveView.m
////  CarSocial
////
////  Created by wang jam on 8/19/14.
////  Copyright (c) 2014 jam wang. All rights reserved.
////
//
//#import "ContentView.h"
//#import "Constant.h"
//#import "SDWebImage/UIImageView+WebCache.h"
//#import "AppDelegate.h"
//#import "Tools.h"
//#import "ContentDetailViewController.h"
//#import <MBProgressHUD.h>
//#import "NetWork.h"
//#import "macro.h"
//#import "ContentViewController.h"
//#import "FaceView.h"
//#import <AsyncDisplayKit/AsyncDisplayKit.h>
//
//
//@implementation ContentView
//{
//    FaceView* faceImageView;
//    
//    
//    UILabel* userNameLabel;
//    UILabel* usersignLabel;
//    
//    UILabel* activeTypeAndPersonCount;
//    
//    UIImageView* genderImage;
//    UILabel* ageAndGenderLabel;
//    UIView* ageAndGenderView;
//
//    UILabel* endPositionLabel;
//    UILabel* activeDescLabel;
//    UILabel* startDateLabel;
//    
//    
//    
//    UILabel* watchCountLabel;
//    
//    UILabel* registerCountLabel;
//    
//    UILabel* commentCountLabel;
//    
//    
//    UIView* firstSeperateLine;
//    
//    //UIImageView* locationIcon;
//    
//    UILabel* distanceLabel;
//    UIScrollView* backgroundView;
//    
//    ContentModel* myContentModel;
//    
//    //发布时间
//    UILabel* dateTimeLabel;
//    
//    //内容
//    UILabel* contentLabel;
//    
//    UIImageView* enlargeImageview;
//    
//    
//    BOOL goodFlag;
//    
//    UIButton* watchButton;
//    UIButton* goodButton;
//    UIButton* commentButton;
//    
//    UIImageView* contentImageview;
//    
//}
//
//
//const int fontSize = 18;
//
//static const int faceImageHeight = 46;
//static const int faceImageWidth = 46;
//static const int userNameLabelHeight = 20;
//
//static const int bottomViewHeight = 36;
//static const int headerViewHeight = faceImageHeight + 20;
//
////static const int ageAndGenderHeight = 20;
////static const int ageAndGenderWidth = 36;
//
//static const int genderImageHeight = 18;
////static const int ageHeight = 18;
////static const int ageWidth = 18;
//
//
//
//
//
//+ (CGFloat)getContentWidth:(NSString*)textStr
//{
//    if (textStr == nil||[textStr isEqualToString:@""]) {
//        return 0;
//    }
//    
//    CGSize boundSize = CGSizeMake(ScreenWidth - 20, 30);
//    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};
//    
//    
//    CGRect requireSize = [textStr boundingRectWithSize:boundSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
//    return requireSize.size.width;
//}
//
//
//+ (CGFloat)getContentHeight:(NSString*)textStr maxContentHeight:(float)maxContentHeight
//{
//    if (textStr == nil||[textStr isEqualToString:@""]) {
//        return 0;
//    }
//    
//    CGSize boundSize = CGSizeMake(ScreenWidth - 20, maxContentHeight);
//    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};
//    
//    
//    CGRect requireSize = [textStr boundingRectWithSize:boundSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
//    return requireSize.size.height;
//
//}
//
//
//+ (CGFloat)getTotalHeight:(ContentModel*)activeMode maxContentHeight:(float)maxContentHeight
//{
//    
//    NSString* imageUrlStr = activeMode.imageUrlStr;
//    
//    float imageViewHeight = 0;
//    if (imageUrlStr!=nil&&![imageUrlStr isEqualToString:@""]) {
//        imageViewHeight = ScreenWidth - 20;
//    }
//    
//    float addressHeight = 24;
////    if ([activeMode.address isEqual:@""]||activeMode.address == nil||(NSNull*)activeMode.address == [NSNull null]) {
////        addressHeight = 0;
////    }
//    
//    return [ContentView getContentHeight:activeMode.contentStr maxContentHeight:maxContentHeight]+bottomViewHeight+headerViewHeight+imageViewHeight+20+addressHeight;
//}
//
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//
//        
//        self.userInteractionEnabled = YES;
//        //[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewPress:)]];
//        
//        self.backgroundColor = [UIColor whiteColor];
//        self.layer.borderColor = sepeartelineColor.CGColor;
//        self.layer.borderWidth = 0;
//        goodFlag = false;
//    }
//    return self;
//}
//
//
//- (void)commentButtonPress:(id)sender
//{
////    if([_parentViewController isKindOfClass:[ContentViewController class]]){
////        if([(ContentViewController*)_parentViewController isScroll]){
////            return;
////        }
////    }
//    
//    if ([_parentViewController isKindOfClass:[ContentViewController class]]) {
//        ContentDetailViewController* contentDetailView = [[ContentDetailViewController alloc] init];
//        contentDetailView.parentContentViewCtrl = (ContentViewController*)_parentViewController;
//        
//        //NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
//        
//        //contentDetailView.contentView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
//        //contentDetailView.contentModel = myContentModel.contentID;
//        contentDetailView.contentID = myContentModel.contentID;
//        contentDetailView.hidesBottomBarWhenPushed = YES;
//        
//        [_parentViewController.navigationController pushViewController:contentDetailView animated:YES];
//        NSLog(@"contentViewPress");
//    }
//}
//
//
//- (void)drawDateTime:(ContentModel*) activeModel
//{
//    dateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(userNameLabel.frame.origin.x, userNameLabel.frame.origin.y+userNameLabel.frame.size.height+8, 180, 16)];
//    dateTimeLabel.font = [UIFont fontWithName:@"Arial" size:13];
//    dateTimeLabel.text = [Tools showTime:activeModel.publishTimeStamp];
//    dateTimeLabel.textColor = [UIColor grayColor];
//    [self addSubview:dateTimeLabel];
//    
//}
//
//- (void)drawAgeAndGenderView:(ContentModel*) activeModel
//{
//    
//    if (activeModel.anonymous == 1) {
//        return;
//    }
//    
//    NSLog(@"%f, %f", userNameLabel.frame.origin.x, userNameLabel.frame.origin.y);
//    
//    
//    
//    genderImage = [[UIImageView alloc] init];
//    genderImage.frame = CGRectMake(userNameLabel.frame.origin.x+[ContentView getContentWidth:activeModel.userInfo.nickName]+5, userNameLabel.frame.origin.y+2, genderImageHeight, genderImageHeight);
//    
//    genderImage.contentMode = UIViewContentModeScaleAspectFill;
//    
//    
//    if (activeModel.userInfo.gender==0) {
//        genderImage.image = [UIImage imageNamed:@"womanSetting.png"];
//    }else{
//        genderImage.image = [UIImage imageNamed:@"manSetting.png"];
//    }
//    [self addSubview:genderImage];
//}
//
//- (void)goodButtonPress:(UITapGestureRecognizer*)sender
//{
////    if([_parentViewController isKindOfClass:[ContentViewController class]]){
////        if([(ContentViewController*)_parentViewController isScroll]){
////            return;
////        }
////    }
//    
//        
//    if (goodFlag == false) {
//        goodFlag = true;
//        
//        //send good message to server
//        [self sendGoodMsg];
//        
//        myContentModel.goodCount++;
//        [goodButton setTitle:[[NSString alloc] initWithFormat:@"赞(%ld)", myContentModel.goodCount] forState:UIControlStateNormal];
//        
//    }
//}
//
//
//- (void)sendGoodMsg
//{
//    NetWork* netWork = [[NetWork alloc] init];
//    
//    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    
//    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myContentModel.contentID, app.myInfo.userID,  @"/addGoodCount"] forKeys:@[@"content_id", @"user_id", @"childpath"]];
//    
//    
//    [netWork message:message images:nil feedbackcall:nil complete:^{
//    } viewController:nil];
//    
//}
//
//
//- (void)drawFaceImage:(ContentModel*)contentModel
//{
//    
//    faceImageView = [[FaceView alloc] initWithFrame:CGRectMake(10, 10, faceImageWidth, faceImageHeight)];
//    faceImageView.contentMode =  UIViewContentModeScaleAspectFill;
//    [faceImageView  setUserInfo:contentModel.userInfo nav:_parentViewController.navigationController];
//    
//    
//    if (contentModel.anonymous == 1) {
//        faceImageView.image = [UIImage imageNamed:@"man-noname.png"];
//        [faceImageView forbiddenPress];
//    }else{
//        [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:contentModel.userInfo.faceImageURLStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            faceImageView.image = [Tools scaleToSize:image size:CGSizeMake(2*faceImageView.frame.size.width, 2*image.size.height*faceImageView.frame.size.width/image.size.width)];
//        }];
//    }
//    
//    [self addSubview:faceImageView];
//}
//
//
//- (void)drawUserInfo:(ContentModel*)contentModel
//{
//    
//    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+10+faceImageView.frame.size.width, faceImageView.frame.origin.y, 100, userNameLabelHeight)];
//    if (contentModel.anonymous == 1) {
//        userNameLabel.text = @"匿名用户";
//    }else{
//        userNameLabel.text = contentModel.userInfo.nickName;
//    }
//    userNameLabel.textColor = [UIColor grayColor];
//    [self addSubview:userNameLabel];
//}
//
//- (void)drawWatchRegisterComment:(ContentModel*)activeModel
//{
//    
//    firstSeperateLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - bottomViewHeight, ScreenWidth, 0.5)];
//    firstSeperateLine.backgroundColor = sepeartelineColor;
//    [self addSubview:firstSeperateLine];
//    
//    
//    watchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, firstSeperateLine.frame.origin.y+1, ScreenWidth/3, bottomViewHeight)];
//    [watchButton setTitle:[[NSString alloc] initWithFormat:@"查看(%ld)", (long)activeModel.watchCount] forState:UIControlStateNormal];
//    watchButton.tintColor = [UIColor grayColor];
//    watchButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:14];
//    [watchButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    //watchButton.showsTouchWhenHighlighted = YES;
//    [watchButton setEnabled:NO];
//    
//    [self addSubview:watchButton];
//    
//    firstSeperateLine = [[UIView alloc] initWithFrame:CGRectMake(watchButton.frame.origin.x+watchButton.frame.size.width+1, watchButton.frame.origin.y+3, 0.5, watchButton.frame.size.height-6)];
//    firstSeperateLine.backgroundColor = sepeartelineColor;
//    [self addSubview:firstSeperateLine];
//    
//    
//    goodButton = [[UIButton alloc] initWithFrame:CGRectMake(watchButton.frame.origin.x+watchButton.frame.size.width+1, watchButton.frame.origin.y+1, ScreenWidth/3, bottomViewHeight)];
//    [goodButton setTitle:[[NSString alloc] initWithFormat:@"赞(%ld)", activeModel.goodCount] forState:UIControlStateNormal];
//    goodButton.tintColor = [UIColor grayColor];
//    goodButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:14];
//    [goodButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    goodButton.showsTouchWhenHighlighted = YES;
//    [goodButton addTarget:self action:@selector(goodButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self addSubview:goodButton];
//    
//    
//    firstSeperateLine = [[UIView alloc] initWithFrame:CGRectMake(goodButton.frame.origin.x+goodButton.frame.size.width+1, watchButton.frame.origin.y+3, 0.5, watchButton.frame.size.height-6)];
//    firstSeperateLine.backgroundColor = sepeartelineColor;
//    [self addSubview:firstSeperateLine];
//    
//    commentButton = [[UIButton alloc] initWithFrame:CGRectMake(goodButton.frame.origin.x+goodButton.frame.size.width+1, watchButton.frame.origin.y+1, ScreenWidth/3, bottomViewHeight)];
//    [commentButton setTitle:[[NSString alloc] initWithFormat:@"评论(%ld)", activeModel.commentCount] forState:UIControlStateNormal];
//    commentButton.tintColor = [UIColor grayColor];
//    commentButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:14];
//    [commentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    commentButton.showsTouchWhenHighlighted = YES;
//    [commentButton addTarget:self action:@selector(commentButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:commentButton];
//    
//    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentButtonPress:)]];
//    
//}
//
//- (void)drawRegister:(ContentModel*)activeModel
//{
//    
//}
//
//- (void)drawCommentCount:(ContentModel*)activeModel
//{
//    
//}
//
//- (void)deleteContent
//{
//    
//}
//
////- (void)drawDistance:(ContentModel*)contentModel
////{
////
////    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-10) - 50, faceImageView.frame.origin.y - 10, 50, 32)];
////        
////    if (contentModel.distanceMeters<100) {
////        contentModel.distanceMeters = 100;
////    }
////        
////    if (contentModel.distanceMeters<1000) {
////        distanceLabel.text = [[NSString alloc] initWithFormat:@"%d00m", contentModel.distanceMeters/100];
////    }else{
////        distanceLabel.text = [[NSString alloc] initWithFormat:@"%dkm", contentModel.distanceMeters/1000];
////    }
////        
////    distanceLabel.font = [UIFont fontWithName:@"Arial" size:14];
////    distanceLabel.textColor = [UIColor grayColor];
////    [self addSubview:distanceLabel];
////        
////    locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(distanceLabel.frame.origin.x - 18, distanceLabel.frame.origin.y+6, locationHeight, locationHeight)];
////    locationIcon.image = [UIImage imageNamed:@"location.png"];
////    locationIcon.contentMode = UIViewContentModeScaleAspectFill;
////    [self addSubview:locationIcon];
////}
//
////- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
////{
////    NSLog(@"touchesBegan");
////}
////
////- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
////{
////    NSLog(@"touchesMoved");
////    
////}
////
////- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
////{
////    NSLog(@"touchesEnded");
////}
//
//
//
//- (void)drawAddress:(ContentModel*) contentModel
//{
//    if ([contentModel.address isEqual:@""]||contentModel.address == nil||(NSNull*)contentModel.address == [NSNull null]) {
//        contentModel.address = @"地球未知地";
//    }
//    
//    float address_y = 0;
//    if (contentModel.imageUrlStr!=nil&&![contentModel.imageUrlStr isEqual:@""]) {
//        address_y = contentImageview.frame.origin.y+contentImageview.frame.size.height+10;
//    }else{
//        address_y = contentLabel.frame.origin.y+contentLabel.frame.size.height+10;
//    }
//    
//    UIImageView* locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x, address_y, 10, 14.5)];
//    locationIcon.image = [UIImage imageNamed:@"manlocation1.png"];
//    //locationIcon.image = [Tools scaleToSize:locationIcon.image size:CGSizeMake(10, 14.5)];
//    
//    [self addSubview:locationIcon];
//    
//    UILabel* addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(locationIcon.frame.origin.x+locationIcon.frame.size.width+5, address_y, ScreenWidth - 20, 16)];
//    
//    addressLabel.textColor = subjectColor;
//    addressLabel.font = [UIFont fontWithName:@"Arial" size:14];
//    
//    if (contentModel.distanceMeters<100) {
//        contentModel.distanceMeters = 100;
//    }
//    
//    if (contentModel.distanceMeters<1000) {
//        addressLabel.text = [[NSString alloc] initWithFormat:@"%@,距离%@", contentModel.address, [[NSString alloc] initWithFormat:@"%d00m", contentModel.distanceMeters/100]];
//    }else{
//        addressLabel.text = [[NSString alloc] initWithFormat:@"%@,距离%@", contentModel.address, [[NSString alloc] initWithFormat:@"%dkm", contentModel.distanceMeters/1000]];
//    }
//    [self addSubview:addressLabel];
//}
//
//- (void)setContentModel:(ContentModel*) contentModel
//{
//    myContentModel = contentModel;
//    //头像
//    [self drawFaceImage:contentModel];
//    //昵称
//    [self drawUserInfo:contentModel];
//    
//    [self drawAgeAndGenderView:contentModel];
//    //日期
//    [self drawDateTime:contentModel];
//    //位置
//    //[self drawDistance:contentModel];
//    
//    //内容
//    [self drawContent:contentModel];
//    
//    [self drawImage:contentModel];
//    
//    //地理位置
//    [self drawAddress:contentModel];
//    
//    //查看次数,评论数
//    [self drawWatchRegisterComment:contentModel];
//}
//
//- (void)drawImage:(ContentModel*) contentModel
//{
//    NSString* imageUrlStr = contentModel.imageUrlStr;
//    if (imageUrlStr == nil||[imageUrlStr isEqualToString:@""]) {
//        return;
//    }
//    
//    float imageWidth = ScreenWidth - 20;
//    
//    float orign_y = 0;
//    if (![contentModel.contentStr isEqualToString:@""]) {
//        orign_y = contentLabel.frame.origin.y+contentLabel.frame.size.height+10;
//    }else{
//        orign_y = faceImageView.frame.origin.y+faceImageView.frame.size.height+10;
//    }
//    
//    contentImageview = [[UIImageView alloc] init];
//    contentImageview.frame = CGRectMake(faceImageView.frame.origin.x, orign_y, imageWidth, imageWidth);
//    
//    
//    [contentImageview sd_setImageWithURL:[[NSURL alloc] initWithString:imageUrlStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        contentImageview.image = image;
//    }];
//    
//    contentImageview.contentMode = UIViewContentModeScaleAspectFill;
//    contentImageview.clipsToBounds = YES;
//    contentImageview.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentImagePress:)];
//    
//    [contentImageview addGestureRecognizer:singleTab];
//    
//    [self addSubview:contentImageview];
//}
//
//
//- (void)contentImagePress:(UITapGestureRecognizer*)sender
//{
//    UIImageView* imageview = (UIImageView*)sender.view;
//    
//    NSLog(@"contentImagePress");
//    if (enlargeImageview == nil) {
//        enlargeImageview = [[UIImageView alloc] init];
//        enlargeImageview.image = imageview.image;
//    }
//    
//    enlargeImageview.frame = [Tools relativeFrameForScreenWithView:imageview];
//    enlargeImageview.contentMode = UIViewContentModeScaleAspectFit;
//    enlargeImageview.backgroundColor = [UIColor blackColor];
//    enlargeImageview.multipleTouchEnabled = YES;
//    
//    backgroundView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    backgroundView.backgroundColor = [UIColor blackColor];
//    backgroundView.userInteractionEnabled = YES;
//    
//    UITapGestureRecognizer* singleTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewPress:)];
//    [singleTab setNumberOfTapsRequired:1];
//    
//    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
//    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
//    [backgroundView addGestureRecognizer:doubleTapGestureRecognizer];
//    [backgroundView addGestureRecognizer:singleTab];
//    [singleTab requireGestureRecognizerToFail:doubleTapGestureRecognizer];
//    
//    
//    
//    backgroundView.delegate = self;
//    //设置最大伸缩比例
//    backgroundView.maximumZoomScale=1.8;
//    //设置最小伸缩比例
//    backgroundView.minimumZoomScale=0.8;
//    //backgroundView.contentSize = enlargeImageview.image.size;
//    
//    [backgroundView addSubview:enlargeImageview];
//    
//    [backgroundView setAlpha:0.0];
//    
//    [_parentViewController.tabBarController.view addSubview:backgroundView];
//    
//    
//    // animations settings
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView animateWithDuration:0.3 animations:^{
//        [backgroundView setAlpha:1];
//        
//        enlargeImageview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//        [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
//        
//
//        
//    } completion:^(BOOL finished) {
//        ;
//        //隐藏导航栏和tab栏
//        
//    }];
//    
//}
//
//- (void)zoomImage:(id)sender
//{
//    if(backgroundView.zoomScale == backgroundView.maximumZoomScale){
//        [backgroundView setZoomScale:1 animated:YES];
//    }else{
//        [backgroundView setZoomScale:backgroundView.maximumZoomScale animated:YES];
//    }
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
//{
//    if (enlargeImageview == view) {
//        if (view.frame.size.width < ScreenWidth) {
//            [scrollView setZoomScale:1.0 animated:YES];
//        }
//    }
//}
//
//
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    
//}
//
////告诉scrollview要缩放的是哪个子控件
//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return enlargeImageview;
//}
//
//- (void)backgroundViewPress:(id)sender
//{
////    _parentViewController.navigationController.navigationBarHidden = NO;
////    _parentViewController.tabBarController.tabBar.hidden = NO;
//    
//    // animations settings
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView animateWithDuration:0.3 animations:^{
//        enlargeImageview.frame = [Tools relativeFrameForScreenWithView:contentImageview];
//        [backgroundView setAlpha:0.0];
//        [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
//
//    } completion:^(BOOL finished) {
//        [enlargeImageview removeFromSuperview];
//        [backgroundView removeFromSuperview];
//        backgroundView = nil;
//        enlargeImageview = nil;
//    }];
//}
//
//
//- (void)drawContent:(ContentModel*) activeModel
//{
//    if ([activeModel.contentStr isEqualToString:@""]) {
//        return;
//    }
//    
//    float contentHeight = [ContentView getContentHeight:activeModel.contentStr maxContentHeight:ScreenHeight/2];
//    
//    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x, headerViewHeight, ScreenWidth - 20, contentHeight)];
//    
//    
//    contentLabel.font = [UIFont fontWithName:@"Arial" size:fontSize];
//    contentLabel.text = activeModel.contentStr;
//    
//    contentLabel.numberOfLines = 0;
//    [self addSubview:contentLabel];
//}
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}
//*/
//
//@end
