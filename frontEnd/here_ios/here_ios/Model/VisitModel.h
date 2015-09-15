//
//  VisitModel.h
//  here_ios
//
//  Created by wang jam on 9/15/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface VisitModel : NSObject

@property NSString* thumbnailStr;
@property NSString* nickName;
@property NSInteger visitTimeStamp;
@property NSString* userID;

- (void)setModels:(NSDictionary*)dict;

@end
