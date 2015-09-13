//
//  ActiveViewController.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EGORefreshTableHeaderView.h>
#import <CoreLocation/CoreLocation.h>

@interface ActiveViewController : UIViewController<UIScrollViewDelegate, EGORefreshTableHeaderDelegate, CLLocationManagerDelegate>


- (void)getActive;

@end
