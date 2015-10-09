//
//  SettingChildViewController.m
//  CarSocial
//
//  Created by wang jam on 9/24/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "SettingChildViewController.h"
#import "Constant.h"
#import "macro.h"
#import "UIPlaceHolderTextView.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "SettingViewController.h"

@interface SettingChildViewController ()
{
    UITextView* editView;
}
@end

@implementation SettingChildViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:[_settingTitleArray objectAtIndex:_index]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    
    editView = [[UITextView alloc] initWithFrame:CGRectMake(5, 64+10, ScreenWidth - 10, 200)];
    
    editView.layer.cornerRadius = 4.0;
    editView.layer.borderWidth = 1;
    editView.layer.borderColor = sepeartelineColor.CGColor;
    editView.text = [_settingStrArray objectAtIndex:_index];
    editView.font = [UIFont fontWithName:@"Arial" size:17];
    editView.delegate = self;
    [editView setContentOffset:CGPointZero];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editViewChanged:) name:
     UITextViewTextDidChangeNotification object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space, iOS7 (~bug?)
    
    [self.view addSubview:editView];
}

- (void)editViewChanged:(NSNotification*)notification
{
    _parent.changedFlag = true;
    NSLog(@"editViewChanged");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [_settingStrArray setObject:editView.text atIndexedSubscript:_index];
    
    //update userInfo
    if (_parent.changedFlag == true) {
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        if (_index == 0) {
            app.myInfo.career = editView.text;
        }
        if (_index == 1) {
            app.myInfo.company = editView.text;
        }
        if (_index == 2) {
            app.myInfo.sign = editView.text;
        }
        if (_index == 3) {
            app.myInfo.interest = editView.text;
        }
    }
    
    //update to server
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"setting child view delloc");
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
