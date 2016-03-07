//
//  UserSearchTableViewController.m
//  stockFront
//
//  Created by wang jam on 2/1/16.
//  Copyright © 2016 jam wang. All rights reserved.
//

#import "UserSearchTableViewController.h"
#import "macro.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "NetworkAPI.h"
#import <YYModel.h>
#import "SettingViewController.h"
#import "Constant.h"
#import "Tools.h"


@interface UserSearchTableViewController ()
{
    UITextField* userSearchTextField;
    NSMutableArray* userlist;
}
@end

@implementation UserSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    navTitle.textColor = [UIColor whiteColor];
    [navTitle setText:@"找人"];
    [navTitle setFont:[UIFont fontWithName:fontName size:middleFont]];
    navTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = navTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    userSearchTextField = [[UITextField alloc] init];
    userSearchTextField.frame = CGRectMake(0, 0, ScreenWidth - 4*minSpace, 6*minSpace);
    userSearchTextField.textAlignment = NSTextAlignmentLeft;
    userSearchTextField.placeholder = @"查找的用户名";
    userSearchTextField.delegate = self;
    userSearchTextField.returnKeyType = UIReturnKeySearch;
    
    userlist = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    [self.tableView setDataSource:self];
    [self.tableView reloadData];

    
}


- (void)searchByName:(NSString*)user_name
{
    UserInfoModel* myinfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc]
                             initWithObjects:@[user_name, myinfo.userID]
                             forKeys:@[@"user_name", @"user_id"]];
    
    [NetworkAPI callApiWithParam:message childpath:@"/searchUser" successed:^(NSDictionary *response) {
        
        
        NSInteger code = [[response objectForKey:@"code"] integerValue];
        
        if(code == SUCCESS){
            
            [userlist removeAllObjects];
            
            NSArray* templist = (NSArray*)[response objectForKey:@"data"];
            
            if(templist!=nil){
                for (NSDictionary* element in templist) {
                    UserInfoModel* temp = [UserInfoModel yy_modelWithDictionary:element];
                    [userlist addObject:temp];
                }
                
                
                [self.tableView reloadData];
            }
            
        }else{
            [Tools AlertBigMsg:@"未知错误"];
        }
        
        
    } failed:^(NSError *error) {
        [Tools AlertBigMsg:@"网络问题"];
    }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == userSearchTextField){
        NSLog(@"textFieldShouldReturn");
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (textField.text.length==0||textField.text==nil) {
            return YES;
        }

        [self searchByName:textField.text];
    }
    return YES;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"搜索结果";
    }
    return @"";
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [userSearchTextField resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField*)textField
{
//    if(textField.text.length == 6){
//        NSLog(@"search stock code: %@", textField.text);
//        NSString* stockCode = textField.text;
//        
//        
//        //发送搜索消息
//        NSDictionary* message = [[NSDictionary alloc]
//                                 initWithObjects:@[stockCode]
//                                 forKeys:@[@"stock_code"]];
//        
//        [NetworkAPI callApiWithParam:message childpath:@"/stock/getStock" successed:^(NSDictionary *response) {
//            
//            NSInteger code = [[response objectForKey:@"code"] integerValue];
//            
//            if(code == SUCCESS){
//                
//                [self loadStockInfo:[response objectForKey:@"data"]];
//                
//            }else if(code == STOCK_NOT_EXIST){
//                [stockList removeAllObjects];
//                [self.tableView reloadData];
//                
//            }else{
//                alertMsg(@"未知错误");
//            }
//            
//            
//        } failed:^(NSError *error) {
//            alertMsg(@"网络问题");
//        }];
//        
//        
//    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 6*minSpace;
    }
    
    if(indexPath.section == 1){
        //return [FaceCellViewTableViewCell cellHeight];
    }
    
    return 0;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [userSearchTextField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [userSearchTextField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    if(section == 1){
        return [userlist count];
    }
    
    return 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.tableView reloadData];
    NSLog(@"viewWillAppear");
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UserInfoModel* userInfo = [userlist objectAtIndex:indexPath.row];
        SettingViewController* settingViewController = [[SettingViewController alloc] init:userInfo];
        settingViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:settingViewController animated:YES];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        static NSString* cellIdentifier = @"searchcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        // Configure the cell...
        // Configure the cell...
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            NSLog(@"new cell");
        }
        
        cell.accessoryView = userSearchTextField;
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    
    if(indexPath.section == 1){
        static NSString* cellIdentifier = @"usercell";
//        FaceCellViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (cell==nil) {
//            cell = [[FaceCellViewTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//            NSLog(@"new cell");
//        }
//        
//        UserInfoModel* userInfo = [userlist objectAtIndex:indexPath.row];
//        [cell configureCell:userInfo];
//        return cell;
    }
    
    return nil;
    
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
