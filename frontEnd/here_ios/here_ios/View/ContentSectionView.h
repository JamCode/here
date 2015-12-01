//
//  ContentSectionView.h
//  here_ios
//
//  Created by wang jam on 11/27/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentModel.h"

@interface ContentSectionView : UIView

- (void)configure:(ContentModel*)contentModel;

+ (NSInteger)contentSectionHeight;

@end
