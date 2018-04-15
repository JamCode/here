//
//  SignInViewController.m
//  CarSocial
//
//  Created by wang jam on 8/31/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "SignInViewController.h"
#import "Constant.h"
#import <MBProgressHUD.h>
#import "NetWork.h"
#import "TabBarViewController.h"
#import "macro.h"
#import "RegisterCellViewTableViewCell.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "CocoaSecurity.h"
#import "TWTSideMenuViewController.h"
#import "MenuViewCtrl.h"
#import "Tools.h"
#import "NetworkAPI.h"

@interface SignInViewController ()
{
    UITableView* tableview;
    UITextField* phoneNumTextField;
    UITextField* passwordTextField;
    MBProgressHUD* loadingView;
    double latitude;
    double longitude;
    
}
@end

@implementation SignInViewController

static const int tableview_x = 0;
static const int tableview_y = 44;
static const int tableview_cell_height = 44;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(tableview_x, tableview_y, ScreenWidth, tableview_cell_height*2+8)];
    
    [tableview setDelegate:self];
    [tableview setDataSource:self];
    tableview.scrollEnabled = NO;
    [self.view addSubview: tableview];
    
    //重发验证码
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(10, tableview.frame.origin.y+tableview.frame.size.height+20, ScreenWidth - 2*10, 44);
    
    loginButton.backgroundColor = subjectColor;
    loginButton.layer.cornerRadius = 6;
    
    [loginButton setTitle:[[NSString alloc] initWithFormat:@"登录"] forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [loginButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (void)getfollowInfo
{
    //[app.locDatabase clearFollowInfo];
    
    
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc]
                             initWithObjects:@[myInfo.userID,
                                               @"/getfollowInfo"]
                             forKeys:@[@"user_id",  @"childpath"]];
    
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:
                                  @[[NSValue valueWithBytes:&@selector(getfollowInfoSuccess:) objCType:@encode(SEL)]]forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    
    NetWork* netWork = [[NetWork alloc] init];
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
    } callObject:self];
    
    
    
}


- (void)getfollowInfoSuccess:(id)sender
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.locDatabase clearFollowInfo];
    
    NSDictionary* feedback = (NSDictionary*)sender;
    
    NSArray* data = [feedback objectForKey:@"data"];
    
    for (NSDictionary* element in data) {
        [app.locDatabase addFollowInfo:[element objectForKey:@"followed_user_id"]];
    }
    
}


- (void)loginSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [app.myInfo fillWithData:feedback];
    
    
    //本地库连接
    NSLog(@"%@", app.myInfo.userID);
    app.locDatabase = [[LocDatabase alloc] init];
    if(![app.locDatabase connectToDatabase:app.myInfo.userID]){
        alertMsg(@"本地数据库问题");
        return;
    }
    
    [self getfollowInfo];
    
    
    
    
    //用户登录信息持久化
    NSUserDefaults *mySettingData = [NSUserDefaults standardUserDefaults];
    [mySettingData setObject:app.myInfo.phoneNum forKey:@"phone"];
    [mySettingData setObject:app.myInfo.password forKey:@"password"];
    [mySettingData synchronize];
    
    TabBarViewController* tabbarView = [[TabBarViewController alloc] init];
    app.tabBarViewController = tabbarView;
    
    MenuViewCtrl* menu = [[MenuViewCtrl alloc] init];
    TWTSideMenuViewController* sideMenu = [[TWTSideMenuViewController alloc] initWithMenuViewController:menu mainViewController:tabbarView];
    
    
    CGFloat offset = ScreenWidth/5;
    sideMenu.edgeOffset = (UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? offset : 0.0f };
    
    
    sideMenu.zoomScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.5634f : 0.85f;
    sideMenu.zoomScale = 0.9;
    
    app.sideMenu = sideMenu;
    sideMenu.navigationController.navigationBar.hidden = YES;
    
    [self presentViewController:sideMenu animated:YES completion:nil];
    
    
    //register remoteNotification
    
    UIApplication* application = [UIApplication sharedApplication];
    
    if (IS_OS_8_OR_LATER) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
    
}


- (void)loginFail:(id)sender
{
    alertMsg(@"用户名或密码错误");
    self.view.hidden = NO;
}

- (void)loginError:(id)sender
{
    alertMsg(@"网络问题");
    self.view.hidden = NO;
}

- (void)loginException:(id)sender
{
    alertMsg(@"未知问题");
    self.view.hidden = NO;
}


- (void)sendLoginMessage:(UserInfoModel*)userModel
{


    
    NSDictionary* message = [[NSDictionary alloc]
                             initWithObjects:@[userModel.phoneNum,
                                               userModel.password,
                                               @"/login"]
                             forKeys:@[@"user_phone", @"password", @"childpath"]];
    

    [NetworkAPI callApiWithParam:message childpath:@"/login" successed:^(NSDictionary *response) {
        
        NSInteger code = [[response objectForKey:@"code"] integerValue];
        if (code == LOGIN_SUCCESS) {
            [self loginSuccess:response];
        }
        
        if (code == LOGIN_FAIL) {
            [self loginFail:nil];
        }
        
        if (code == ERROR) {
            [self loginError:nil];
        }
        
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;

        
        
    } failed:^(NSError *error) {
        [self loginException:nil];
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;

    }];
    
    
//    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:
//                                  @[[NSValue valueWithBytes:&@selector(loginSuccess:) objCType:@encode(SEL)],
//                                    [NSValue valueWithBytes:&@selector(loginFail:) objCType:@encode(SEL)],
//                                    [NSValue valueWithBytes:&@selector(loginError:) objCType:@encode(SEL)],
//                                    [NSValue valueWithBytes:&@selector(loginException:) objCType:@encode(SEL)] ]
//                                                               forKeys:@[[[NSNumber alloc] initWithInt:LOGIN_SUCCESS],
//                                                                         [[NSNumber alloc] initWithInt:LOGIN_FAIL],
//                                                                         [[NSNumber alloc] initWithInt:ERROR],
//                                                                         [[NSNumber alloc] initWithInt:EXCEPTION]]];
//    
//    
//    NetWork* netWork = [[NetWork alloc] init];
//    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
//        [loadingView hide:YES];
//        [loadingView removeFromSuperview];
//        loadingView = nil;
//    } callObject:self];
}

- (void)nextStep:(id)sender
{
    [phoneNumTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    if ([phoneNumTextField.text isEqualToString:@""]||[passwordTextField.text  isEqualToString:@""]) {
        alertMsg(@"用户名或密码不能为空");
        return;
    }
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    loadingView.labelText = @"正在登录...";
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.myInfo.phoneNum = phoneNumTextField.text;
    
    app.myInfo.password = [Tools encodePassword:passwordTextField.text];

    
    [self sendLoginMessage:app.myInfo];
    
    NSLog(@"loginButtonAction");
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegisterCellViewTableViewCell* cell = [[RegisterCellViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCell"];
    
    
    if(indexPath.section == 0){
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 232, 32)];
        
        cell.accessoryView = textField;
        
        if (indexPath.row==0) {
            textField.placeholder = @"请输入手机号码";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            phoneNumTextField = textField;
            cell.imageView.image = [UIImage imageNamed:@"cellphone64px.png"];
        }
        if (indexPath.row == 1) {
            textField.placeholder = @"请输入密码";
            textField.secureTextEntry = YES;
            passwordTextField = textField;
            cell.imageView.image = [UIImage imageNamed:@"password64px.png"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
        
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"phone"]==nil||
        [[NSUserDefaults standardUserDefaults] objectForKey:@"password"]==nil) {
        self.view.hidden = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"signinview delloc");
        
        tableview = nil;
        phoneNumTextField = nil;
        passwordTextField = nil;
        loadingView = nil;
        self.view = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
