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
#import "ContentDetailViewController.h"
#import "NetWork.h"
#import "CommentModel.h"
#import "ImageEnlarge.h"
#import "ContentModel.h"
#import "ContentDetailViewController.h"
#import "InputToolbar.h"
#import <Masonry.h>


@implementation ContentTableViewCell
{
    NSMutableArray* imageArray;
    
    UIImageView* enlargeImageview;
    MyImageView* originalImageView;
    UIScrollView* backgroundView;
    
    ContentModel* myContentModel;
    UIToolbar* bottomToolbar;
    UITextView* commentInputView;
    UIImageView* reportButton;
    
    
    UIActionSheet* sheet;
    MBProgressHUD* loading;
    
    CommentModel* commentModel;
    
    InputToolbar* inputToolBar;
    
    
    UIImageView* contentImageView;
    
    
    UIView* buttonsView;
    UIView* contentView;
    
    
    UIButton* goodbutton;
    UIButton* commentButton;
    UIButton* transferButton;
    UIButton* morebutton;
    
    
    
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


static const int buttonsView_height = 54;
static const int buttons_height = 34;


- (ContentModel*)getMyContentModel
{
    return myContentModel;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        contentImageView = [[UIImageView alloc] init];
        buttonsView = [[UIView alloc] init];
        contentView = [[UIView alloc] init];
        
        goodbutton = [[UIButton alloc] init];
        [goodbutton addTarget:self action:@selector(clickGoodButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        commentButton = [[UIButton alloc] init];
        [commentButton addTarget:self action:@selector(clickCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        
        transferButton = [[UIButton alloc] init];
        [transferButton addTarget:self action:@selector(clickTransferButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        morebutton = [[UIButton alloc] init];
        [morebutton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [buttonsView addSubview:goodbutton];
        [buttonsView addSubview:commentButton];
        [buttonsView addSubview:transferButton];
        [buttonsView addSubview:morebutton];

        
        [self addSubview:contentImageView];
        [self addSubview:buttonsView];
        [self addSubview:contentView];
    }
    return self;
}


- (void)clickMoreButton:(id)sender
{
    NSLog(@"clickMoreButton");
}

- (void)clickTransferButton:(id)sender
{
    NSLog(@"clickTransferButton");
}

- (void)clickCommentButton:(id)sender
{
    NSLog(@"clickCommentButton");
}

- (void)clickGoodButton:(id)sender
{
    
    LocDatabase* loc = [AppDelegate getLocDatabase];
    
    NSLog(@"clickGoodButton");
    if (myContentModel.goodFlag == true) {
        myContentModel.goodFlag = false;
        [goodbutton setBackgroundImage:[UIImage imageNamed:@"good.png"] forState:UIControlStateNormal];
        [loc deleteContentGoodInfo:myContentModel.contentID];
        [self cancelGood:nil];
        
    }else{
        myContentModel.goodFlag = true;
        [goodbutton setBackgroundImage:[UIImage imageNamed:@"good_after.png"] forState:UIControlStateNormal];
        [loc insertContentGoodInfo:myContentModel.contentID];
        [self sendGood:nil];

    }
}


- (void)awakeFromNib {
    // Initialization code
    
    NSLog(@"initial cell");
}

+ (CGFloat)getTotalHeight:(ContentModel*)model maxContentHeight:(NSInteger)maxHeight
{
    return ScreenWidth+buttonsView_height+44;
}


- (void)layoutSubviews
{
    [contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenWidth));
    }];
    
    contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    contentImageView.clipsToBounds = YES;
    
    
    [buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(contentImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, buttonsView_height));
    }];
    
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0.0f, buttonsView_height - 0.3f, ScreenWidth, 0.3f);
    border.backgroundColor = [UIColor lightGrayColor].CGColor;
    [buttonsView.layer addSublayer:border];
    
    
    //good button
    [goodbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(buttonsView.mas_left).offset(10);
        make.top.mas_equalTo(buttonsView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(buttons_height, buttons_height));
    }];
    
    
    //comment button
    [commentButton setBackgroundImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
    [commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(goodbutton.mas_right).offset(10);
        make.top.mas_equalTo(goodbutton.mas_top);
        make.size.mas_equalTo(CGSizeMake(buttons_height, buttons_height));
    }];
    
    //transfer button
    [transferButton setBackgroundImage:[UIImage imageNamed:@"transfer.png"] forState:UIControlStateNormal];
    [transferButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(commentButton.mas_right).offset(10);
        make.top.mas_equalTo(commentButton.mas_top);
        make.size.mas_equalTo(CGSizeMake(buttons_height, buttons_height));
    }];
    
    //more button
    [morebutton setBackgroundImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    [morebutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(buttonsView.mas_right).offset(-10);
        make.top.mas_equalTo(commentButton.mas_top);
        make.size.mas_equalTo(CGSizeMake(buttons_height, buttons_height));
    }];
    
}


- (void)setContentModel:(ContentModel*)model
{
    myContentModel = model;
    ImageModel* imageModel = model.imageModelArray[0];
    
//    [contentImageView sd_setImageWithURL:[[NSURL alloc] initWithString:imageModel.imageUrlStr]];
    
    
    //contentImageView.image = [UIImage imageNamed:@"IMG_3461.JPG"];
    
    
    
    
    [contentImageView sd_setImageWithURL:[[NSURL alloc] initWithString:imageModel.imageUrlStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [Tools scaleToSize:image size:CGSizeMake(ScreenWidth, ScreenWidth*image.size.height/image.size.width) imageView:contentImageView];
    }];
    
    if(model.goodFlag == true){
        [goodbutton setBackgroundImage:[UIImage imageNamed:@"good_after.png"] forState:UIControlStateNormal];
    }else{
        [goodbutton setBackgroundImage:[UIImage imageNamed:@"good.png"] forState:UIControlStateNormal];
    }
    
}


- (void)reportContentSuccess:(id)sender
{
    [Tools AlertBigMsg:@"举报成功"];
}

- (void)sendReportMsg
{
    UIView* rootView = [Tools appRootViewController].view;
    loading = [[MBProgressHUD alloc] initWithView:rootView];
    [rootView addSubview:loading];
    [loading show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myContentModel.contentID, @"/reportContent"] forKeys:@[@"content_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(reportContentSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loading hide:YES];
        [loading removeFromSuperview];
        loading = nil;
    } callObject:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //举报
        [self sendReportMsg];
    }
}

- (void)reportButtonPress:(id)sender
{
    NSLog(@"reportButtonPress");
    [sheet showInView:[Tools appRootViewController].view];
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
    if (inputToolBar!=nil) {
        [inputToolBar hideInput];
        [inputToolBar removeFromSuperview];
        inputToolBar = nil;
    }
}

//- (void)hidenButtons
//{
//    if (funView!=nil) {
//        [funView hidenButtons];
//    }
//}


- (void)initCommentInputView
{
    
    inputToolBar = [[InputToolbar alloc] init];
    inputToolBar.inputDelegate = self;
    
    [[Tools curNavigator].view addSubview:inputToolBar];
    
    [inputToolBar showInput];
}


- (void)sendAction:(NSString *)msg
{
    NSLog(@"%@", msg);
    [inputToolBar hideInput];
    [inputToolBar removeFromSuperview];
    inputToolBar = nil;
    [self sendComment:msg];
}




- (void)sendComment:(id)sender
{
    NSString* msg = (NSString*)sender;
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    commentModel = [[CommentModel alloc] init];
    UserInfoModel* myUserInfo = [AppDelegate getMyUserInfo];
    
    commentModel.sendUserInfo = myUserInfo;
    ContentModel* contentModel = myContentModel;
    commentModel.contentModel = contentModel;
    commentModel.counterUserInfo = contentModel.userInfo;
    commentModel.commentStr = msg;
    commentInputView.text = @"";
    commentModel.publish_time = [[NSDate date] timeIntervalSince1970];
    
    
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
    
    if (_contentDetail!=nil) {
        [_contentDetail addNewCommentCell:commentModel];
    }
    
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
    }
    
    if (index == 0) {
        //赞
        
        if (myContentModel.goodFlag == false) {
            [self sendGood:nil];
        }
    }
    
}

- (void)cancelGood:(id)sender
{
    
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myContentModel.contentID, @"/cancelGood"] forKeys:@[@"content_id", @"childpath"]];
    
    
    [netWork message:message images:nil feedbackcall:nil complete:^{
        
    } callObject:self];

}

- (void)sendGood:(id)sender
{
    
    
    UserInfoModel* myUserInfo = [AppDelegate getMyUserInfo];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myContentModel.contentID, myUserInfo.userID,  myContentModel.userInfo.userID, @"/addGoodCount"] forKeys:@[@"content_id", @"user_id", @"content_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(sendGoodSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        
    } callObject:self];
    
}

+ (ContentTableViewCell*)generateCell:(UITableView*)tableView cellId:(NSString*)cellId contentList:(NSMutableArray*)contentList indexPath:(NSIndexPath*)indexPath
{
    ContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell==nil) {
        cell = [[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        NSLog(@"new cell");
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.tableView = tableView;
    
    ContentModel* contentmodel = [contentList objectAtIndex:indexPath.row];
    [cell setContentModel:contentmodel];
    return cell;
    
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
//    [self increaseGoodCount];
//    if (_tableView!=nil) {
//        [_tableView reloadData];
//    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
