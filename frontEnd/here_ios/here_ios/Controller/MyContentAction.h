//
//  MyContentAction.h
//  CarSocial
//
//  Created by wang jam on 9/8/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComTableViewCtrl.h"


@interface MyContentAction : NSObject<ComTableViewDelegate, UITextViewDelegate>


- (id)init:(NSString*)user_id;

@end
