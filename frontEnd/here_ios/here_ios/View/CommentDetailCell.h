//
//  CommentDetailCell.h
//  CarSocial
//
//  Created by wang jam on 3/26/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"
#import "Tools.h"
#import "GoodModel.h"

@interface CommentDetailCell : UITableViewCell
- (CommentDetailCell*)initWithStyle:(UITableViewCellStyle)cellStyle reuseIdentifier:(NSString*)reuseIdentifier;

+ (CGFloat)getUnreadCommentCellHeight;

- (void)setUnreadCommentModel:(CommentModel*)commentModel;
- (void)setUnreadGoodModel:(GoodModel*)goodModel;


@end
