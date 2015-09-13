//
//  PriMsgModel.m
//  CarSocial
//
//  Created by wang jam on 9/26/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "PriMsgModel.h"

@implementation PriMsgModel


- (id)init
{
    if (self = [super init]) {
        _message_content = @"";
        _data = [_message_content dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

@end
