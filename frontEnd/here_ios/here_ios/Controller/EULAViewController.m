//
//  EULAViewController.m
//  here_ios
//
//  Created by wang jam on 2/12/16.
//  Copyright © 2016 jam wang. All rights reserved.
//

#import "EULAViewController.h"
#import "macro.h"
#import "Constant.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>

@interface EULAViewController ()
{
    NJKWebViewProgress* progressProxy;
    NJKWebViewProgressView* progressView;
}
@end

@implementation EULAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"用户协议"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;

    
    self.view.backgroundColor = [UIColor whiteColor];
    

    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
    webView.backgroundColor = [UIColor whiteColor];
    webView.scalesPageToFit = YES;
    
    NSURL* url = [NSURL URLWithString:@"http://123.57.229.67:10808/eula"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [webView loadRequest:request];//加载
    
    progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = progressProxy;
    progressProxy.webViewProxyDelegate = self;
    progressProxy.progressDelegate = self;
    
    [self.view addSubview:webView];
    
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.navigationController.navigationBar addSubview:progressView];
    
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [progressView setProgress:progress animated:NO];
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
