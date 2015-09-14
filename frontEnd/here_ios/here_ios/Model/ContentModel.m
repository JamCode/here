//
//  ActiveModel.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "ContentModel.h"
#import "UserInfoModel.h"
#import "Tools.h"
#import "ImageModel.h"
@implementation ContentModel

- (id)init
{
    if (self = [super init]) {
        _userInfo = [[UserInfoModel alloc] init];
        _to_content = 1;
        _canBeDeleted = false;
        _imageModelArray = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)setContentModel:(NSDictionary*)element
{
    _userInfo.nickName = [element objectForKey:@"user_name"];
    _userInfo.faceImageURLStr = [element objectForKey:@"user_face_image"];
    _userInfo.userID = [element objectForKey:@"user_id"];
    _userInfo.gender = [[element objectForKey:@"user_gender"] integerValue];
    _userInfo.age = [[element objectForKey:@"user_age"] integerValue];
    _userInfo.faceImageThumbnailURLStr = [element objectForKey:@"user_facethumbnail"];
    
    _contentID = [element objectForKey:@"content_id"];
    _latitude = [[element objectForKey: @"content_publish_latitude"] doubleValue];
    _longitude = [[element objectForKey: @"content_publish_longitude"] doubleValue];
    _publishTimeStamp = [[element objectForKey:@"content_publish_timestamp"] intValue];
    _watchCount = [[element objectForKey:@"content_see_count"] intValue];
    _goodCount = [[element objectForKey:@"content_good_count"] intValue];
    
    
    _commentCount = [[element objectForKey:@"content_comment_count"] intValue];
    _contentStr = [Tools getJsonObject:[element objectForKey:@"content"]];
    _imageUrlStr = [Tools getJsonObject:[element objectForKey:@"content_image_url"]];
    _anonymous = [[element objectForKey:@"anonymous"] intValue];
    
    _address = [element objectForKey:@"address"];
    _goodFlag = false;
    
    NSArray* contentImageUrlArray = [element objectForKey:@"content_image_url_array"];
    NSArray* contentImageCompressUrlArray = [element objectForKey:@"content_image_compress_url_array"];
    
    for (int i=0; i<[contentImageUrlArray count]; ++i) {
        ImageModel* imageModel = [[ImageModel alloc] init];
        imageModel.imageUrlStr = [contentImageUrlArray objectAtIndex:i];
        imageModel.imageThumbnailStr = [contentImageCompressUrlArray objectAtIndex:i];
        [_imageModelArray addObject:imageModel];
    }
}

@end
