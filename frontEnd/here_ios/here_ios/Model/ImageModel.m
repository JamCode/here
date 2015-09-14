//
//  ImageModel.m
//  CarSocial
//
//  Created by wang jam on 7/23/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel


- (void)setModels:(NSDictionary*)element
{
    _imageThumbnailStr = [element objectForKey:@"image_compress_url"];
    _imageUrlStr = [element objectForKey:@"image_url"];
    _timestamp = [[element objectForKey:@"timestamp"] integerValue];
}

@end
