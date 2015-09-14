//
//  MyContentAction.m
//  CarSocial
//
//  Created by wang jam on 9/8/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "MyContentAction.h"
#import "ContentModel.h"
#import "ContentTableViewCell.h"
#import "ContentDetailViewController.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import "macro.h"
#import "Constant.h"
#import "Tools.h"

@implementation MyContentAction
{
    NSMutableArray* contentModeArray;
    pullCompleted completed;
    ComTableViewCtrl* comTable;
    UIToolbar* bottomToolbar;
    UITextView* commentInputView;
    NSString* my_content_user_id;

}


- (id)init:(NSString*)user_id
{
    if ([super init]) {
        my_content_user_id = user_id;
    }
    return self;
}

- (void)pullUpAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    
    ContentModel* lastModel = [contentModeArray lastObject];
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    if (lastModel != nil) {
        lastTimestamp = lastModel.publishTimeStamp;
    }
    
    [self getMyContent:lastTimestamp handleAction:@selector(getContentHisSuccess:)];
}

- (void)pullDownAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    [self getMyContent:lastTimestamp handleAction:@selector(getContentSuccess:)];
}

- (NSInteger)rowNum
{
    return [contentModeArray count];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"MyContentTableViewCell";
    ContentTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSLog(@"new cell");
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.tableView = comTable.tableView;
    
    ContentModel* contentmodel = [contentModeArray objectAtIndex:indexPath.row];
    [cell setContentModel:contentmodel];
    return cell;
}

- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    ContentDetailViewController* contentDetail = [[ContentDetailViewController alloc] init];
    
    contentDetail.contentModel = model;
    contentDetail.hidesBottomBarWhenPushed = YES;
    [comTableViewCtrl.navigationController pushViewController:contentDetail animated:YES];
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

- (void)getContentHisSuccess:(id)sender
{
    [self fillContentList:sender];
}

- (void)getMyContent:(NSInteger)lastTimestamp handleAction:(SEL)handleAction
{
    //异步注册信息
    UserInfoModel* myinfo = [AppDelegate getMyUserInfo];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:lastTimestamp], my_content_user_id, myinfo.userID, @"/getContentByUser"] forKeys:@[@"last_timestamp", @"user_id", @"my_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getContentError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getContentException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
}

- (void)getContentException:(id)sender
{
    [Tools AlertMsg:@"getContentException"];
}

- (void)getContentError:(id)sender
{
    [Tools AlertMsg:@"getContentError"];
}

- (void)getContentSuccess:(id)sender
{
    [contentModeArray removeAllObjects];
    [self fillContentList:sender];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    comTable = comTableViewCtrl;
    
    contentModeArray = [[NSMutableArray alloc] init];
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    return [ContentTableViewCell getTotalHeight:model maxContentHeight:ScreenHeight];
}

- (void)tableViewWillAppear:(ComTableViewCtrl*)comTableViewCtrl
{
    
}

- (void)tableViewWillDisappear:(ComTableViewCtrl*)comTableViewCtrl
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
}


@end
