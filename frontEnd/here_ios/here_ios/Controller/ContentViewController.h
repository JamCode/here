//
//  ActiveViewController.h
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ContentModel.h"
#import "ComTableViewCtrl.h"

@class ContentTableViewCell;

@interface ContentViewController : UITableViewController<UIScrollViewDelegate, CLLocationManagerDelegate, UITabBarDelegate, UITextViewDelegate>

- (id)init:(NSString*)title publishButtonFlag:(BOOL)flag setLoadingAction:(SEL)action content_user_id:(NSString*)content_user_id;

- (void)showCommentInputView:(ContentTableViewCell*)contentModel;


- (void)refreshNews;

- (void)getNearbyContent;
- (void)getPopularContent;
- (void)getMyContent;
- (void)getMyContentByCity;
- (void)getCollectContent;

- (void)callLoadingAction;


- (void)checkUnreadMsg;

- (BOOL)tabbarHidden;
//- (void)showTabbarAndNavBar;
//- (void)hiddenTabbarAndNavBar;

@property NSString* city_desc;


@property NSMutableDictionary* faceImageDic;

@end
