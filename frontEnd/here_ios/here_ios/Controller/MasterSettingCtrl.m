//
//  MasterSettingCtrl.m
//  here_ios
//
//  Created by wang jam on 10/1/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "MasterSettingCtrl.h"
#import "macro.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SettingViewController.h"
#import "FeedBackCtrl.h"

typedef enum masterSection{
    face,
    account,
    support,
    logout
} section;

@interface MasterSettingCtrl ()
{
    UserInfoModel* userInfo;
}
@end

@implementation MasterSettingCtrl




- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"设置"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    userInfo = [AppDelegate getMyUserInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == face) {
        return 1;
    }
    
    if (section == account) {
        return 3;
    }
    
    if (section == support) {
        return 1;
    }
    
    if (section == logout) {
        return 1;
    }
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == face) {
        return 64;
    }else{
        return 44;
    }
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == account) {
        return @"账户";
    }
    
    if (section == support) {
        return @"支持";
    }
    return @"";
}

- (void)logout
{
    MBProgressHUD* loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    
    [loadingView showAnimated:YES whileExecutingBlock:^{
        
        //清理本地账户信息
        NSUserDefaults *mySettingData = [NSUserDefaults standardUserDefaults];
        [mySettingData removeObjectForKey:@"phone"];
        [mySettingData removeObjectForKey:@"password"];
        [mySettingData synchronize];
        [NSThread sleepForTimeInterval:3.0];
        
        //发送注销请求给服务器
        
    } completionBlock:^{
        //self.parentViewController.view.hidden = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        //self.view.hidden = NO;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == logout) {
        [self logout];
    }
    
    if (indexPath.section == account) {
        if (indexPath.row == 0) {
            SettingViewController* setting = [[SettingViewController alloc] init:userInfo];
            setting.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:setting animated:YES];
        }
    }
    
    if (indexPath.section == support) {
        FeedBackCtrl* feedback = [[FeedBackCtrl alloc] init];
        feedback.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:feedback animated:YES];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == face) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"masterFaceSettingCell"];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"masterFaceSettingCell"];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"masterSettingCell"];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"masterSettingCell"];
        }
    }
    
    
    if (indexPath.section == face) {
        [cell.imageView sd_setImageWithURL:[[NSURL alloc] initWithString:userInfo.faceImageThumbnailURLStr]];
        cell.textLabel.text = userInfo.nickName;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = userInfo.sign;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    if (indexPath.section == logout) {
        cell.textLabel.text = @"退出账户";
        cell.textLabel.textColor = subjectColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (indexPath.section == support) {
        cell.textLabel.text = @"用户反馈";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == account) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"我的资料";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"评论过的内容";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"赞过的内容";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    NSMutableArray* visitmodels = (NSMutableArray*)[dataList objectAtIndex:indexPath.row];
//    
//    [cell setModels:visitmodels];
    
    return cell;

}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
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
