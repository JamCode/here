//
//  MyImageView.h
//  CarSocial
//
//  Created by wang jam on 8/6/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyImageView : UIImageView


@property BOOL loadingFlag;
@property NSURL* imageURL;

- (void)loadingImageFromURL:(NSString*)urlStr;
- (void)reloading;

@end
