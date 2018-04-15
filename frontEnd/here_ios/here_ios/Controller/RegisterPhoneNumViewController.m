//
//  RegisterPhoneNumViewController.m
//  CarSocial
//
//  Created by wang jam on 8/30/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "RegisterPhoneNumViewController.h"
#import "Constant.h"
#import "RegisterConfirmViewController.h"
#import "RegisterCellViewTableViewCell.h"
#import <MBProgressHUD.h>
#import "NetWork.h"
#import "macro.h"

@interface RegisterPhoneNumViewController ()
{
    UITableView* tableview;
    UITextField* phoneNumTextField;
    UITextField* passwordTextField;
    MBProgressHUD* loadingView;
}
@end

@implementation RegisterPhoneNumViewController

static const int tableview_x = 0;
static const int tableview_y = 44;
static const int tableview_cell_height = 44;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userInfo = [[UserInfoModel alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"登录信息"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep:)];
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(tableview_x, tableview_y, ScreenWidth, tableview_cell_height*2+8)];
    [tableview setDelegate:self];
    [tableview setDataSource:self];
    [self.view addSubview: tableview];
    
    UILabel* noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, tableview.frame.origin.y+tableview.frame.size.height+5, ScreenWidth - 20, 55)];
    noticeLabel.textColor = [UIColor grayColor];
    noticeLabel.text = @"为了保护你的账号安全，请勿设置过于简单的密码 我们不会在任何地方泄露你的手机号码";
    noticeLabel.font = [UIFont fontWithName:@"Arial" size:12];
    noticeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noticeLabel.numberOfLines = 0;
    [self.view addSubview:noticeLabel];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegisterCellViewTableViewCell* cell = [[RegisterCellViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCell"];
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 232, 32)];
    //textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cell.accessoryView = textField;
    if (indexPath.row==0) {
        textField.placeholder = @"请输入手机号码";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        phoneNumTextField = textField;
        cell.imageView.image = [UIImage imageNamed:@"cellphone64px.png"];
    }
    if (indexPath.row == 1) {
        textField.placeholder = @"请输入密码";
        passwordTextField = textField;
        cell.imageView.image = [UIImage imageNamed:@"password64px"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)nextStep:(id)sender
{
    if (phoneNumTextField == nil||phoneNumTextField.text.length!=11) {
        alertMsg(@"电话号码格式不对");
        return;
    }
    
    if (passwordTextField == nil||passwordTextField.text.length<6) {
        alertMsg(@"密码不能小于6位");
        return;
    }
    [phoneNumTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"确认手机号码" message:phoneNumTextField.text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert setTag:101];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            NSLog(@"%ld", (long)buttonIndex);
        }
        if (buttonIndex == 1) {
            NSLog(@"%ld", (long)buttonIndex);
            _userInfo.password = passwordTextField.text;
            _userInfo.phoneNum = phoneNumTextField.text;
            
            //发送验证码
            loadingView = [[MBProgressHUD alloc] initWithView:self.view];
            //loadingView.labelText = @"验证手机号码";
            [self.view addSubview:loadingView];
            [loadingView show:YES];
            
            NetWork* netWork = [[NetWork alloc] init];
            NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.phoneNum, @"/confirmPhone"] forKeys:@[@"user_phone", @"childpath"]];
            
            
            NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(certificateCodeSend:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(phoneExist:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(certificateCodeSend:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(certificateError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(certificateException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:CERTIFICATE_CODE_SEND],[[NSNumber alloc] initWithInt:PHONE_EXIST],[[NSNumber alloc] initWithInt:CERTIFICATE_CODE_SENDED],[[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
            
            [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
                [loadingView hide:YES];
            } callObject:self];
        }
    }
}

- (void)phoneExist:(id)sender
{
    alertMsg(@"电话号码已被注册");
}

- (void)certificateCodeSend:(id)sender
{
    RegisterConfirmViewController* confirmView = [[RegisterConfirmViewController alloc] init];
    confirmView.userInfo = _userInfo;
    
    [self.navigationController pushViewController:confirmView animated:YES];
}

- (void)certificateError:(id)sender
{
    alertMsg(@"网络问题");
}

- (void)certificateException:(id)sender
{
    alertMsg(@"未知问题");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"registerphone delloc");
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
