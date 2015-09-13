//
//  LoginViewController.m
//  miniWeChat
//
//  Created by wang jam on 5/4/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SynthesizeSingleton.h"
#import "Constant.h"
#import "TextFieldView.h"
#import "NetWork.h"
#import "macro.h"
#import "TabBarViewController.h"
#import <MBProgressHUD.h>
//#import "TabBarViewController.h"

@interface LoginViewController ()
{
    TextFieldView* username;
    TextFieldView* password;
    UIButton* loginButton;
    UIButton* signupButton;
    UIButton* forgotPassword;
    MBProgressHUD* loadingView;
    NSTimer* loginTimer;
}
@end

@implementation LoginViewController
SYNTHESIZE_SINGLETON_FOR_CLASS(LoginViewController)

const int loginTitleLabel_y = 88;
const int loginTitleHeight = 30;

const int textFieldViewWidth = 280;
const int textFieldViewHeight = 90;
const int textFieldView_x = 20;

const int usertextFieldWidth = 280;
const int usertextFieldHeight = 40;
const int usertextField_x = 20;

const int loginButtonWidth = 280;
const int loginButtonHeight = 20;
const int loginButton_x = 20;

const int signupButton_x = 60;
const int signupButton_y = 524;
const int signupButtonWidth = 100;
const int signupButtonHeight = 18;

const int forgotPasswordButton_x = 160;
const int forgotPasswordButton_y = signupButton_y;
const int forgotPasswordButtonWidth = signupButtonWidth;
const int forgotPasswordButtonHeight = signupButtonHeight;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = subjectColor;
        
    }
    return self;
}

//- (void) buttonClick:(id)sender
//{
//    NSLog(@"buttonClick");
//    RegisterViewController* registerView = [RegisterViewController sharedRegisterViewController];
//    [self presentViewController:registerView animated:YES completion:nil];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //nav title
    //self.navigationController.navigationBar.tintColor = CornflowerBlue;
    
    
    //init login title
    UILabel* loginTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, loginTitleLabel_y, self.view.bounds.size.width, loginTitleHeight)];
    loginTitle.text = @"车聚";
    loginTitle.textColor = [UIColor whiteColor];
    loginTitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:loginTitleHeight];
    loginTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:loginTitle];
    
    //init textfiled
    username = [[TextFieldView alloc] initWithFrame:CGRectMake(0, 5, usertextFieldWidth, usertextFieldHeight)];
    
    password = [[TextFieldView alloc] initWithFrame:CGRectMake(0, textFieldViewHeight/2+1, usertextFieldWidth, usertextFieldHeight)];
    
    username.placeholder = @"用户名/邮箱";
    password.placeholder = @"密码";
    [password setSecureTextEntry:YES];
    
    [password addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventEditingDidEndOnExit];

    
    UIView* textFieldView = [[UIView alloc] initWithFrame:CGRectMake(textFieldView_x, loginTitleLabel_y+loginTitleHeight+20, textFieldViewWidth, textFieldViewHeight)];
    
    textFieldView.layer.cornerRadius = 6;
    textFieldView.layer.masksToBounds = YES;
    textFieldView.layer.borderWidth = 0.2;
    textFieldView.layer.borderColor = [UIColor grayColor].CGColor;
    textFieldView.backgroundColor = [UIColor whiteColor];
    
    UIView* textFieldViewLine = [[UIView alloc]initWithFrame:CGRectMake(3, textFieldViewHeight/2, textFieldViewWidth-6, 0.3)];
    textFieldViewLine.backgroundColor = [UIColor grayColor];
    [textFieldView addSubview:textFieldViewLine];
    [textFieldView addSubview:username];
    [textFieldView addSubview:password];
    
    [self.view addSubview: textFieldView];
    
    //init login button
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(loginButton_x, textFieldView.frame.origin.y+textFieldView.bounds.size.height+20, loginButtonWidth, loginButtonHeight);
    
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.titleLabel.font = [UIFont systemFontOfSize: loginButtonHeight];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.showsTouchWhenHighlighted = YES;
    
    [self.view addSubview:loginButton];
    
    signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signupButton.frame = CGRectMake(signupButton_x, signupButton_y, signupButtonWidth, signupButtonHeight);
    [signupButton setTitle:@"注册账号" forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signupButton.titleLabel.font = [UIFont systemFontOfSize: signupButtonHeight];
    signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signupButton.showsTouchWhenHighlighted = YES;
    [signupButton addTarget:self action:@selector(signupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    forgotPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    forgotPassword.frame = CGRectMake(forgotPasswordButton_x, forgotPasswordButton_y, forgotPasswordButtonWidth, forgotPasswordButtonHeight);
    [forgotPassword setTitle:@"找回密码" forState:UIControlStateNormal];
    [forgotPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    forgotPassword.titleLabel.font = [UIFont systemFontOfSize: signupButtonHeight];
    forgotPassword.titleLabel.textAlignment = NSTextAlignmentCenter;
    forgotPassword.showsTouchWhenHighlighted = YES;
    [forgotPassword addTarget:self action:@selector(getBackPasswordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:forgotPassword];
    [self.view addSubview: signupButton];

    NSLog(@"load login");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
    if (![username isExclusiveTouch]&&![password isExclusiveTouch]) {
        [username resignFirstResponder];
        [password resignFirstResponder];
    }
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    NSLog(@"show nav");
//}

- (void)signupButtonAction:(id)sender
{
    NSLog(@"enter signup");
    RegisterViewController* registerViewController = [RegisterViewController sharedRegisterViewController];
    [self.navigationController pushViewController:registerViewController animated:YES];
    
}

- (void)loginButtonAction:(id)sender
{
    [username resignFirstResponder];
    [password resignFirstResponder];
    if ([username.text isEqualToString:@""]||[password.text  isEqualToString:@""]) {
        alertMsg(@"账号或密码不能为空");
        return;
    }
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    loadingView.labelText = @"正在登录...";
    [self.view addSubview:loadingView];
    //[loadingView setMode:MBProgressHUDAnimationZoom];
    
    
    [loadingView show:YES];
    
    //验证登录邮箱和密码
    dispatch_queue_attr_t loginqueue = dispatch_queue_create("loginqueue", NULL);
    dispatch_async(loginqueue, ^{
        NetWork* netWork = [[NetWork alloc] init];
        NSString* loginURLStr = [[NSString alloc] initWithFormat:@"%@%@", domainServer, @"/login"];
        
        NSURL* loginURL = [[NSURL alloc] initWithString:loginURLStr];
        NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[username.text, password.text] forKeys:@[@"email", @"password"]];
        
        
        NSMutableDictionary* feedback = [[NSMutableDictionary alloc] init];
        
        NSError* netError = [netWork sendMessageSyn:loginURL message:message feedbackMessage:&feedback];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView hide:YES];
            if (netError) {
                alertMsg(@"网络问题");
            }else{
                if ((int)[feedback objectForKey:@"code"] == 0) {
                    TabBarViewController* tabbarView = [TabBarViewController sharedTabBarViewController];
                    [self.navigationController pushViewController:tabbarView animated:YES];
                    
                }else if([[feedback objectForKey:@"code"] intValue] == 1){
                    alertMsg(@"用户名或密码错误");
                }else if([[feedback objectForKey:@"code"] intValue] == ERROR){
                    alertMsg(@"网络问题");
                }else{
                    //未知返回值
                    alertMsg(@"未知问题");
                }
            }
        });
    });
    
    NSLog(@"loginButtonAction");
}



- (void)loginTimeOut:(id)sender
{
    NSLog(@"login time out");
    [loadingView hide:YES];
    //alertMsg(@"登录超时");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



