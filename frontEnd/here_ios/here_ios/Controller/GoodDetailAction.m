//
//  GoodDetailAction.m
//  CarSocial
//
//  Created by wang jam on 9/7/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "GoodDetailAction.h"
#import "CommentDetailCell.h"
#import "NetWork.h"
#import "AppDelegate.h"
#import "macro.h"
#import "Constant.h"
#import "Tools.h"
#import "ContentDetailViewController.h"

@implementation GoodDetailAction
{
    NSMutableArray* dataList;
}

- (void)pullUpAction:(pullCompleted)completedBlock
{
    GoodModel* goodModel = [dataList lastObject];
    if (goodModel == nil) {
        completedBlock();
    }else{
        [self getGood:goodModel.publish_time handleAction:@selector(getGoodHisSuccess:) pullComplete:completedBlock];
    }
}

- (void)pullDownAction:(pullCompleted)completedBlock
{
    [self getGood:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getGoodSuccess:) pullComplete:completedBlock];
}

- (NSInteger)rowNum
{
    return [dataList count];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    CommentDetailCell *cell = [tableview dequeueReusableCellWithIdentifier:@"goodCell"];
    if (cell == nil) {
        cell = [[CommentDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"goodCell"];
    }
    
    GoodModel* goodModel = [dataList objectAtIndex:indexPath.row];
    [cell setUnreadGoodModel:goodModel];
    
    return cell;

}

- (void)didSelectedCell:(ComTableViewCtrl*)comTableViewCtrl IndexPath:(NSIndexPath *)indexPath
{
    ContentDetailViewController* contentDetailView = [[ContentDetailViewController alloc] init];
    
    GoodModel* goodModel = [dataList objectAtIndex:indexPath.row];
    
    contentDetailView.contentModel = goodModel.contentModel;
    
    contentDetailView.hidesBottomBarWhenPushed = YES;
    
    [comTableViewCtrl.navigationController pushViewController:contentDetailView animated:YES];
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];

}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return [CommentDetailCell getUnreadCommentCellHeight];
}

- (void)tableViewWillAppear:(ComTableViewCtrl*)comTableViewCtrl
{
    
}

- (void)tableViewWillDisappear:(ComTableViewCtrl*)comTableViewCtrl
{
    [comTableViewCtrl.tableView deselectRowAtIndexPath:[comTableViewCtrl.tableView indexPathForSelectedRow] animated:YES];

}


- (void)getGoodSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;

    NSArray* data = [feedback objectForKey:@"data"];

    if ([data count]<=0) {
        return;
    }

    [dataList removeAllObjects];

    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        GoodModel* goodModel = [[GoodModel alloc] init];
        [goodModel setGoodModel:element];
        [dataList addObject:goodModel];
    }


}


- (void)getGood:(long)lastTimestamp handleAction:(SEL)handleAction pullComplete:(pullCompleted)pullComplete
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];

    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, [NSNumber numberWithLong:lastTimestamp], @"/getUnreadGood"] forKeys:@[@"user_id", @"timestamp", @"childpath"]];

    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getGoodError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getGoodException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];

    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        pullComplete();
    } callObject:self];
}


- (void)getGoodException:(id)sender
{
    [Tools AlertMsg:@"未知异常"];
}

- (void)getGoodError:(id)sender
{
    [Tools AlertMsg:@"未知错误"];
}


- (void)getGoodHisSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;

    NSArray* data = [feedback objectForKey:@"data"];

    if ([data count]<=0) {
        return;
    }

    //[commentList removeAllObjects];

    for (int i=0; i<[data count]; ++i) {
        NSDictionary* element = [data objectAtIndex:i];
        GoodModel* goodModel = [[GoodModel alloc] init];
        [goodModel setGoodModel:element];
        [dataList addObject:goodModel];
    }

}

@end
