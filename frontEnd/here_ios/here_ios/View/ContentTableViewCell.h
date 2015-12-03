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
#import "InputToolbar.h"

@class ContentViewController;
@class ContentDetailViewController;

@interface ContentTableViewCell : UITableViewCell<OptionFunViewDelegate, UIScrollViewDelegate, UITextViewDelegate, UIActionSheetDelegate, InputToolbarDelegate>


@property UILabel* contentLabel;
@property UILabel* addressLabel;
//@property UILabel* contentDetailInfoLabel;//赞数，评论数
@property UILabel* goodCountLabel;
@property UILabel* commentCountLabel;
@property UILabel* distanceLabel;



+ (CGFloat)getTotalHeight:(ContentModel*)model maxContentHeight:(NSInteger)maxHeight;
- (void)setContentModel:(ContentModel*)model;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (ContentModel*)getMyContentModel;

- (void)increaseCommentCount;
- (void)increaseGoodCount;
- (void)showKeyboard;

+ (ContentTableViewCell*)generateCell:(UITableView*)tableView cellId:(NSString*)cellId contentList:(NSMutableArray*)contentList indexPath:(NSIndexPath*)indexPath;

@property UITableView* tableView;
@property NSMutableArray *contentModeArray;



@property ContentDetailViewController* contentDetail;



@end
