//
//  ImageEnlarge.h
//  ImageEnlarge
//
//  Created by wang jam on 9/9/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageEnlarge : UIImageView<UIScrollViewDelegate>


- (id)initWithParentView:(UIView*)parentView;
- (void)setThumbnailUrl:(NSString*)imageUrl;
- (void)setImageUrl:(NSString*)imageUrl;

@end
