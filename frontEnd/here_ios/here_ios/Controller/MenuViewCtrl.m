//
//  MenuViewCtrl.m
//  CarSocial
//
//  Created by wang jam on 3/23/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "MenuViewCtrl.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "MenuCell.h"
#import "CommentDetailAction.h"
#import "NetWork.h"
#import "macro.h"
#import "Tools.h"
#import "NearByPersonAction.h"
#import "ComTableViewCtrl.h"
#import "GoodDetailAction.h"
#import "SettingViewController.h"

@interface MenuViewCtrl ()

@end

@implementation MenuViewCtrl

static const int faceimage_width = 64;

- (void)initHeaderView
{
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];

    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, ScreenHeight/4)];
    
    CGFloat offset = ScreenWidth/5;
    
    
    UIImageView* faceimage = [[UIImageView alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width/2+offset - faceimage_width)/2, 44, faceimage_width, faceimage_width)];
    faceimage.layer.cornerRadius = faceimage_width/2;
    faceimage.layer.masksToBounds = YES;
    
    
    [headerView addSubview:faceimage];
    UILabel* nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, faceimage.frame.origin.y+faceimage_width, self.tableView.frame.size.width/2+offset, 44)];
    nickNameLabel.text = myInfo.nickName;
    nickNameLabel.textAlignment = NSTextAlignmentCenter;
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.font = [UIFont fontWithName:@"Arial" size:20];
    [headerView addSubview:nickNameLabel];
    
    
    [faceimage sd_setImageWithURL:[[NSURL alloc] initWithString:myInfo.faceImageThumbnailURLStr] placeholderImage:[UIImage imageNamed:@"loading.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    self.tableView.tableHeaderView = headerView;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = myblack;
    self.tableView.backgroundColor = myblack;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self initHeaderView];
    
    
    //注册左滑动事件
    UISwipeGestureRecognizer *swapLeft = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(closeButtonPressed)];
    swapLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swapLeft];
}

- (void)closeButtonPressed
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.sideMenu closeMenuAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    if (indexPath.row == 0) {
        //go to comment detail view
        [app.sideMenu closeMenuAnimated:YES completion:nil];
        UINavigationController* nav =  (UINavigationController*)[app.tabBarViewController.viewControllers objectAtIndex:0];
        
        ComTableViewCtrl* comTableCtrl = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[CommentDetailAction alloc] init]];
        
        comTableCtrl.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:comTableCtrl animated:NO];
        
        
    }
    
    if (indexPath.row == 1) {
        //我的赞
        [app.sideMenu closeMenuAnimated:YES completion:nil];
        UINavigationController* nav =  (UINavigationController*)[app.tabBarViewController.viewControllers objectAtIndex:0];

        ComTableViewCtrl* comTableCtrl = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[GoodDetailAction alloc] init]];
        
        comTableCtrl.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:comTableCtrl animated:NO];
    }
    
    if (indexPath.row == 2) {
        //附近的人
        [app.sideMenu closeMenuAnimated:YES completion:nil];
        UINavigationController* nav =  (UINavigationController*)[app.tabBarViewController.viewControllers objectAtIndex:0];
        ComTableViewCtrl* comTableCtrl = [[ComTableViewCtrl alloc] init:YES allowPullUp:NO initLoading:YES comDelegate:[[NearByPersonAction alloc] init]];
        comTableCtrl.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:comTableCtrl animated:NO];
    }
    
    if(indexPath.row == 3){
        //我的资料
        
        [app.sideMenu closeMenuAnimated:YES completion:nil];
        UINavigationController* nav =  (UINavigationController*)[app.tabBarViewController.viewControllers objectAtIndex:0];
        
        SettingViewController* userSetting = [[SettingViewController alloc] init:[AppDelegate getMyUserInfo]];
        
        userSetting.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:userSetting animated:NO];
        
    }
}





//- (void)setCommentNotice:(NSInteger)commentCount
//{
//    MenuCell* commentCell = (MenuCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//    [commentCell setCommentNotice:commentCount];
//}



- (void)getUnreadNoticeMsgCount
{
    //get unread notice msg count
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, @"/getNoticeMsgCount"] forKeys:@[@"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(checkUnreadMsgSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(checkUnreadMsgError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(checkUnreadMsgException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        ;
    } callObject:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}


- (void)setNoticeCount:(NSDictionary* )feedback
{
    NSIndexPath* index = [NSIndexPath indexPathForRow:0 inSection:0];
    MenuCell* cell = (MenuCell*)[self.tableView cellForRowAtIndexPath:index];
    
    NSInteger count = [[feedback objectForKey:@"unreadCommentsCount"] integerValue];
    [cell setNoticeCount:count];
    
    index = [NSIndexPath indexPathForRow:1 inSection:0];
    cell = (MenuCell*)[self.tableView cellForRowAtIndexPath:index];
    count = [[feedback objectForKey:@"unreadGoodCount"] integerValue];
    [cell setNoticeCount:count];
    
}

- (void)removeNoticeCount
{
    
}

- (void)checkUnreadMsgSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    [self setNoticeCount: feedback];
}

- (void)checkUnreadMsgError:(id)sender
{
    NSLog(@"checkUnreadMsgError");
}

- (void)checkUnreadMsgException:(id)sender
{
    NSLog(@"checkUnreadMsgException");
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (cell == nil) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"我的评论";
        //[cell setCommentNotice:10];
    }
    
    if (indexPath.row == 1) {
        cell.textLabel.text = @"我的赞";
    }
    
    if (indexPath.row == 2) {
        cell.textLabel.text = @"附近的人";
    }
    
    if (indexPath.row == 3) {
        cell.textLabel.text = @"我的资料";
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = myblack;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 30, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    return cell;
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
     Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
