//
//  ComTableViewCtrl.h
//  ComTableViewCtrl
//
//  Created by wang jam on 8/30/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^pullCompleted)();
@class ComTableViewCtrl;

@protocol ComTableViewDelegate <NSObject>

@optional
- (void)pullUpAction:(pullCompleted)completedBlock; //上拉响应函数
- (void)pullDownAction:(pullCompleted)completedBlock; //下拉响应函数
- (NSInteger)rowNum;
- (NSInteger)sectionNum;
- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath;
- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl;
- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath;
- (void)tableViewWillAppear:(ComTableViewCtrl*)comTableViewCtrl;
- (void)tableViewWillDisappear:(ComTableViewCtrl*)comTableViewCtrl;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
@required
- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath;


@end

@interface ComTableViewCtrl : UITableViewController

- (id)init:(BOOL)allowPullDown allowPullUp:(BOOL)allowPullUp initLoading:(BOOL)loading comDelegate:(id<ComTableViewDelegate>)delegate;

- (void)pullDown; //下拉加载

- (void)refreshNew;

- (void)forbidPullDown; //禁用下拉加载
- (void)allowPullDown; //允许下拉加载

- (void)forbidPullUp;//禁用上拉加载
- (void)allowPullUp;//允许上拉加载

@end



