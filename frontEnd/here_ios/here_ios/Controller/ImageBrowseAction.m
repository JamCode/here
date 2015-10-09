//
//  ImageBrowseAction.m
//  CarSocial
//
//  Created by wang jam on 9/8/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "ImageBrowseAction.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import "UserInfoModel.h"
#import "macro.h"
#import "NetWork.h"
#import "NetWork.h"
#import "Tools.h"
#import "ImageBrowseCell.h"
#import "ImageModel.h"

@implementation ImageBrowseAction
{
    NSMutableArray* dataList;
    NSString* my_user_id;
    pullCompleted completed;
}

- (id)init:(NSString*)user_id
{
    if (self = [super init]) {
        my_user_id = user_id;
    }
    return self;
}

- (void)pullUpAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    
    NSArray* lastModelArray = [dataList lastObject];
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    if (lastModelArray != nil) {
        ImageModel* imageModel = [lastModelArray lastObject];
        lastTimestamp = imageModel.timestamp;
    }
    
    [self getUserImages:lastTimestamp handleAction:@selector(getUserImageHisSuccess:)];
    
}

- (void)pullDownAction:(pullCompleted)completedBlock
{
    completed = completedBlock;
    [self getUserImages:[[NSDate date] timeIntervalSince1970] handleAction:@selector(getUserImageSuccess:)];

}

- (NSInteger)rowNum
{
    return [dataList count];
}

- (UITableViewCell*)generateCell:(UITableView*)tableview indexPath:(NSIndexPath *)indexPath
{
    ImageBrowseCell *cell = [tableview dequeueReusableCellWithIdentifier:@"ImageBrowseCell"];
    
    if (cell==nil) {
        cell = [[ImageBrowseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NearByTableViewCell"];
        NSLog(@"new cell");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableArray* imagemodels = (NSMutableArray*)[dataList objectAtIndex:indexPath.row];
    
    [cell setModels:imagemodels];
    return cell;
}

- (void)initAction:(ComTableViewCtrl*)comTableViewCtrl
{
    dataList = [[NSMutableArray alloc] init];
    comTableViewCtrl.tableView.separatorStyle = NO;
}

- (CGFloat)cellHeight:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    return [ImageBrowseCell cellHeight];
}

- (void)tableViewWillAppear:(ComTableViewCtrl*)comTableViewCtrl
{
    
}

- (void)tableViewWillDisappear:(ComTableViewCtrl*)comTableViewCtrl
{
    
}


- (void)getUserImages:(NSInteger)lastTimestamp handleAction:(SEL)handleAction
{
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[my_user_id, [[NSNumber alloc] initWithInteger:lastTimestamp],[[NSNumber alloc] initWithInt:15], @"/getUserImage"] forKeys:@[@"user_id", @"timestamp", @"count", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&handleAction objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getUserImageError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getUserImageException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        completed();
    } callObject:self];
    
}

- (void)getUserImageHisSuccess:(id)sender
{
    [self fillWithImages:sender];
}


- (void)getUserImageSuccess:(id)sender
{
    [dataList removeAllObjects];
    [self fillWithImages:sender];
}

- (void)fillWithImages:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSArray* contents = [feedback objectForKey:@"data"];
    
    
    NSMutableArray* modelsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary* element in contents) {
        ImageModel* imageModel = [[ImageModel alloc] init];
        [imageModel setModels:element];
        [modelsArray addObject:imageModel];
        
        if ([modelsArray count]%3 == 0) {
            [dataList addObject:modelsArray];
            modelsArray = [[NSMutableArray alloc] init];
        }
    }
    
    if ([modelsArray count]>0) {
        [dataList addObject:modelsArray];
    }
}

- (void)getUserImageError:(id)sender
{
    [Tools AlertMsg:@"getUserImageError"];
}

- (void)getUserImageException:(id)sender
{
    [Tools AlertMsg:@"getUserImageException"];

}


@end
