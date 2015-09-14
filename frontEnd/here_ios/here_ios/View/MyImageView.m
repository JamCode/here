//
//  MyImageView.m
//  CarSocial
//
//  Created by wang jam on 8/6/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "MyImageView.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation MyImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)loadingImageFromURL:(NSString*)urlStr
{
    [self sd_setImageWithURL:[[NSURL alloc] initWithString:urlStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _imageURL = imageURL;
        _loadingFlag = true;
        if (error) {
            _loadingFlag = false;
            self.image = [UIImage imageNamed:@"loading.png"];
        }
    }];
}


- (void)reloading
{
    if (_loadingFlag == false&&_imageURL!=nil) {
        [self loadingImageFromURL:[_imageURL absoluteString]];
    }
}

@end
