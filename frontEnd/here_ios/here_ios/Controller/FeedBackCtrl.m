//
//  FeedBackCtrl.m
//  here_ios
//
//  Created by wang jam on 10/1/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "FeedBackCtrl.h"
#import "macro.h"
#import "Constant.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NetWork.h"
#import "Tools.h"
#import "AppDelegate.h"
#import "UserInfoModel.h"

@interface FeedBackCtrl ()
{
    UITextView* contentTextView;
    UILabel* placeholder;
}
@end

@implementation FeedBackCtrl


- (void)submitFeedbackSuccess:(id)sender
{
    [Tools AlertBigMsg:@"感谢您的反馈"];
}

- (void)submitFeedback:(id)sender
{
    if([contentTextView.text isEqual:@""]||contentTextView.text == nil){
        [Tools AlertBigMsg:@"反馈内容为空"];
        return;
    }
    
    MBProgressHUD* loading = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loading];
    [loading show:YES];
    
    UserInfoModel* userInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[userInfo.userID, contentTextView.text, @"/submitFeedback"] forKeys:@[@"user_id", @"feedback", @"childpath"]];
    
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(submitFeedbackSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loading hide:YES];
        [loading removeFromSuperview];
    } callObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    
    UIView* mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 210)];
    mainView.backgroundColor = [UIColor whiteColor];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, 180)];
    contentTextView.font = [UIFont fontWithName:@"Arial" size:18];
    contentTextView.textAlignment = NSTextAlignmentLeft;
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, ScreenWidth - 20, 64)];
    placeholder.text = @"简要说明下您所喜欢，或者需要改进的内容";
    placeholder.numberOfLines = 0;
    placeholder.backgroundColor = [UIColor clearColor];
    placeholder.enabled = NO;
    [contentTextView addSubview:placeholder];
    contentTextView.delegate = self;
    contentTextView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:contentTextView];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(submitFeedback:)];
    
    [self.view addSubview:mainView];
    
    [contentTextView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        placeholder.text = @"简要说明下你所喜欢，或者需要改进的内容";
    }else{
        placeholder.text = @"";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
