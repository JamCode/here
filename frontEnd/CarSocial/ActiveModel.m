//
//  ActiveModel.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "ActiveModel.h"
#import "UserInfoModel.h"

@implementation ActiveModel

- (id)init
{
    if (self = [super init]) {
        _userInfo = [[UserInfoModel alloc] init];
        
    }
    return self;
}


@end
