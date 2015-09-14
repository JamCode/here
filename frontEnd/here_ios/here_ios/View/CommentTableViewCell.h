//
//  CommentTableViewCell.h
//  CarSocial
//
//  Created by wang jam on 12/22/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"

@interface CommentTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier commentElement:(CommentModel*)commentElement content_user_id:(NSString*)content_user_id nav:(UINavigationController*)nav;

+ (CGFloat)getCellHeight:(NSString*)commentStr;

@end
