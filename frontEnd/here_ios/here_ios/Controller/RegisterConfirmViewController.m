//
//  RegisterConfirmViewController.m
//  CarSocial
//
//  Created by wang jam on 8/30/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "RegisterConfirmViewController.h"
#import "Constant.h"
#import "TextFieldView.h"
#import <MBProgressHUD.h>
#import "NetWork.h"
#import "macro.h"
#import "TabBarViewController.h"
#import "AppDelegate.h"
#import "CocoaSecurity.h"
#import "Tools.h"

@interface RegisterConfirmViewController ()
{
    int sec;
    UIButton* resendButton;
    NSTimer* timer;
    TextFieldView* confirmTextField;
    MBProgressHUD* loadingView;
}
@end

@implementation RegisterConfirmViewController

static const int notice_x = 10;
static const int notice_y = 20;
static const int notice_height = 18;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userInfo = [[UserInfoModel alloc] init];
        sec = 60;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"验证手机"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep:)];
    
    UILabel* noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(notice_x, notice_y, ScreenWidth - 2*notice_x, notice_height)];
    noticeLabel.textColor = [UIColor grayColor];
    noticeLabel.text = [[NSString alloc] initWithFormat:@"%@%@", @"验证码短信已发送到: +86 ", _userInfo.phoneNum];
    noticeLabel.font = [UIFont fontWithName:@"Arial" size:14];
    [self.view addSubview:noticeLabel];
    
    
    
    UIView* textFieldBack = [[UIView alloc] initWithFrame:CGRectMake(0, noticeLabel.frame.origin.y+noticeLabel.frame.size.height+10, ScreenWidth, 44)];
    textFieldBack.backgroundColor = [UIColor whiteColor];
    
    confirmTextField = [[TextFieldView alloc] initWithFrame:CGRectMake(30, 0, ScreenWidth-30, 44)];
    confirmTextField.placeholder = @"请输入验证码";
    [textFieldBack addSubview:confirmTextField];
    
    UIImageView* nickNameIcon = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 5, 32, 32)];
    nickNameIcon.image = [UIImage imageNamed:@"earth64px.png"];
    [textFieldBack addSubview:nickNameIcon];
    
    [self.view addSubview:textFieldBack];
    
    //重发验证码
    resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resendButton.frame = CGRectMake(10, textFieldBack.frame.origin.y+textFieldBack.frame.size.height+20, ScreenWidth - 2*10, 44);
    resendButton.backgroundColor = sepeartelineColor;
    resendButton.layer.cornerRadius = 6;
    [resendButton setEnabled:NO];
    
    [resendButton setTitle:[[NSString alloc] initWithFormat:@"重发验证码(%d)", sec] forState:UIControlStateNormal];
    [resendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [resendButton addTarget:self action:@selector(resendConfirmNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resendButton];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeInvoke:) userInfo:nil repeats:YES];
}

- (void)timeInvoke:(id)sender
{
    if (sec>0) {
        sec = sec-1;
        
        resendButton.titleLabel.text = [[NSString alloc] initWithFormat:@"重发验证码(%d)", sec];
    }else{
        [resendButton setEnabled:YES];
        resendButton.titleLabel.text = [[NSString alloc] initWithFormat:@"重发验证码"];
        resendButton.backgroundColor = subjectColor;
        [timer invalidate];
    }
    NSLog(@"timeInvoke");
}

- (void)resendConfirmNum:(id)sender
{
    sec = 60;
    resendButton.titleLabel.text = [[NSString alloc] initWithFormat:@"重发验证码(%d)", sec];
    resendButton.backgroundColor = sepeartelineColor;
    [resendButton setEnabled:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeInvoke:) userInfo:nil repeats:YES];
    
    
    //异步获取手机验证码
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.phoneNum, @"/confirmPhone"] forKeys:@[@"user_phone", @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(certificateCodeSend:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(phoneExist:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(CertificateCodeSended:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(certificateError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(certificateException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:CERTIFICATE_CODE_SEND],[[NSNumber alloc] initWithInt:PHONE_EXIST],[[NSNumber alloc] initWithInt:CERTIFICATE_CODE_SENDED],[[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}

- (void)CertificateCodeSended:(id)sender
{
    alertMsg(@"验证码已发送,请等待");
}

- (void)phoneExist:(id)sender
{
    alertMsg(@"电话号码已被注册");
}

- (void)certificateCodeSend:(id)sender
{
    alertMsg(@"验证码已发送");
}

- (void)certificateError:(id)sender
{
    alertMsg(@"网络问题");
}

- (void)certificateException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)nextStep:(id)sender
{
    [confirmTextField resignFirstResponder];
    confirmTextField.text = [confirmTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (confirmTextField.text.length==0||confirmTextField.text == nil) {
        alertMsg(@"验证码不能为空");
        return;
    }
    
    _userInfo.certificateNo = confirmTextField.text;
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    
    CocoaSecurityResult* encodePassword = [CocoaSecurity md5:_userInfo.password];
    _userInfo.password = encodePassword.hexLower;
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.phoneNum, _userInfo.certificateNo, _userInfo.nickName, _userInfo.password, [NSNumber numberWithInteger:_userInfo.age], [NSNumber numberWithInteger:_userInfo.gender], _userInfo.birthday, @"/register"] forKeys:@[@"user_phone", @"user_certificate_code", @"user_name", @"user_password", @"user_age", @"user_gender", @"user_birth_day", @"childpath"]];
    
    NSDictionary* images = [[NSDictionary alloc] initWithObjects:@[_userInfo.faceImage] forKeys:@[@"user_facethumbnail"]];
    
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(registerSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(registerFail:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(certificateNotMatch:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(registerException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:REGISTER_SUCCESS],[[NSNumber alloc] initWithInt:REGISTER_FAIL],[[NSNumber alloc] initWithInt:CERTIFICATE_CODE_NOT_MATCH],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:images feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
    } callObject:self];
}

- (void)certificateNotMatch:(id)sender
{
    [Tools AlertBigMsg:@"验证码错误"];
}

- (void)registerException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)registerFail:(id)sender
{
    alertMsg(@"注册失败");
}

- (void)registerError:(id)sender
{
    alertMsg(@"网络问题");
}

- (void)registerSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.myInfo fillWithData:feedback];
    
    NSUserDefaults *mySettingData = [NSUserDefaults standardUserDefaults];
    [mySettingData setObject:app.myInfo.phoneNum forKey:@"phone"];
    [mySettingData setObject:app.myInfo.password forKey:@"password"];
    [mySettingData synchronize];
    
    
    TabBarViewController* tabbarView = [[TabBarViewController alloc] init];
    [self presentViewController:tabbarView animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"registerconfirm delloc");
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
