//
//  StartViewController.m
//  CarSocial
//
//  Created by wang jam on 8/28/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "StartViewController.h"
#import "RegisterNickNameViewController.h"
#import "SignInViewController.h"
#import "macro.h"
#import "Constant.h"
#import "Tools.h"

@interface StartViewController ()

@end

@implementation StartViewController

//static const int button_x = 58;

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
    
    NSString* deviceModel = [Tools getCurrentDeviceModel];
    UIImageView* backgroundImage;
    if([deviceModel isEqualToString:@"iPhone6"]){
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waitPage6.png"]];
    }
    
    else if ([deviceModel isEqualToString:@"iPhone6Plus"]) {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waitPage6p.png"]];
    }else{
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waitPage5.png"]];
    }
    
    
    backgroundImage.userInteractionEnabled = YES;
    backgroundImage.frame = self.view.frame;
    
    UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - ScreenHeight/10, ScreenWidth/2, ScreenHeight/10)];
    registerButton.userInteractionEnabled = YES;
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton* loginButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, registerButton.frame.origin.y, registerButton.frame.size.width, registerButton.frame.size.height)];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    
    
    [backgroundImage addSubview:registerButton];
    [backgroundImage addSubview:loginButton];
    
    [self.view insertSubview:backgroundImage atIndex:0];
    
}

- (void)loginButtonAction:(id)sender
{
    NSLog(@"enter registerButtonAction");
    SignInViewController* signinView = [[SignInViewController alloc] init];
    [self.navigationController pushViewController:signinView animated:YES];
}

- (void)registerButtonAction:(id)sender
{
    NSLog(@"enter registerButtonAction");
    RegisterNickNameViewController* firstRegister = [[RegisterNickNameViewController alloc] init];
    [self.navigationController pushViewController:firstRegister animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"start view delloc");
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
