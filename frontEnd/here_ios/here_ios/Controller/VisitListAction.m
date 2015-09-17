//
//  VisitListAction.m
//  here_ios
//
//  Created by wang jam on 9/15/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "VisitListAction.h"
#import "VisitCell.h"
#import "NetWork.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "macro.h"
#import "Constant.h"
#import "Tools.h"
#import "VisitModel.h"

@implementation VisitListAction
{
    NSMutableArray* dataList;
    pullCompleted completed;

}

- (void)pullDownAction:(pullCompleted)completedBlock; //下拉响应函数
{
    completed = completedBlock;
    [self getVisitList:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getVisitListSuccess:)];
}

- (void)getVisitList:(NSInteger)lastTimestamp handleAction:(SEL)handleAction
{
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, [[NSNumber alloc] initWithInteger:lastTimestamp], @"/getAllVisit"] forKeys:@[@"user_id", @"timestamp", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getVisitListError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getVisitListException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
    
}

- (void)getVisitListSuccess:(id)sender
{
    [dataList removeAllObjects];
    
    NSDictionary* feedback = (NSDictionary*)sender;
    NSArray* contents = [feedback objectForKey:@"data"];
    
    
    NSMutableArray* modelsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary* element in contents) {
        VisitModel* visitModel = [[VisitModel alloc] init];
        [visitModel setModels:element];
        [modelsArray addObject:visitModel];
        
        if ([modelsArray count]%4 == 0) {
            [dataList addObject:modelsArray];
            modelsArray = [[NSMutableArray alloc] init];
        }
    }
    
    if ([modelsArray count]>0) {
        [dataList addObject:modelsArray];
    }
    
}


- (void)getVisitListException:(id)sender
{
    [Tools AlertMsg:@"getVisitListException"];
}

- (void)getVisitListError:(id)sender
{
    [Tools AlertMsg:@"getVisitListError"];
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
    VisitCell *cell = [tableview dequeueReusableCellWithIdentifier:@"VisitCell"];
    
    if (cell==nil) {
        cell = [[VisitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VisitCell"];
        NSLog(@"new cell");
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableArray* visitmodels = (NSMutableArray*)[dataList objectAtIndex:indexPath.row];
    
    [cell setModels:visitmodels];
    
    return cell;
}


- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];
    comTableViewCtrl.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return [VisitCell cellHeight];
}


@end
