//
//  ImageBrowseCell.h
//  CarSocial
//
//  Created by wang jam on 9/8/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageModel.h"

@interface ImageBrowseCell : UITableViewCell


+ (CGFloat)cellHeight;
- (void)setModels:(NSMutableArray*)imageModels;

@end
