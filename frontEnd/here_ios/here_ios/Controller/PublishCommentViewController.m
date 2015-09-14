//
//  PublishCommentViewController.m
//  CarSocial
//
//  Created by wang jam on 12/28/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "PublishCommentViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NetWork.h"
#import "macro.h"

@interface PublishCommentViewController ()
{
    UserInfoModel* myInfo;
    UITextView* textView;
    UILabel* placeholder;
    MBProgressHUD* loadingView;
    MBProgressHUD* feedbackTextView;
}
@end

@implementation PublishCommentViewController

- (void)CancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publishButton:(id)sender
{
    NSString* text = textView.text;
    if ([text isEqualToString:@""]||text == nil) {
        return;
    }
    
    [textView resignFirstResponder];
    [loadingView show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserInfoModel* myUserInfo = app.myInfo;
    
    
    if (_toCommentUser.userID == nil) {
        _toCommentUser = _contentModel.userInfo;
    }
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_contentModel.contentID, myUserInfo.userID, myUserInfo.nickName, _toCommentUser.userID, text, [[NSNumber alloc] initWithInt:_contentModel.to_content], @"/addCommentToContent"] forKeys:@[@"content_id", @"user_id", @"user_name", @"to_user_id", @"comment", @"to_content", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addCommentSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(msgError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(msgException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
    } callObject:self];
}



- (void)msgException:(id)sender
{
    alertMsg(@"msg exception");
}

- (void)msgError:(id)sender
{
    alertMsg(@"msg error");
}

- (void)addCommentSuccess:(id)sender
{
    feedbackTextView.labelText = @"评论成功";
    [feedbackTextView show:YES];
    [feedbackTextView hide:YES afterDelay:1.0];
}


- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud == feedbackTextView) {
        [self dismissViewControllerAnimated:YES completion:^{
            //[_contentDetail addCommentSuccess:nil];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    UIBarButtonItem *leftitem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(CancelButton:)];
    
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publishButton:)];
    
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:nil];
    navigationBarTitle.leftBarButtonItem = leftitem;
    navigationBarTitle.rightBarButtonItem = rightitem;
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    myInfo = app.myInfo;
    
    
    [navigationBar setItems:[NSArray arrayWithObject: navigationBarTitle]];
    navigationBar.backgroundColor = [UIColor blackColor];
    navigationBar.barTintColor = [UIColor blackColor];
    navigationBar.tintColor = [UIColor whiteColor];
    
    [self.view addSubview: navigationBar];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.origin.y+navigationBar.frame.size.height, ScreenWidth, ScreenHeight/3)];
    textView.font = [UIFont fontWithName:@"Arial" size:18];
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 120, 32)];
    placeholder.text = @"写下你的评论";
    placeholder.backgroundColor = [UIColor clearColor];
    placeholder.enabled = NO;
    [textView addSubview:placeholder];
    textView.delegate = self;
    
    
    
    textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:textView];
    [textView becomeFirstResponder];
    
    
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView hide:YES];
    
    feedbackTextView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:feedbackTextView];
    feedbackTextView.mode = MBProgressHUDModeText;
    [feedbackTextView hide:YES];
    
    feedbackTextView.delegate = self;
    
}

- (void)textViewDidChange:(UITextView *)textViewed
{
    if (textViewed.text.length == 0) {
        placeholder.text = @"写下你的评论";
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
