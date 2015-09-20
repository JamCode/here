//
//  VisitModel.m
//  here_ios
//
//  Created by wang jam on 9/15/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "VisitModel.h"

@implementation VisitModel


- (void)setModels:(NSDictionary*)dict
{
    _thumbnailStr = [dict objectForKey:@"user_facethumbnail"];
    _nickName = [dict objectForKey:@"user_name"];
    _visitTimeStamp = [[dict objectForKey:@"visit_timestamp"] integerValue];
    _userID = [dict objectForKey:@"visit_user_id"];
}

@end
