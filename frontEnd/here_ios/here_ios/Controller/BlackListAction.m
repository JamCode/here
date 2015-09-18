//
//  BlackListAction.m
//  here_ios
//
//  Created by wang jam on 9/18/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "BlackListAction.h"

@implementation BlackListAction
{
    NSMutableArray* dataList;
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

//- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
//{
//    return 44;
//}

@end
