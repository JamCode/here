//
//  ImageModel.h
//  CarSocial
//
//  Created by wang jam on 7/23/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageModel : NSObject

@property NSString* imageUrlStr;
@property NSString* imageThumbnailStr;
@property NSInteger timestamp;

- (void)setModels:(NSDictionary*)element;

@end
