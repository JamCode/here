//
//  HotContentAction.m
//  here_ios
//
//  Created by wang jam on 9/27/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "HotContentAction.h"
#import "ContentModel.h"
#import "ContentTableViewCell.h"
#import "macro.h"
#import "Constant.h"
#import "ContentDetailViewController.h"
#import "NetWork.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "ContentSectionView.h"

@implementation HotContentAction
{
    NSMutableArray* contentModeArray;
    pullCompleted completed;
    ComTableViewCtrl* comTable;
}


- (void)pullDownAction:(pullCompleted)completedBlock //下拉响应函数
{
    completed = completedBlock;
    [self getPopularContent];
    
}


- (void)getPopularContent
{
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[@"/getPopularContent"] forKeys:@[@"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
    
}

- (void)fillContentList:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSDictionary* contentsDic = [feedback objectForKey:@"contents"];
    NSArray* contents = [contentsDic allValues];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserInfoModel* myinfo = app.myInfo;
    
    for (NSDictionary* element in contents) {
        ContentModel* contentMode = [[ContentModel alloc] init];
        [contentMode setContentModel:element];
        
        CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myinfo.latitude longitude:myinfo.longitude];
        CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:contentMode.latitude longitude:contentMode.longitude];
        CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
        contentMode.distanceMeters = meters;
        
        [contentModeArray addObject:contentMode];
        
    }
    
    [contentModeArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContentModel* element1 = (ContentModel*)obj1;
        ContentModel* element2 = (ContentModel*)obj2;
        return element1.publishTimeStamp<element2.publishTimeStamp;
    }];
}

- (void)getContentSuccess:(id)sender
{
    [contentModeArray removeAllObjects];
    [self fillContentList:sender];
}





- (NSInteger)rowNum
{
    return 1;
}

- (NSInteger)sectionNum
{
    return [contentModeArray count];
}

- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
//    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
//    ContentDetailViewController* contentDetail = [[ContentDetailViewController alloc] init];
//    
//    contentDetail.contentModel = model;
//    contentDetail.hidesBottomBarWhenPushed = YES;
//    [comTableViewCtrl.navigationController pushViewController:contentDetail animated:YES];
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    comTable = comTableViewCtrl;
    
    contentModeArray = [[NSMutableArray alloc] init];
    
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"热门"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    comTable.navigationItem.titleView = navTitle;
    
    comTable.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    return [ContentTableViewCell getTotalHeight:model maxContentHeight:ScreenHeight];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ContentSectionView* contentSectionView = [[ContentSectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, [ContentSectionView contentSectionHeight])];
    [contentSectionView configure:[contentModeArray objectAtIndex:section]];
    
    return contentSectionView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ContentSectionView contentSectionHeight];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"hotContentCell";
    ContentTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellId];
    
    if (cell==nil) {
        cell = [[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        NSLog(@"new cell");
    }
    
    
    cell.tableView = tableview;
    cell.contentModeArray = contentModeArray;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.tableView = comTable.tableView;
    
    ContentModel* contentmodel = [contentModeArray objectAtIndex:indexPath.section];
    [cell setContentModel:contentmodel];
    return cell;
}


@end
