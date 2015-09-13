//
//  TabBarViewController.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "TabBarViewController.h"
#import "Constant.h"
#import "ContentViewController.h"
#import "NearByPersonAction.h"
#import "MessageTableViewController.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import "Tools.h"
#import "TWTSideMenuViewController.h"
#import "MenuViewCtrl.h"
#import "NearByContentAction.h"
#import "ComTableViewCtrl.h"


@interface TabBarViewController ()
{
    CLLocationManager* locationManager;
    NSMutableArray *controllers;
}
@end

@implementation TabBarViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)initChildView:(NSMutableArray*)navcontrollers viewController:(UIViewController*) viewController title:(NSString*)title
{
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    nav.navigationBar.barTintColor = [UIColor blackColor];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    //self.tabBar.barTintColor = subjectColor;
    nav.title = title;
    [navcontrollers addObject:nav];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    self.tabBar.barTintColor = [UIColor clearColor];
    self.tabBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self initControllerViews];
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if((self.selectedIndex == 0&&item.tag == 0)
       ||(self.selectedIndex == 1&&item.tag == 1)){
        //double click to refresh
        NSLog(@"%ld", item.tag);
        UINavigationController* nav = [self.viewControllers objectAtIndex:self.selectedIndex];
        
        if([nav.topViewController isKindOfClass:[ComTableViewCtrl class]]){
            ComTableViewCtrl* comTable = (ComTableViewCtrl*)nav.topViewController;
            [comTable refreshNew];
        }
    }
}

- (void)initControllerViews
{
    if(controllers != nil){
        return;
    }
    
    
    controllers = [NSMutableArray array];
    
    
    ComTableViewCtrl* comTableViewCtrl = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[NearByContentAction alloc] init]];
    
    
    ContentViewController* popularView = [[ContentViewController alloc] init:@"热门" publishButtonFlag:NO setLoadingAction:@selector(getPopularContent) content_user_id:nil];
    
    
    MessageTableViewController* message = [[MessageTableViewController alloc] init];
    [message viewDidLoad];
    [message checkMissedMsg];
    
    SettingViewController* setting = [[SettingViewController alloc] init:[AppDelegate getMyUserInfo]];
    
    [self initChildView:controllers viewController:comTableViewCtrl title:@"附近"];
    [self initChildView:controllers viewController:popularView title:@"热门"];
    [self initChildView:controllers viewController:message title:@"消息"];
    [self initChildView:controllers viewController:setting title:@"设置"];
    
    
    self.viewControllers = controllers;
    
    UITabBarItem *tabItem = [[self.tabBar items] objectAtIndex:0];
    UIImage* image = [UIImage imageNamed:@"nearbylocation.png"];
    [tabItem setImage:image];
    tabItem.tag = 0;
    
    
    //[tabItem setTitle:@"活动"]
    
    tabItem = [[self.tabBar items] objectAtIndex:1];
    image = [UIImage imageNamed:@"hot.png"];
    [tabItem setImage:image];
    tabItem.tag = 1;
    
    //tabItem
    //[tabItem setTitle:@"附近"]
    
    tabItem = [[self.tabBar items] objectAtIndex:2];
    image = [UIImage imageNamed:@"message.png"];
    
    [tabItem setImage:image];
    tabItem.tag = 2;
    //[tabItem setTitle:@"消息"]
    
    tabItem = [[self.tabBar items] objectAtIndex:3];
    image = [UIImage imageNamed:@"setting.png"];
    [tabItem setImage:image];
    tabItem.tag = 3;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"tabbarview delloc");
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
