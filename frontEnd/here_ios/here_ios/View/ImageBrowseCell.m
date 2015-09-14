//
//  ImageBrowseCell.m
//  CarSocial
//
//  Created by wang jam on 9/8/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "ImageBrowseCell.h"
#import "macro.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ImageEnlarge.h"
#import "Tools.h"

@implementation ImageBrowseCell
{
    
    NSMutableArray* imageViewArray;
}

static int spaceWidth = 5;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageViewArray = [[NSMutableArray alloc] init];
        int imageWidth = (ScreenWidth-4*spaceWidth)/3;
        
        for (int i=0; i<3; ++i) {
            ImageEnlarge* imageView = [[ImageEnlarge alloc] initWithParentView:[Tools appRootViewController].view];
            imageView.frame = CGRectMake(i*(imageWidth+spaceWidth)+spaceWidth, spaceWidth, imageWidth, imageWidth);
            [self addSubview:imageView];
            [imageViewArray addObject:imageView];
        }
    }
    return self;
}

+ (CGFloat)cellHeight
{
    return ScreenWidth/3;
}

- (void)setModels:(NSMutableArray*)imageModels
{
    for (int i=0; i<[imageViewArray count]; ++i) {
        ImageEnlarge* imageView = [imageViewArray objectAtIndex:i];
        imageView.image = nil;
        if (i<[imageModels count]) {
            ImageModel* imageModel = [imageModels objectAtIndex:i];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView setThumbnailUrl:imageModel.imageThumbnailStr];
            [imageView setImageUrl:imageModel.imageUrlStr];
        }
    }
}


@end
