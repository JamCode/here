//
//  RegisterNickNameViewController.m
//  CarSocial
//
//  Created by wang jam on 8/29/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "RegisterNickNameViewController.h"
#import "TextFieldView.h"
#import "Constant.h"
#import "RegisterUserInfoViewController.h"
#import "UserInfoModel.h"
#import "Tools.h"
#import "NetWork.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "macro.h"
#import "RegisterPhoneNumViewController.h"
#import <Masonry.h>
#import "EULAViewController.h"

@interface RegisterNickNameViewController ()
{
    TextFieldView* textField;
    UILabel* noticeLabel;
}
@end

@implementation RegisterNickNameViewController

static const int textview_x = 0;
static const int textview_y = 28;
static const int textview_height = 44;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userInfo = [[UserInfoModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"输入名称"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep:)];
    
    UIView* textfieldBack = [[UIView alloc] initWithFrame:CGRectMake(textview_x, textview_y, ScreenWidth, textview_height)];
    textfieldBack.backgroundColor = [UIColor whiteColor];
    
    textField = [[TextFieldView alloc] initWithFrame:CGRectMake(30, 0, ScreenWidth-30, textview_height)];
    textField.placeholder = @"请输入名称";
    [textfieldBack addSubview:textField];
    
    UIImageView* nickNameIcon = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 5, 32, 32)];
    nickNameIcon.image = [UIImage imageNamed:@"nickname64px.png"];
    
    [textfieldBack addSubview:nickNameIcon];
    
    [self.view addSubview:textfieldBack];
    
    
    noticeLabel = [[UILabel alloc] init];
    
    
    [self.view addSubview:noticeLabel];
    noticeLabel.textColor = subjectColor;
    noticeLabel.text = @"注册即表示同意《小马达用户协议》";
    noticeLabel.font = [UIFont fontWithName:@"Arial" size:12];
    noticeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noticeLabel.numberOfLines = 0;
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.userInteractionEnabled = YES;
    [noticeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickNotice:)]];
    
    
}

- (void)clickNotice:(id)sender
{
    NSLog(@"clickNotice");
    
    
    EULAViewController* eula = [[EULAViewController alloc] init];
    
    [self.navigationController pushViewController:eula animated:YES];
}

- (void)nextStep:(id)sender
{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (textField.text.length==0||textField.text==nil) {
        
        [Tools AlertBigMsg:@"名字不能为空"];
        return;
    }
    
    [textField resignFirstResponder];
    
    //验证名字
    MBProgressHUD* loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[textField.text, @"/checkNameExist"] forKeys:@[@"user_name", @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(userNameExist:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(userNameNotExist:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:USER_EXIST],[[NSNumber alloc] initWithInt:USER_NOT_EXIST]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
    } callObject:self];
}

- (void)userNameNotExist:(id)sender
{
    _userInfo.nickName = textField.text;
    
    RegisterPhoneNumViewController* registerPhoneInfo = [[RegisterPhoneNumViewController alloc] init];
    registerPhoneInfo.userInfo = _userInfo;
    
    [self.navigationController pushViewController:registerPhoneInfo animated:YES];
}


- (void)userNameExist:(id)sender
{
    [Tools AlertBigMsg:@"名称已被注册"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
    
    
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(textField.mas_bottom).offset(2*minSpace);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth - 2*minSpace, 2*minSpace));
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"registernickname delloc");
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
