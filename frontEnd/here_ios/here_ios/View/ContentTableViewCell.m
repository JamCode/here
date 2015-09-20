//
//  ContentTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 7/22/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "ContentTableViewCell.h"
#import "macro.h"
#import "Constant.h"
#import "Tools.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ImageModel.h"
#import "AppDelegate.h"
#import "OptionFunView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ImageModel.h"
#import "ContentViewController.h"
#import "ContentDetailViewController.h"
#import "NetWork.h"
#import "CommentModel.h"
#import "ImageEnlarge.h"

static const int inputfontSize = 16;
static const double textViewHeight = 36;
static const double bottomToolbarHeight = 48;


@implementation ContentTableViewCell
{
    NSMutableArray* imageArray;
    UIImageView* genderImage;
    OptionFunView *funView;
    
    UIImageView* enlargeImageview;
    MyImageView* originalImageView;
    UIScrollView* backgroundView;
    
    ContentModel* myContentModel;
    UIToolbar* bottomToolbar;
    UITextView* commentInputView;
    
    
}

static const int faceImageWidth = 48;
static const int nickNameWidth = 44;
static const int nickNameHeight = 22;
static const int addressLabelHeight = 18;
static const int contentDetailInfoHeight = 18;
static const int timeHeight = 18;
static const int nameFontSize = 18;
static const int timeFontSize = 12;
static const int contentFontSize = 16;
static const int spaceValue = 10;
static const int minSpaceValue = 5;
static const int contentImageHeight = 76;
static const int maxImageHeight = 140;


static const int ageAndGenderHeight = 16;
static const int ageAndGenderWidth = 30;

static const int genderImageHeight = 10;

static const int ageHeight = 16;
static const int ageWidth = 18;






- (ContentModel*)getMyContentModel
{
    return myContentModel;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _faceView = [[FaceView alloc] initWithFrame:CGRectMake(spaceValue, 2*spaceValue, faceImageWidth, faceImageWidth)];
        _faceView.contentMode = UIViewContentModeScaleAspectFill;
        _faceView.clipsToBounds = YES;
        
        
        _nickName = [[UILabel alloc] initWithFrame:CGRectMake(_faceView.frame.origin.x+_faceView.frame.size.width+spaceValue, _faceView.frame.origin.y, nickNameWidth, nickNameHeight)];
        _nickName.font = [UIFont fontWithName:@"Arial" size:nameFontSize];
        
        //_cutoffLine = [[UIView alloc] initWithFrame:CGRectMake(_nickName.frame.origin.x, _faceView.frame.origin.y+_faceView.frame.size.height, ScreenWidth - _nickName.frame.origin.x, 1)];
        //_cutoffLine.backgroundColor = sepeartelineColor;
        
        [self initGenderAgeView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nickName.frame.origin.x, _nickName.frame.origin.y, 0, timeHeight)];
        _timeLabel.font = [UIFont fontWithName:@"Arial" size:timeFontSize];
        _timeLabel.textColor = [UIColor lightGrayColor];
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nickName.frame.origin.x, _nickName.frame.origin.y+_nickName.frame.size.height+spaceValue, ScreenWidth - _nickName.frame.origin.x - 3*spaceValue, 0)];
        _contentLabel.font = [UIFont fontWithName:@"Arial" size:contentFontSize];
        _contentLabel.textColor = [UIColor darkGrayColor];
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nickName.frame.origin.x, 0, _contentLabel.frame.size.width, addressLabelHeight)];
        _addressLabel.font = [UIFont fontWithName:@"Arial" size:timeFontSize];
        _addressLabel.textColor = subjectColor;
        
        
//        _contentDetailInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_contentLabel.frame.origin.x, 0, 180, contentDetailInfoHeight)];
//        _contentDetailInfoLabel.font = [UIFont fontWithName:@"Arial" size:timeFontSize];
//        _contentDetailInfoLabel.textColor = [UIColor lightGrayColor];
        
        
        _goodCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_contentLabel.frame.origin.x, 0, 0, contentDetailInfoHeight)];
        _goodCountLabel.font = [UIFont fontWithName:@"Arial" size:timeFontSize];
        _goodCountLabel.textColor = [UIColor lightGrayColor];
        
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.font = [UIFont fontWithName:@"Arial" size:timeFontSize];
        _commentCountLabel.textColor = [UIColor lightGrayColor];
        
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.font = [UIFont fontWithName:@"Arial" size:timeFontSize];
        _distanceLabel.textColor = [UIColor lightGrayColor];
        
        
        
        
        
        //_commentButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OptionFunView_icon@2x.png"]];
        
        //[self addSubview:_commentButton];
        [self addSubview:_faceView];
        [self addSubview:_nickName];
        
        //[self addSubview:_cutoffLine];
        [self addSubview:_timeLabel];
        [self addSubview:_contentLabel];
        //[self addSubview:_addressLabel];
        
        [self addSubview:_goodCountLabel];
        [self addSubview:_commentCountLabel];
        [self addSubview:_distanceLabel];

        //[self addSubview:_contentDetailInfoLabel];
        
        imageArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hidenButtons) name:@"commentButtonHide" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hidenKeyboard) name:@"commentKeyboardHide" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
    }
    return self;
}


- (void)keyboardWillShow:(NSNotification*)notification
{
    if (![commentInputView isFirstResponder]) {
        return;
    }
    
    commentInputView.text = @"";
    
    NSLog(@"keyboardWillShow");
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    //CGFloat keyboardHeight = keyboardBounds.size.height;
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [[Tools curNavigator].view convertRect:keyboardBounds toView:nil];
    
    CGRect bottomFrame = bottomToolbar.frame;
    
    
    bottomFrame.origin.y =  ScreenHeight - keyboardBounds.size.height - bottomToolbarHeight;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    bottomToolbar.frame = bottomFrame;
    bottomToolbar.hidden = NO;
    // commit animations
    [UIView commitAnimations];
    
    
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [[Tools curNavigator].view convertRect:keyboardBounds toView:nil];
    //keyboardHeight = 0;
    
    //CGRect btnFrame = talkTableView.frame;
    CGRect bottomFrame = bottomToolbar.frame;
    //btnFrame.origin.y = 0;
    bottomFrame.origin.y = ScreenHeight;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    bottomToolbar.frame = bottomFrame;
    bottomToolbar.hidden = YES;
    
    // commit animations
    [UIView commitAnimations];
}



- (void)awakeFromNib {
    // Initialization code
    
    NSLog(@"initial cell");
}

- (void)initGenderAgeView{
    
    _ageAndGenderView = [[UIView alloc] initWithFrame:CGRectMake(_nickName.frame.origin.x+10+_nickName.frame.size.width, _nickName.frame.origin.y, ageAndGenderWidth, ageAndGenderHeight)];
    
    
    _ageAndGenderView.layer.cornerRadius = 4.0;
    //ageAndGenderView.layer.masksToBounds = YES;
    
    genderImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 4, genderImageHeight, genderImageHeight)];
    
    genderImage.contentMode = UIViewContentModeScaleAspectFill;
    genderImage.center = CGPointMake(genderImage.center.x, ageAndGenderHeight/2.0);
    
    
    [_ageAndGenderView addSubview:genderImage];
    
    _ageAndGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(genderImage.frame.origin.x+genderImage.frame.size.width, 2, ageWidth, ageHeight)];
    
    _ageAndGenderLabel.center = CGPointMake(_ageAndGenderLabel.center.x, ageAndGenderHeight/2.0);
    
    _ageAndGenderLabel.textAlignment = NSTextAlignmentCenter;
    _ageAndGenderLabel.font = [UIFont fontWithName:@"Arial" size:10];
    _ageAndGenderLabel.textColor = [UIColor whiteColor];
    [_ageAndGenderView addSubview: _ageAndGenderLabel];
    
    [self addSubview: _ageAndGenderView];
}


+ (CGFloat)getTotalHeight:(ContentModel*)model maxContentHeight:(NSInteger)maxHeight
{
    float imageViewHeight = 0;
    if (model.imageModelArray!=nil&&[model.imageModelArray count]>1) {
        imageViewHeight = contentImageHeight;
    }
    
    if (model.imageModelArray!=nil&&[model.imageModelArray count]==1) {
        imageViewHeight = maxImageHeight;
    }
    
    CGSize contentSize;
    if (model.contentStr == nil||[model.contentStr isEqualToString:@""]) {
        contentSize = CGSizeMake(0, 0);
    }else{
        contentSize = [Tools getTextArrange:model.contentStr maxRect:CGSizeMake(ScreenWidth - faceImageWidth - 2*spaceValue - spaceValue, ScreenWidth) fontSize:contentFontSize];
    }
    
    
    //return 300;
    CGFloat cellHeight = 0;
    
    
    cellHeight =  2*spaceValue+nickNameHeight+spaceValue+contentSize.height+spaceValue+imageViewHeight+spaceValue+ contentDetailInfoHeight+2*spaceValue;
    
    if (model.contentStr == nil||[model.contentStr isEqualToString:@""]) {
        cellHeight -= spaceValue;
    }
    
    if (imageViewHeight == 0) {
        cellHeight -= spaceValue;
    }
    
    
    NSLog(@"%f", cellHeight);
    return cellHeight;
}

- (void)setContentModel:(ContentModel*)model
{
    myContentModel = model;
    [_faceView setUserInfo:model.userInfo nav:nil];
    //[self addSubview:_faceView];
    NSLog(@"%f,%f,%f,%f", _faceView.frame.origin.x, _faceView.frame.origin.y, _faceView.frame.size.width, _faceView.frame.size.height);
    
    
    if (model.anonymous == 1) {
        _faceView.image = [UIImage imageNamed:@"man-noname.png"];
        [_faceView forbiddenPress];
        _nickName.text = @"匿名用户";
        CGSize nameSize = [Tools getTextArrange:_nickName.text maxRect:CGSizeMake(250, _nickName.frame.size.height) fontSize:nameFontSize];
        _nickName.frame = CGRectMake(_nickName.frame.origin.x, _nickName.frame.origin.y, nameSize.width+minSpaceValue,  _nickName.frame.size.height);
        
        _ageAndGenderView.hidden = YES;
        //_ageAndGenderView.frame = CGRectMake(0, 0, 0, 0);
        
    }else{
        
        if (model.userInfo.faceImageThumbnailURLStr!=nil) {
            [_faceView sd_setImageWithURL:[[NSURL alloc] initWithString:model.userInfo.faceImageThumbnailURLStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
        }
        
        _nickName.text = model.userInfo.nickName;
        
        CGSize nameSize = [Tools getTextArrange:_nickName.text maxRect:CGSizeMake(250, _nickName.frame.size.height) fontSize:nameFontSize];
        _nickName.frame = CGRectMake(_nickName.frame.origin.x, _nickName.frame.origin.y, nameSize.width+minSpaceValue,  _nickName.frame.size.height);
        
        _ageAndGenderView.hidden = false;
        _ageAndGenderView.frame = CGRectMake(_nickName.frame.origin.x+_nickName.frame.size.width+minSpaceValue, _nickName.frame.origin.y, _ageAndGenderView.frame.size.width, _ageAndGenderView.frame.size.height);
        
        _ageAndGenderView.center = CGPointMake(_ageAndGenderView.center.x, _nickName.center.y);
        
        if (model.userInfo.gender==0) {
            genderImage.image = [UIImage imageNamed:@"woman32white.png"];
            _ageAndGenderView.backgroundColor = genderPink;
        }else{
            genderImage.image = [UIImage imageNamed:@"man32white.png"];
            _ageAndGenderView.backgroundColor = subjectColor;
        }
        
        
        
        _ageAndGenderLabel.text = [[NSString alloc] initWithFormat:@"%ld", model.userInfo.age];
    }
    
    
    
    
    _timeLabel.text = [Tools showTime:model.publishTimeStamp];
    CGSize timeSize = [Tools getTextArrange:_timeLabel.text maxRect:CGSizeMake(180, timeHeight) fontSize:nameFontSize];
    _timeLabel.frame = CGRectMake(ScreenWidth - 20 - timeSize.width, _timeLabel.frame.origin.y, timeSize.width, timeSize.height);
    
    
    _contentLabel.text = model.contentStr;
    CGSize contentSize = [Tools getTextArrange:_contentLabel.text maxRect:CGSizeMake(_contentLabel.frame.size.width, 180) fontSize:contentFontSize];
    _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x, _contentLabel.frame.origin.y, _contentLabel.frame.size.width, contentSize.height);
    _contentLabel.numberOfLines = 0;
    
    for (UIView* view in self.subviews) {
        if (view.tag == 11||view.tag == 111) {
            [view removeFromSuperview];
        }
    }
    
    [imageArray removeAllObjects];
    
    //int contentImageWidth = (ScreenWidth - _nickName.frame.origin.x - 10)/3;
    int contentImageWidth = maxImageHeight;
    
    if ([model.imageModelArray count]>1) {
        contentImageWidth = contentImageHeight;
    }
    
    
    for (int i=0; i<[model.imageModelArray count]; ++i) {
        ImageModel* imageModel = [model.imageModelArray objectAtIndex:i];
        ImageEnlarge* imageView = [[ImageEnlarge alloc] initWithParentView:[Tools appRootViewController].view];
        
        if (_contentLabel.text!=nil&&![_contentLabel.text isEqual:@""]) {
            imageView.frame = CGRectMake(_nickName.frame.origin.x+i*(contentImageWidth+minSpaceValue), _contentLabel.frame.origin.y+_contentLabel.frame.size.height+spaceValue, contentImageWidth, contentImageWidth);
        }else{
            imageView.frame = CGRectMake(_nickName.frame.origin.x+i*(contentImageWidth+minSpaceValue), _contentLabel.frame.origin.y, contentImageWidth, contentImageWidth);
        }
        
        imageView.tag = 11;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [imageView setThumbnailUrl:imageModel.imageThumbnailStr];
        [imageView setImageUrl:imageModel.imageUrlStr];
        [self addSubview:imageView];
        [imageArray addObject:imageView];
        
    }

    
    
    
    
    //_addressLabel.text = model.address;
    
    [self showContentDetailInfo:model];
    
    if ([model.imageModelArray count]>0) {
        UIImageView* imageView = [imageArray objectAtIndex:0];
        
        
        _goodCountLabel.frame = CGRectMake(_goodCountLabel.frame.origin.x, imageView.frame.origin.y+imageView.frame.size.height+spaceValue, _goodCountLabel.frame.size.width, _goodCountLabel.frame.size.height);
        
    }else{
        _goodCountLabel.frame = CGRectMake(_goodCountLabel.frame.origin.x, _contentLabel.frame.origin.y+_contentLabel.frame.size.height+spaceValue, _goodCountLabel.frame.size.width, _goodCountLabel.frame.size.height);
        
    }
    
    if (model.commentFlag == true) {
        _commentCountLabel.textColor = subjectColor;
    }else{
        _commentCountLabel.textColor = [UIColor lightGrayColor];
    }
    
    if (model.goodFlag == true) {
        _goodCountLabel.textColor = subjectColor;
    }else{
        _goodCountLabel.textColor = [UIColor lightGrayColor];
    }
    
    
    
    _commentCountLabel.frame = CGRectMake(_goodCountLabel.frame.origin.x+_goodCountLabel.frame.size.width+minSpaceValue, _goodCountLabel.frame.origin.y , _commentCountLabel.frame.size.width, _commentCountLabel.frame.size.height);
    
    
    _distanceLabel.frame = CGRectMake(_commentCountLabel.frame.origin.x+_commentCountLabel.frame.size.width+minSpaceValue, _goodCountLabel.frame.origin.y , _distanceLabel.frame.size.width, _distanceLabel.frame.size.height);

    
    
    
    
    //_commentButton.frame = CGRectMake(ScreenWidth - 22- 20, _contentDetailInfoLabel.frame.origin.y, 22, 15);
    
    
    funView = [[OptionFunView alloc] initWithFrame:CGRectMake(ScreenWidth - 150 - 20, _goodCountLabel.frame.origin.y, 150, 34)];
    funView.center = CGPointMake(funView.center.x, _goodCountLabel.center.y);
    
    funView.tag = 11;
    funView.funTitles = @[@"赞", @"评论"];
    //self.funtitles = funView.funTitles;
    
    funView.delegate = self;
    
    [self addSubview:funView];
    
    
    _timeLabel.center = CGPointMake(funView.frame.origin.x+funView.frame.size.width, _timeLabel.center.y);
    
    
    
    
    NSLog(@"%f, %f, %f, %f", funView.frame.origin.x, funView.frame.origin.y, funView.frame.size.width, funView.frame.size.height);
    
    
    
}

- (void)showContentDetailInfo:(ContentModel*)model
{
    CLLocation* userLocation = [[CLLocation alloc] initWithLatitude:model.latitude longitude:model.longitude];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CLLocation* myLocation = [[CLLocation alloc] initWithLatitude:app.myInfo.latitude longitude:app.myInfo.longitude];
    
    [Tools showDistance:userLocation otherLocation:myLocation];
    
    _goodCountLabel.text = [[NSString alloc] initWithFormat:@"%ld赞", model.goodCount];
    [Tools resizeLabel:_goodCountLabel maxHeight:contentDetailInfoHeight maxWidth:100 fontSize:timeFontSize];
    
    _commentCountLabel.text = [[NSString alloc] initWithFormat:@"%ld评论", model.commentCount];
    [Tools resizeLabel:_commentCountLabel maxHeight:contentDetailInfoHeight maxWidth:100 fontSize:timeFontSize];
    
    _distanceLabel.text = [[NSString alloc] initWithFormat:@"%@", [Tools showDistance:userLocation otherLocation:myLocation]];
    [Tools resizeLabel:_distanceLabel maxHeight:contentDetailInfoHeight maxWidth:100 fontSize:timeFontSize];
    
}


- (void)increaseCommentCount
{
    _commentCountLabel.text = [[NSString alloc] initWithFormat:@"%ld评论", ++myContentModel.commentCount];
    _commentCountLabel.textColor = subjectColor;
    myContentModel.commentFlag = true;
    
}

- (void)increaseGoodCount
{
    _goodCountLabel.text = [[NSString alloc] initWithFormat:@"%ld赞", ++myContentModel.goodCount];
    _goodCountLabel.textColor = subjectColor;
    myContentModel.goodFlag = true;
}

- (void)hidenKeyboard
{
    if (commentInputView!=nil) {
        [commentInputView resignFirstResponder];
        [bottomToolbar removeFromSuperview];
        bottomToolbar = nil;
    }
}

- (void)hidenButtons
{
    if (funView!=nil) {
        [funView hidenButtons];
    }
}


- (void)initCommentInputView
{
    [bottomToolbar removeFromSuperview];
    
    bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight+bottomToolbarHeight, ScreenWidth, bottomToolbarHeight)];
    [bottomToolbar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [bottomToolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    bottomToolbar.backgroundColor = activeViewControllerbackgroundColor;
    
    
    commentInputView = [[UITextView alloc] init];
    commentInputView.delegate =self;
    commentInputView.frame = CGRectMake(0, 0, ScreenWidth - 2*40, textViewHeight);
    commentInputView.returnKeyType = UIReturnKeyDone;//设置返回按钮的样式
    
    
    commentInputView.keyboardType = UIKeyboardTypeDefault;//设置键盘样式为默认
    commentInputView.font = [UIFont fontWithName:@"Arial" size:inputfontSize];
    commentInputView.scrollEnabled = YES;
    commentInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    commentInputView.layer.cornerRadius = 4.0;
    commentInputView.layer.borderWidth = 0.5;
    commentInputView.layer.borderColor = sepeartelineColor.CGColor;
    
    
    UIBarButtonItem* textfieldButtonItem =[[UIBarButtonItem alloc] initWithCustomView:commentInputView];
    
    UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendComment:)];
    
    NSArray *textfieldArray=[[NSArray alloc]initWithObjects:textfieldButtonItem, sendButton, nil];
    [bottomToolbar setItems:textfieldArray animated:YES];
    
    bottomToolbar.hidden = YES;
    
    [[Tools curNavigator].view addSubview:bottomToolbar];
    
    [commentInputView becomeFirstResponder];
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == commentInputView) {
        if ([text isEqualToString:@"\n"]) {
            
            [textView resignFirstResponder];
            
            [self sendComment:nil];
            
            return NO;
            
        }
        return YES;
    }
    return YES;
}

- (void)sendComment:(id)sender
{
    if ([commentInputView.text isEqual:@""]||commentInputView.text == nil) {
        return;
    }
    
    NSLog(@"%@", commentInputView.text);
    
    [commentInputView resignFirstResponder];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    CommentModel* commentModel = [[CommentModel alloc] init];
    UserInfoModel* myUserInfo = [AppDelegate getMyUserInfo];
    
    commentModel.sendUserInfo = myUserInfo;
    ContentModel* contentModel = myContentModel;
    commentModel.contentModel = contentModel;
    commentModel.counterUserInfo = contentModel.userInfo;
    commentModel.commentStr = commentInputView.text;
    commentInputView.text = @"";
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[commentModel.contentModel.contentID, commentModel.sendUserInfo.userID, commentModel.counterUserInfo.userID, commentModel.commentStr, commentModel.sendUserInfo.nickName, @"/addCommentToContent"] forKeys:@[@"content_id", @"user_id", @"to_user_id", @"comment", @"user_name", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addCommentSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        
    } callObject:self];
    
}


- (void)addCommentError:(id)sender
{
    [Tools AlertMsg:@"addCommentError"];
}

- (void)addCommentException:(id)sender
{
    [Tools AlertMsg:@"addCommentException"];
}

- (void)addCommentSuccess:(id)sender
{
    [self increaseCommentCount];
    if (_tableView!=nil) {
        [_tableView reloadData];
    }
}


- (void)OptionFunView:(OptionFunView *)OptionFunView didSelectButtonAtIndex:(NSUInteger)index
{
    
    NSLog(@"您点击了============%ld", index);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
    
    if (index == 1) {
        
        //评论
        [self initCommentInputView];
        
//        if ([self.contentViewCtrl isKindOfClass:[ContentViewController class]]) {
//            [(ContentViewController*)self.contentViewCtrl showCommentInputView:self];
//        }
//        
//        if([self.contentViewCtrl isKindOfClass:[ContentDetailViewController class]]){
//            [(ContentDetailViewController*)self.contentViewCtrl showCommentInputView];
//        }
        
    }
    
    if (index == 0) {
        //赞
        
        if (myContentModel.goodFlag == false) {
            [self sendGood:nil];
        }
    }
    
}

- (void)sendGood:(id)sender
{
    
    
    UserInfoModel* myUserInfo = [AppDelegate getMyUserInfo];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myContentModel.contentID, myUserInfo.userID,  myContentModel.userInfo.userID, @"/addGoodCount"] forKeys:@[@"content_id", @"user_id", @"content_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(sendGoodSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(sendGoodError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(sendGoodException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        
    } callObject:self];
    
}


- (void)sendGoodError:(id)sender
{
    [Tools AlertMsg:@"网络错误"];
}

- (void)sendGoodException:(id)sender
{
    [Tools AlertMsg:@"未知异常"];
}

- (void)sendGoodSuccess:(id)sender
{
    [self increaseGoodCount];
    if (_tableView!=nil) {
        [_tableView reloadData];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end