//
//  ActiveView.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveModel.h"

@interface ActiveView : UIView

- (void)setActiveModel:(ActiveModel*) activeModel;

@property UIViewController* parentViewController;

@end
