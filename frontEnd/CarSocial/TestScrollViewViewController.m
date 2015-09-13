//
//  TestScrollViewViewController.m
//  CarSocial
//
//  Created by wang jam on 8/22/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "TestScrollViewViewController.h"
#import "Constant.h"
#import "ContentTableViewCell.h"

@interface TestScrollViewViewController ()
{
    UIScrollView* mainScrollView;
}
@end

@implementation TestScrollViewViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    mainScrollView.contentSize = CGSizeMake(ScreenWidth, 0);
    [mainScrollView setPagingEnabled:NO];
    
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    mainScrollView.delegate = self;
    
    [self.view addSubview:mainScrollView];

    
    
    for (int i=0; i<6; ++i) {
        ContentTableViewCell* activeView = [[ContentTableViewCell alloc] initWithFrame:CGRectMake(10, 15+mainScrollView.contentSize.height, ScreenWidth-2*10, 250)];
        
        [mainScrollView addSubview:activeView];
        mainScrollView.contentSize = CGSizeMake(ScreenWidth, activeView.frame.size.height+mainScrollView.contentSize.height+10);
    }
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
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
