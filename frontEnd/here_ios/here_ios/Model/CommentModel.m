//
//  CommentModel.m
//  CarSocial
//
//  Created by wang jam on 3/29/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel


- (id)init
{
    if (self = [super init]) {
        _counterUserInfo = [[UserInfoModel alloc] init];
        _sendUserInfo = [[UserInfoModel alloc] init];
        _contentModel = [[ContentModel alloc] init];
    }
    return self;
}


- (void)setCommentModel:(NSDictionary*)feedback
{
    
    _sendUserInfo.faceImageThumbnailURLStr = [feedback objectForKey:@"user_facethumbnail"];
    _sendUserInfo.nickName = [feedback objectForKey:@"user_name"];
    _sendUserInfo.userID = [feedback objectForKey:@"user_id"];

    _counterUserInfo.nickName = [feedback objectForKey:@"to_user_name"];
    _counterUserInfo.userID = [feedback objectForKey:@"comment_to_user_id"];
    
    
    
    
    _publish_time = [[feedback objectForKey:@"comment_timestamp"] integerValue];
    _commentStr = [feedback objectForKey:@"comment_content"];
    
    
    _contentModel.contentStr = [feedback objectForKey:@"content"];
    _contentModel.contentID = [feedback objectForKey:@"content_id"];
    _contentModel.imageUrlStr = [feedback objectForKey:@"content_image_url"];
    
    _content_comment_id = [feedback objectForKey:@"content_comment_id"];
    
    _good_count = [[feedback objectForKey:@"good_count"] integerValue];
    
    //_contentModel.userInfo.faceImageThumbnailURLStr = [feedback objectForKey:@""]
    
}


@end
