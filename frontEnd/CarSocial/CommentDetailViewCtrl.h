//
//  CommentDetailViewCtrl.h
//  CarSocial
//
//  Created by wang jam on 3/25/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class CBStoreHouseRefreshControl;
enum handleType {comment,good};


@interface CommentDetailViewCtrl : UITableViewController

//@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;

@property enum handleType handle;

@end
