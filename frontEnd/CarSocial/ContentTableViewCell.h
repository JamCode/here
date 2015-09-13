//
//  ContentTableViewCell.h
//  CarSocial
//
//  Created by wang jam on 7/22/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"
#import "ContentModel.h"
#import "OptionFunView.h"
#import "MyImageView.h"
@class ContentViewController;
@interface ContentTableViewCell : UITableViewCell<OptionFunViewDelegate, UIScrollViewDelegate, UITextViewDelegate>


@property FaceView* faceView;
@property UIView* cutoffLine;
@property UILabel* nickName;
@property UILabel* timeLabel;
@property UILabel* contentLabel;
@property UILabel* addressLabel;
//@property UILabel* contentDetailInfoLabel;//赞数，评论数
@property UILabel* goodCountLabel;
@property UILabel* commentCountLabel;
@property UILabel* distanceLabel;





@property UIView* ageAndGenderView;
@property UILabel* ageAndGenderLabel; 


+ (CGFloat)getTotalHeight:(ContentModel*)model maxContentHeight:(NSInteger)maxHeight;
- (void)setContentModel:(ContentModel*)model;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (ContentModel*)getMyContentModel;

- (void)increaseCommentCount;
- (void)increaseGoodCount;

@property UITableView* tableView;




@end
