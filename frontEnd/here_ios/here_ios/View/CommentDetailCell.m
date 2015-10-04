//
//  CommentDetailCell.m
//  CarSocial
//
//  Created by wang jam on 3/26/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "CommentDetailCell.h"
#import "FaceView.h"
#import "Constant.h"
#import "macro.h"
#import "CommentModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TimeFunction.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "GoodModel.h"
//more
//hehe

@implementation CommentDetailCell
{
    FaceView* counter_face;
    UILabel* counter_nick_name;
    UILabel* publish_time;
    UIButton* replyButton;
    UILabel* commentLabel;
    UILabel* preCommentLabel;
    
    UIView* tempView;
    UILabel* contentNickName;
    UIImageView* contentImage;
    UILabel* contentStr;
    NSMutableDictionary* imageDic;
}

static const int counter_face_height = 50;
static const int counter_nick_name_height = 24;
static const int publish_time_height = 8;
static const int commentLabel_height = 24;

static const int contentStr_height = 44;
static const int contentStr_width = 64;
static const int contentFontSize = 14;



static const int separate_height = 10;

- (CommentDetailCell*)initWithStyle:(UITableViewCellStyle)cellStyle reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.backgroundColor = sepeartelineColor;
        counter_face = [[FaceView alloc] initWithFrame:CGRectMake(separate_height, separate_height, counter_face_height, counter_face_height)];
        [self addSubview:counter_face];
        
        counter_nick_name = [[UILabel alloc] initWithFrame:CGRectMake(counter_face.frame.origin.x+counter_face.frame.size.width+separate_height, counter_face.frame.origin.y, 80, counter_nick_name_height)];
        [self addSubview:counter_nick_name];
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(counter_nick_name.frame.origin.x, counter_nick_name.frame.origin.y+ counter_nick_name.frame.size.height, ScreenWidth/3, commentLabel_height)];
        commentLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        commentLabel.font = [UIFont fontWithName:@"Arial" size:16];
        
        [self addSubview:commentLabel];
        
        
        
        publish_time = [[UILabel alloc] initWithFrame:CGRectMake(commentLabel.frame.origin.x, commentLabel.frame.origin.y+commentLabel.frame.size.height+separate_height, 80, publish_time_height)];
        [self addSubview:publish_time];
        
        contentStr = [[UILabel alloc] init];
        contentStr.font = [UIFont fontWithName:@"Arial" size:contentFontSize];
        contentStr.textColor = [UIColor grayColor];
        contentStr.numberOfLines = 0;
        contentStr.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        
        [self addSubview:contentStr];
        
        
        contentImage = [[UIImageView alloc] init];
        contentImage.contentMode = UIViewContentModeScaleAspectFill;
        contentImage.clipsToBounds = YES;
        [self addSubview:contentImage];
        
//        replyButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 74, counter_face.frame.origin.y, 64, replyButton_height)];
//        [self addSubview:replyButton];
        

        
//        tempView = [[UIView alloc] initWithFrame:CGRectMake(separate_height, commentLabel.frame.origin.y+commentLabel.frame.size.height+separate_height, ScreenWidth - 2*separate_height, contentStr_height)];
//        tempView.backgroundColor = activeViewControllerbackgroundColor;
//        [self addSubview:tempView];
    }
    return self;
}



- (void)setUnreadGoodModel:(GoodModel*)goodModel
{
    if (goodModel == nil) {
        return;
    }
    
    
    
    counter_face.contentMode = UIViewContentModeScaleAspectFill;
    counter_face.clipsToBounds = YES;
    counter_face.userInteractionEnabled = YES;
    [counter_face setUserInfo:goodModel.sendUserInfo nav:nil];
    
    [counter_face sd_setImageWithURL:[[NSURL alloc] initWithString:goodModel.sendUserInfo.faceImageThumbnailURLStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    counter_nick_name.text = goodModel.sendUserInfo.nickName;
    publish_time.text = [TimeFunction showTime:goodModel.publish_time];
    publish_time.font = [UIFont fontWithName:@"Arial" size:13];
    publish_time.textColor = [UIColor grayColor];
    
    commentLabel.text =  [[NSString alloc] initWithFormat:@"%@", goodModel.commentStr];
    
    
    
    
    if (goodModel.contentModel.imageUrlStr!=nil&&(NSNull*)goodModel.contentModel.imageUrlStr!=[NSNull null]) {
        int height = [CommentDetailCell getUnreadCommentCellHeight] - 2*separate_height;
        
        contentImage.frame = CGRectMake(ScreenWidth - height - separate_height, separate_height, height, height);
        [contentImage sd_setImageWithURL:[[NSURL alloc] initWithString:goodModel.contentModel.imageUrlStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
        
        contentStr.frame = CGRectMake(contentImage.frame.origin.x - contentStr_width - separate_height, counter_face.frame.origin.y, contentStr_width, contentStr_height);
        contentStr.text = goodModel.contentModel.contentStr;
        
        
    }else{
        
        contentStr.frame = CGRectMake(ScreenWidth - contentStr_width - separate_height, counter_face.frame.origin.y, contentStr_width, contentStr_height);
        contentStr.text = goodModel.contentModel.contentStr;
    }
    
}



- (void)setUnreadCommentModel:(CommentModel*)commentModel
{
    if (commentModel == nil) {
        return;
    }
    
    
    
    counter_face.contentMode = UIViewContentModeScaleAspectFill;
    counter_face.clipsToBounds = YES;
    counter_face.userInteractionEnabled = YES;
    [counter_face setUserInfo:commentModel.sendUserInfo nav:nil];
    
    [counter_face sd_setImageWithURL:[[NSURL alloc] initWithString:commentModel.sendUserInfo.faceImageThumbnailURLStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    counter_nick_name.text = commentModel.sendUserInfo.nickName;
    publish_time.text = [TimeFunction showTime:commentModel.publish_time];
    publish_time.font = [UIFont fontWithName:@"Arial" size:13];
    publish_time.textColor = [UIColor grayColor];
    
    commentLabel.text =  [[NSString alloc] initWithFormat:@"%@", commentModel.commentStr];
    
    
    
    
    if (commentModel.contentModel.imageUrlStr!=nil&&(NSNull*)commentModel.contentModel.imageUrlStr!=[NSNull null]) {
        int height = [CommentDetailCell getUnreadCommentCellHeight] - 2*separate_height;
        
        contentImage.frame = CGRectMake(ScreenWidth - height - separate_height, separate_height, height, height);
        [contentImage sd_setImageWithURL:[[NSURL alloc] initWithString:commentModel.contentModel.imageUrlStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
        
        contentStr.frame = CGRectMake(contentImage.frame.origin.x - contentStr_width - separate_height, counter_face.frame.origin.y, contentStr_width, contentStr_height);
        contentStr.text = commentModel.contentModel.contentStr;
        
        
    }else{
        
        contentStr.frame = CGRectMake(ScreenWidth - contentStr_width - separate_height, counter_face.frame.origin.y, contentStr_width, contentStr_height);
        contentStr.text = commentModel.contentModel.contentStr;
    }
    
}

+ (CGFloat)getUnreadCommentCellHeight
{
    return separate_height+counter_nick_name_height+commentLabel_height+separate_height+publish_time_height+separate_height;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
