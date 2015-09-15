//
//  VisitListAction.m
//  here_ios
//
//  Created by wang jam on 9/15/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "VisitListAction.h"
#import "VisitCell.h"

@implementation VisitListAction
{
    NSMutableArray* dataList;
    pullCompleted completed;

}

- (void)pullUpAction:(pullCompleted)completedBlock; //上拉响应函数
{
    
}

- (void)pullDownAction:(pullCompleted)completedBlock; //下拉响应函数
{
    
}

- (NSInteger)rowNum
{
    return [dataList count];
}

- (NSInteger)sectionNum
{
    return 1;
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    return nil;
}


- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return 0;
}


@end
