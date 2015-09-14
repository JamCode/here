//
//  CommentModel.h
//  CarSocial
//
//  Created by wang jam on 3/29/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"
#import "ContentModel.h"

@interface CommentModel : NSObject

@property UserInfoModel* counterUserInfo;
@property UserInfoModel* sendUserInfo;
@property ContentModel* contentModel;



@property long publish_time;
@property NSString* commentStr;


- (void)setCommentModel:(NSDictionary*)feedback;


@end
