//
//  NetworkAPI.h
//  stockFront
//
//  Created by wang jam on 1/4/16.
//  Copyright © 2016 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface NetworkAPI : NSObject

+ (void)callApiWithParam:(NSDictionary*)param childpath:(NSString*)childpath successed:(void(^)(NSDictionary *response))successedBlock failed:(void(^)(NSError* error))failedBlock;
+ (void)callApiWithParamForImage:(NSDictionary*)param imageDatas:(NSDictionary*)imageDatas childpath:(NSString*)childpath successed:(void(^)(NSDictionary *response))successedBlock failed:(void(^)(NSError* error))failedBlock;



@end
