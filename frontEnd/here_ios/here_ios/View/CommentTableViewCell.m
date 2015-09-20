//
//  CommentTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 12/22/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Tools.h"
#import "FaceView.h"
#import "CommentModel.h"


@implementation CommentTableViewCell
{
    FaceView* faceImageView;
    UILabel* namelabel;
    UILabel* commentLabel;
    UILabel* commentDateLabel;
}
static const int cellHeight = 64;
static const int faceViewWidth = 36;
static const int nameWidth = 100;
static const int fontSize = 16;
static const int faceImageView_x = 13;
static const int commentDateWidth = 70;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



+ (CGFloat)getCommentlabelHeight:(NSString*)commentStr
{
    CGSize boundSize = CGSizeMake(ScreenWidth - 20 - faceImageView_x - faceViewWidth, CGFLOAT_MAX);
    
    CGSize requireSize = [Tools getTextArrange:commentStr maxRect:boundSize fontSize:fontSize];
    
//    CGSize requireSize = [commentStr sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:boundSize lineBreakMode:UILineBreakModeWordWrap];
    return requireSize.height;
}

+ (CGFloat)getCellHeight:(NSString*)commentStr
{
    CGFloat realHeight = [CommentTableViewCell getCommentlabelHeight:commentStr] + 20 + faceViewWidth;
    
    if (realHeight > cellHeight) {
        return realHeight;
    }
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier commentElement:(CommentModel *)commentElement content_user_id:(NSString*)content_user_id nav:(UINavigationController*)nav
{
    
    if (nav == nil) {
        NSLog(@"nav is nil");
    }
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (commentElement == nil) {
        return self;
    }
    
    //init face image
    
    faceImageView = [[FaceView alloc] initWithFrame:CGRectMake(faceImageView_x, 10, faceViewWidth, faceViewWidth)];
    faceImageView.contentMode = UIViewContentModeScaleAspectFill;
    faceImageView.clipsToBounds = YES;
    
    [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:commentElement.sendUserInfo.faceImageThumbnailURLStr] placeholderImage:[UIImage imageNamed:@"loading.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    UserInfoModel* userinfo = commentElement.sendUserInfo;
    [faceImageView setUserInfo:userinfo nav:nav];
    faceImageView.primsgButtonShow = YES;
    [self addSubview:faceImageView];
    
    
    //init name
    namelabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+faceViewWidth+10, 0, nameWidth, 36)];
    namelabel.font = [UIFont fontWithName:@"Arial" size:fontSize];
    namelabel.text = userinfo.nickName;
    [self addSubview:namelabel];
    
    //init comment
    
    NSString* commentStr = nil;
    
    
    
    
    if (commentElement.contentModel.anonymous == 1
        &&[commentElement.counterUserInfo.userID isEqual:commentElement.contentModel.userInfo.userID]) {
        //匿名
        commentStr = [[NSString alloc] initWithFormat:@"回复 %@: %@", @"匿名作者", commentElement.commentStr];
    }else{
        commentStr = [[NSString alloc] initWithFormat:@"回复 %@: %@", commentElement.counterUserInfo.nickName,commentElement.commentStr];
    }
    
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [CommentTableViewCell getCellHeight:commentStr])];
    
    commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(namelabel.frame.origin.x, namelabel.frame.origin.y+namelabel.frame.size.height+5, ScreenWidth - 20 - faceImageView.frame.origin.x - faceImageView.frame.size.width, [CommentTableViewCell getCommentlabelHeight:commentStr])];
    
    commentLabel.numberOfLines = 0;
    
    commentLabel.font = [UIFont fontWithName:@"Arial" size:fontSize];
    commentLabel.text = commentStr;
    commentLabel.textColor = [UIColor grayColor];
    [self addSubview:commentLabel];
    
    
    //init comment date
    
    commentDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - commentDateWidth - 10, namelabel.frame.origin.y, commentDateWidth, namelabel.frame.size.height)];
    commentDateLabel.text = [Tools showTime:commentElement.publish_time];
    commentDateLabel.textColor = [UIColor grayColor];
    commentDateLabel.font = [UIFont fontWithName:@"Arial" size:14];
    [self addSubview:commentDateLabel];
    
    
    return self;
}

@end
