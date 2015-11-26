//
//  GoodModel.m
//  CarSocial
//
//  Created by wang jam on 8/30/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "GoodModel.h"

@implementation GoodModel

- (id)init
{
    if (self = [super init]) {
        _counterUserInfo = [[UserInfoModel alloc] init];
        _sendUserInfo = [[UserInfoModel alloc] init];
        _contentModel = [[ContentModel alloc] init];
        _commentModel = [[CommentModel alloc] init];
    }
    return self;
}


- (void)setCommentGoodModel:(NSDictionary*)feedback
{
    _sendUserInfo.faceImageThumbnailURLStr = [feedback objectForKey:@"user_facethumbnail"];
    _sendUserInfo.nickName = [feedback objectForKey:@"user_name"];
    _sendUserInfo.userID = [feedback objectForKey:@"user_id"];
    
    _publish_time = [[feedback objectForKey:@"cgbi_timestamp"] integerValue];
    _commentStr = @"赞了你的评论";
    
    _contentModel.contentID = [feedback objectForKey:@"content_id"];
    
    _commentModel.commentStr = [feedback objectForKey:@"comment_content"];
    _contentModel.contentStr = [feedback objectForKey:@"comment_content"];
}

- (void)setGoodModel:(NSDictionary*)feedback
{
    _sendUserInfo.faceImageThumbnailURLStr = [feedback objectForKey:@"user_facethumbnail"];
    _sendUserInfo.nickName = [feedback objectForKey:@"user_name"];
    _sendUserInfo.userID = [feedback objectForKey:@"user_id"];
    
    
    _publish_time = [[feedback objectForKey:@"gbi_timestamp"] integerValue];
    _commentStr = @"赞了状态";
    
    
    _contentModel.contentStr = [feedback objectForKey:@"content"];
    _contentModel.contentID = [feedback objectForKey:@"content_id"];
    _contentModel.imageUrlStr = [feedback objectForKey:@"content_image_url"];

}


@end
