//
//  ActiveViewController.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "ContentViewController.h"
#import<MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Constant.h"
#import "PublishContentViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "NetWork.h"
#import "macro.h"
#import "Tools.h"
#import "MenuViewCtrl.h"
#import "ContentTableViewCell.h"
#import "Constant.h"
#import "CommentModel.h"
#import "ContentDetailViewController.h"

//#import "UITabBarController+ShowHideBar.h"


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface ContentViewController ()
{
    MBProgressHUD* loadingView;
    //EGORefreshTableHeaderView *refreshTableHeaderView;
    BOOL reloading;
    NSMutableArray* contentModeArray;
    //NSMutableArray* contentViewArray;
    CLLocationManager* locationManager;
    SEL loadingAction;
    NSString* navtitle;
    BOOL publishButtonFlag;
    //BOOL isScrollFlag;
    NSInteger offset;
    UIActivityIndicatorView* bottomActive;
    UIButton* leftBar;
    UILabel* noticelabel;
    
    NSString* my_content_user_id;
    
    int locationTryCount;
    
    BOOL noMoreHisNews;
    
    CGFloat startContentOffsetY;
    
    
    BOOL tabbarHidden;
    
    UITextView* commentInputView;
    UIToolbar* bottomToolbar;
    
    ContentTableViewCell* selectedCommentCell;
    
    //UIRefreshControl* refreshControl;
        

}
@end

@implementation ContentViewController

static const int noticeLabelHeight = 10;
static const int leftbarWidth = 20;

static const int inputfontSize = 16;
static const double textViewHeight = 36;
static const double bottomToolbarHeight = 48;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        locationTryCount = 0;
        _faceImageDic = [[NSMutableDictionary alloc] init];
        noMoreHisNews = false;
    }
    return self;
}

- (id)init:(NSString*)title publishButtonFlag:(BOOL)flag setLoadingAction:(SEL)action content_user_id:(NSString*)content_user_id
{
    if (self = [super init]) {
        navtitle = title;
        publishButtonFlag = flag;
        loadingAction = action;
        my_content_user_id = content_user_id;
    }
    return self;
}


- (void)initNav
{
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:navtitle];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    if (publishButtonFlag == true) {
        UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBar.frame = CGRectMake(0, 0, 24, 24);
        [rightBar setBackgroundImage:[UIImage imageNamed:@"publishActivity48.png"] forState:UIControlStateNormal];
        [rightBar addTarget:self action:@selector(publishActivity:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
        self.navigationItem.rightBarButtonItem = rightitem;
        
        
        leftBar = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBar.frame = CGRectMake(0, 0, leftbarWidth, leftbarWidth);
        [leftBar setBackgroundImage:[UIImage imageNamed:@"info-icon.png"] forState:UIControlStateNormal];
        
        [leftBar addTarget:self action:@selector(openButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBar];
    }
}

//set to red notice
- (void)setLeftBarNotice
{
    if (noticelabel != nil) {
        [noticelabel removeFromSuperview];
    }
    
    noticelabel = [[UILabel alloc] initWithFrame:CGRectMake(leftbarWidth -noticeLabelHeight/2, -noticeLabelHeight/2, noticeLabelHeight, noticeLabelHeight)];
    
    noticelabel.backgroundColor = [UIColor redColor];
    noticelabel.layer.cornerRadius = noticeLabelHeight/2;
    noticelabel.layer.masksToBounds = YES;
    [leftBar addSubview:noticelabel];
}

- (void)removeLeftBarNotice
{
    if (noticelabel != nil) {
        [noticelabel removeFromSuperview];
    }
}


- (void)openButtonPressed
{
    NSLog(@"openButtonPressed");
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    [(MenuViewCtrl*)app.sideMenu.menuViewController getUnreadNoticeMsgCount];
    [app.sideMenu openMenuAnimated:YES completion:nil];
    
}

- (void)refreshNewInfo:(id)sender
{
    if (reloading == YES) {
        return;
    }
    
    NSLog(@"refreshNewInfo");
    
    reloading = YES;
    if ([contentModeArray count] == 0) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    }else{
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力加载中..."];
    }
    
    if (loadingAction == @selector(getNearbyContent)) {
        locationTryCount = 0;
        [Tools startLocation:locationManager];
    }else{
        [self performSelector:loadingAction withObject:nil];
    }
}

- (void)initRefreshAndLoading
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshNewInfo:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
    
    //[self setRefreshControl:refreshControl];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    reloading = NO;
    
    
    contentModeArray = [[NSMutableArray alloc] init];
    [self initNav];
    
    if (loadingAction == @selector(getNearbyContent)) {
        
        //获取用户地理信息
        locationManager = [[CLLocationManager alloc] init];
        if ([CLLocationManager locationServicesEnabled] == false) {
            alertMsg(@"定位服务无法使用");
            return;
        }
        
        [locationManager setDelegate:self];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 5.0f;
        
        //注册右滑动事件
        UISwipeGestureRecognizer *swapRight = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(openButtonPressed)];
        swapRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swapRight];
        
        //注册左滑动事件
        UISwipeGestureRecognizer *swapLeft = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(closeButtonPressed)];
        swapLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swapLeft];
    }
    
    
    
    [self initRefreshAndLoading];
    offset = 0;
    
    
    //self.tableView.separatorStyle = NO;
    
    UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    [self.tableView setTableFooterView:bottomView];
    
    
    //[self setBottomTitle:@"上拉加载更多"];
    
    
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
    
    //[self setLeftBarNotice];
    
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    [self initCommentInputView];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setBottomTitle:(NSString*)title
{
    UILabel* bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    bottomLabel.text = title;
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.textColor = [UIColor grayColor];
    
    for (UIView* view in self.tableView.tableFooterView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.tableView.tableFooterView addSubview:bottomLabel];
    
}


- (void)setBottomActive
{
    bottomActive = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    bottomActive.frame = CGRectMake((ScreenWidth - 30)/2, (self.tableView.tableFooterView.frame.size.height - 30)/2, 30, 30);
    [bottomActive setColor:[UIColor grayColor]];
    
    //[bottomActive setCenter:CGPointMake(200, 15)];//指定进度轮中心点
    [bottomActive hidesWhenStopped];
    
    for (UIView* view in self.tableView.tableFooterView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.tableView.tableFooterView addSubview:bottomActive];
}

- (void)closeButtonPressed
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.sideMenu closeMenuAnimated:YES completion:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    startContentOffsetY = scrollView.contentOffset.y;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    
    [commentInputView resignFirstResponder];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //isScrollFlag = false;
    
    
    
}

- (void)checkUnreadMsgSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSInteger count = [[feedback objectForKey:@"data"] integerValue];
    if (count > 0) {
        [self setLeftBarNotice];
    }else{
        [self removeLeftBarNotice];
    }
}

- (void)checkUnreadMsgError:(id)sender
{
    NSLog(@"checkUnreadMsgError");
}

- (void)checkUnreadMsgException:(id)sender
{
    NSLog(@"checkUnreadMsgException");
}

- (void)checkUnreadMsg
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, @"/getNoticeMsgCount"] forKeys:@[@"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(checkUnreadMsgSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(checkUnreadMsgError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(checkUnreadMsgException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        ;
    } callObject:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (loadingAction == @selector(getNearbyContent)) {
        //check unread msg
        [self checkUnreadMsg];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
    
    if ([contentModeArray count] == 0) {
        
        [self.refreshControl endRefreshing];
        
    }else{
        //[self.refreshControl endRefreshing];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //keyboardHeight = 0;
    
    //CGRect btnFrame = talkTableView.frame;
    CGRect bottomFrame = bottomToolbar.frame;
    //btnFrame.origin.y = 0;
    bottomFrame.origin.y = ScreenHeight;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    bottomToolbar.frame = bottomFrame;
    bottomToolbar.hidden = YES;
    
    // commit animations
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    commentInputView.text = @"";
    
    NSLog(@"keyboardWillShow");
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    //CGFloat keyboardHeight = keyboardBounds.size.height;
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect bottomFrame = bottomToolbar.frame;
    
    
    bottomFrame.origin.y =  ScreenHeight - keyboardBounds.size.height - bottomToolbarHeight;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    bottomToolbar.frame = bottomFrame;
    bottomToolbar.hidden = NO;
    // commit animations
    [UIView commitAnimations];
    

}

- (BOOL)tabbarHidden
{
    return tabbarHidden;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    
    CGPoint off = scrollView.contentOffset;
    
    CGRect bounds = scrollView.bounds;
    
    CGSize size = scrollView.contentSize;
    
    CGFloat currentOffset = off.y + bounds.size.height;
    
    CGFloat maximumOffset = size.height;
    
    //当currentOffset与maximumOffset的值相等时，说明scrollview已经滑到底部了。也可以根据这两个值的差来让他做点其他的什么事情
    
    if ([bottomActive isAnimating]) {
        return;
    }
    
    if((maximumOffset - currentOffset)<-40.0&&maximumOffset>bounds.size.height
       &&![bottomActive isAnimating]
       &&noMoreHisNews==false){
        
        NSLog(@"-----我要刷新数据-----");
        NSLog(@"%f", self.tableView.tableFooterView.center.x);
        NSLog(@"%f", self.tableView.tableFooterView.center.y);

        
        [self setBottomActive];
        
        if (loadingAction == @selector(getNearbyContent)) {
            [bottomActive startAnimating];

            [self getNearbyContentHis];
        }
        
        else if (loadingAction == @selector(getPopularContent)) {
            
            [bottomActive startAnimating];

            [self getPopularContentHis];
        }
        
        else if (loadingAction == @selector(getMyContent)) {
            [bottomActive startAnimating];
            
            [self getMyContentHis];
        }else{
//            mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, mainScroll.contentSize.height - bottomActive.frame.size.height - activeViewUpBottomDistance - 64);
//            [bottomActive stopAnimating];
//            [bottomActive removeFromSuperview];
            
            //[bottomActive stopAnimating];
        }
    }
    
    
    if (off.y - startContentOffsetY>10) {
        //NSLog(@"向下滑动");
        
//        if (tabbarHidden == YES) {
//            return;
//        }
//        
//        
//        [self hiddenTabbarAndNavBar];
        
        //self.navigationController.view.hidden = YES;
        
        //self.tabBarController.view.backgroundColor = [UIColor clearColor];
        
        //[self.tabBarController.tabBar setHidden:YES];
    }else{
        //NSLog(@"向上滑动");

    }
}

//- (void)showTabbarAndNavBar
//{
//    [self.tabBarController setHidden:NO];
//    tabbarHidden = NO;
//    [UIView animateWithDuration:0.25 animations:^{
//        self.navigationController.navigationBar.alpha = 1;
//        self.tableView.contentInset = UIEdgeInsetsMake(0, self.tableView.contentInset.left, 0, self.tableView.contentInset.right);
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, 64, ScreenWidth, ScreenHeight - self.tabBarController.tabBar.frame.size.height);
//        
//    } completion:^(BOOL finished) {
//        if (finished == true) {
//            
//            [UIView animateWithDuration:0.25 animations:^{
//                
//                
//            }];
//        }
//    }];
//}

//- (void)hiddenTabbarAndNavBar
//{   
//    [self.tabBarController setHidden:YES];
//    tabbarHidden = YES;
//    [UIView animateWithDuration:0.25 animations:^{
//        self.navigationController.navigationBar.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished == true) {
//            [UIView animateWithDuration:0.25 animations:^{
//                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, 0, ScreenWidth, ScreenHeight);
//                self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, 64, self.tableView.contentInset.right);
//            }];
//        }
//    }];
//}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    
    
    if (error.code == kCLErrorDenied) {
        alertMsg(@"应用无权限使用地理位置功能");
        [self doneLoadingTableViewData];
        [self.tableView reloadData];
        [locationManager stopUpdatingLocation];
        return;
    }
    
    
    ++locationTryCount;
    if (locationTryCount>totalLocationTryCount) {
        alertMsg(@"无法获取地理位置信息可能导致相关功能不可用");
        [locationManager stopUpdatingLocation];
    }
    
    return;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    isScrollFlag = true;
//}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 滑動完成時觸發
    // 經由 setContentOffset:animated: 滑動完成才會喔
    // 如果是手動滑的不會觸發
    
    if ([scrollView isKindOfClass:[self.tableView class]]) {
        if (scrollView.contentOffset.y<0) {
            [self.refreshControl beginRefreshing];
            [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];

        }
    }
}

- (void)refreshNews
{
//    if (self.refreshControl.refreshing == true) {
//        return;
//    }
    
    
    NSLog(@"%f", self.refreshControl.frame.size.height);
    
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height - 44) animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations");
    
    [locationManager stopUpdatingLocation];
    
    
    CLLocation* newLocation = [locations lastObject];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
//    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
//    NSLog(@"%ld", nowTime);
//    NSLog(@"%ld", app.myInfo.locationTime);
//    
//    if (nowTime - app.myInfo.locationTime<2) {
//        //[self doneLoadingTableViewData];
//        return;
//    }
    
    app.myInfo.latitude = newLocation.coordinate.latitude;
    app.myInfo.longitude = newLocation.coordinate.longitude;
    app.myInfo.locationTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"location update");
    //send new location to server
    NSDictionary* message = [[NSDictionary alloc]initWithObjects:@[app.myInfo.userID,[NSNumber numberWithDouble:app.myInfo.latitude],[NSNumber numberWithDouble:app.myInfo.longitude], @"/updateLocation"]forKeys:@[@"user_id", @"latitude", @"longitude", @"childpath"]];
    
    
    NetWork* netWork = [[NetWork alloc] init];
        [netWork message:message images:nil feedbackcall:nil complete:^{
    } callObject:self];
    
  
    
    [self performSelector:loadingAction withObject:nil];
    
}

//- (void)getMyContentSuccess:(id)sender
//{
//    NSDictionary* feedback = (NSDictionary*)sender;
//    
//    NSArray* contents = [feedback objectForKey:@"contents"];
//    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    UserInfoModel* myinfo = app.myInfo;
//    
//    
//    [contentModeArray removeAllObjects];
//    [self removeAllViews:mainScroll.subviews];
//    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, refreshTableHeaderView.frame.size.height);
//    offset = [contents count];
//    
//    
//    for (NSDictionary* element in contents) {
//        ContentModel* contentMode = [[ContentModel alloc] init];
//        [contentMode setContentModel:element];
//        
//        CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myinfo.latitude longitude:myinfo.longitude];
//        CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:contentMode.latitude longitude:contentMode.longitude];
//        CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
//        contentMode.distanceMeters = meters;
//        
//        [contentModeArray addObject:contentMode];
//        
//        ContentView* contentView = [[ContentView alloc] initWithFrame:CGRectMake(0, activeViewUpBottomDistance+mainScroll.contentSize.height, ScreenWidth, [ContentView getTotalHeight:contentMode maxContentHeight:ScreenHeight/2])];
//        
//        contentView.parentViewController = self;
//        [contentView setContentModel:contentMode];
//        
//        mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, mainScroll.contentSize.height+contentView.frame.size.height+activeViewUpBottomDistance);
//        
//        [mainScroll addSubview:contentView];
//    }
//    
//    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, mainScroll.contentSize.height+64);
//    [mainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
//}

- (void)getMyContent
{
    //异步注册信息
    UserInfoModel* myinfo = [AppDelegate getMyUserInfo];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSNumber* lasttimestamp;
    if ([contentModeArray count]>0) {
        ContentModel* contentModel = [contentModeArray firstObject];
        lasttimestamp = [NSNumber numberWithInteger:contentModel.publishTimeStamp];
    }else{
        lasttimestamp = [NSNumber numberWithInteger:0];
    }

    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[lasttimestamp, my_content_user_id, myinfo.userID, @"/getContentByUser"] forKeys:@[@"last_timestamp", @"user_id", @"my_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } callObject:self];
}

- (void)getMyContentByCity
{
    //异步注册信息
    UserInfoModel* myinfo = [AppDelegate getMyUserInfo];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]], my_content_user_id, myinfo.userID, _city_desc, @"/getMyContentByCity"] forKeys:@[@"last_timestamp", @"user_id", @"my_user_id", @"city_desc", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } callObject:self];
}


- (void)getMyContentHis
{
    //异步注册信息
    UserInfoModel* myinfo = [AppDelegate getMyUserInfo];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    ContentModel* lastContent = [contentModeArray lastObject];
    int lastTimeStamp = [[NSDate date] timeIntervalSince1970];
    
    if (lastContent != nil) {
        lastTimeStamp = (int)lastContent.publishTimeStamp;
    }
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInt:lastTimeStamp], my_content_user_id, myinfo.userID, @"/getHisContentByUser"] forKeys:@[@"last_timestamp", @"user_id", @"my_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccessHis:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } callObject:self];
}


- (void)viewDidAppear:(BOOL)animated
{
    
}


- (void)publishActivity:(id)sender
{
    NSLog(@"publishActivity");
    
    
    PublishContentViewController* publish = [[PublishContentViewController alloc] init];
    publish.contentViewController = self;
    [self presentViewController:publish animated:YES completion:nil];
    //[self.navigationController pushViewController:publish animated:YES];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"contentview didReceiveMemoryWarning");
    
    if ([self isViewLoaded] && [self.view window] == nil) {
        
        [contentModeArray removeAllObjects];
        contentModeArray = nil;
        self.tableView = nil;
    }
}

- (void)doneLoadingTableViewData{
    
    [bottomActive stopAnimating];
    [bottomActive removeFromSuperview];
    
    //model should call this when its done loading
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多"];
    
    reloading = NO;
    
    
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    isScrollFlag = false;
//}


- (BOOL)isScroll
{
    return true;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y - startContentOffsetY<-10) {
        
//        if (tabbarHidden == NO) {
//            return;
//        }
//        
//        [self showTabbarAndNavBar];
    }
}


- (void)getPopularContentHis
{
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    NSNumber* lasttimestamp =  [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970] - 3*3600*24];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[lasttimestamp, [[NSNumber alloc] initWithInteger:offset], @"/getPopularContent"] forKeys:@[@"last_timestamp", @"offset", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccessHis:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } callObject:self];
}

- (void)getPopularContent
{
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[[NSNumber alloc] initWithInteger:lastTimestamp], @"/getPopularContent"] forKeys:@[@"last_timestamp", @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } callObject:self];
    
}


- (void)getNearbyContentHis{
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    ContentModel* lastModel = [contentModeArray lastObject];
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    if (lastModel != nil) {
        lastTimestamp = lastModel.publishTimeStamp;
    }
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[[NSNumber alloc] initWithDouble:app.myInfo.latitude], [[NSNumber alloc] initWithDouble:app.myInfo.longitude], [[NSNumber alloc] initWithInteger:lastTimestamp], @"/getNearbyContent"] forKeys:@[@"user_latitude", @"user_longitude", @"last_timestamp",  @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccessHis:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
    } callObject:self];

}

- (void)getContentSuccessHis:(id)sender
{

    
    NSDictionary* feedback = (NSDictionary*)sender;
    
    
    NSDictionary* contentsDic = [feedback objectForKey:@"contents"];
    NSArray* contents = [contentsDic allValues];
    
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserInfoModel* myinfo = app.myInfo;
    
    
    
    for (NSDictionary* element in contents) {
        ContentModel* contentMode = [[ContentModel alloc] init];
        [contentMode setContentModel:element];
        
        CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myinfo.latitude longitude:myinfo.longitude];
        CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:contentMode.latitude longitude:contentMode.longitude];
        CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
        contentMode.distanceMeters = meters;
        
        [contentModeArray addObject:contentMode];
        
    }
    
    [contentModeArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContentModel* element1 = (ContentModel*)obj1;
        ContentModel* element2 = (ContentModel*)obj2;
        return element1.publishTimeStamp<element2.publishTimeStamp;
    }];
    
    if ([contents count]>0) {
        [self.tableView reloadData];
        [self setBottomTitle:@"上拉加载更多数据"];
    }else{
        //no more his news
        noMoreHisNews = true;
        [self setBottomTitle:@"没有更多数据了"];
    }
}


- (void)getCollectContent
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[app.myInfo.userID, @"/getUserCollectList"] forKeys:@[@"user_id", @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
        
    } callObject:self];

}

- (void)getNearbyContent
{
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //异步注册信息
    NetWork* netWork = [[NetWork alloc] init];
    
    
    NSInteger lastTimestamp = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[[[NSNumber alloc] initWithDouble:app.myInfo.latitude], [[NSNumber alloc] initWithDouble:app.myInfo.longitude], [[NSNumber alloc] initWithInteger:lastTimestamp] , @"/getNearbyContent"] forKeys:@[@"user_latitude", @"user_longitude", @"last_timestamp", @"childpath"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(getException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self doneLoadingTableViewData];
        
    } callObject:self];
    
}


- (void)getException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)getActiveError:(id)sender
{
    alertMsg(@"获取活动失败");
}

- (NSInteger)getActiveLastTimestamp
{
    if ([contentModeArray count] == 0) {
        return 0;
    }else{
        NSInteger lastTimestamp = 0;
        for (int i=0; i<[contentModeArray count]; ++i) {
            ContentModel* active = [contentModeArray objectAtIndex:i];
            if (lastTimestamp<active.publishTimeStamp) {
                lastTimestamp = active.publishTimeStamp;
            }
        }
        return lastTimestamp;
    }
}

- (void)getContentSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    
    NSDictionary* contentsDic = (NSDictionary*)[feedback objectForKey:@"contents"];
    
    NSArray* contents = [contentsDic allValues];
    
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserInfoModel* myinfo = app.myInfo;
    
    [contentModeArray removeAllObjects];
    for (NSDictionary* element in contents) {
        ContentModel* contentMode = [[ContentModel alloc] init];
        [contentMode setContentModel:element];
        
        CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myinfo.latitude longitude:myinfo.longitude];
        CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:contentMode.latitude longitude:contentMode.longitude];
        
        NSLog(@"%f", contentMode.latitude);
        
        CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
        contentMode.distanceMeters = meters;
        
        [contentModeArray addObject:contentMode];
    }
    
    
    [contentModeArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContentModel* element1 = (ContentModel*)obj1;
        ContentModel* element2 = (ContentModel*)obj2;
        return element1.publishTimeStamp<element2.publishTimeStamp;
    }];
    
    [self.tableView reloadData];
    [self setBottomTitle:@"上拉加载更多数据"];
}

- (BOOL)isRepeatContent:(NSArray*)contentArray ContentModel:(ContentModel*)contentModel
{
    for (ContentModel* element in contentArray) {
        if ([element.contentID isEqual:contentModel.contentID]) {
            return true;
        }
    }
    return false;
}


- (void)callLoadingAction
{
    if (loadingAction!=nil) {
        [self performSelector:loadingAction withObject:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [contentModeArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    return [ContentTableViewCell getTotalHeight:model maxContentHeight:ScreenHeight];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary* userInfo = [nearByPersonArray objectAtIndex:indexPath.row];
//    
//    
//    TalkViewController* talk = [[TalkViewController alloc] init];
//    
//    talk.counterInfo.userID = [userInfo objectForKey:@"user_id"];
//    talk.counterInfo.faceImageURLStr = [userInfo objectForKey:@"user_facethumbnail"];
//    talk.counterInfo.nickName = [userInfo objectForKey:@"user_name"];
//    
//    [self.navigationController pushViewController:talk animated:YES];
    
    [commentInputView resignFirstResponder];
    
    ContentModel* model = [contentModeArray objectAtIndex:indexPath.row];
    ContentDetailViewController* contentDetail = [[ContentDetailViewController alloc] init];
    
    contentDetail.parentCtrl = self;
    contentDetail.contentModel = model;
    contentDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contentDetail animated:YES];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"ContentTableViewCell";
    ContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    // Configure the cell...
    if (cell==nil) {
        cell = [[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSLog(@"new cell");
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    //cell.contentViewCtrl = self;
    //cell.parentViewController = self.navigationController;
    //cell.index = indexPath;
    
    //NSLog(@"set image");
    ContentModel* contentmodel = [contentModeArray objectAtIndex:indexPath.row];
    
    [cell setContentModel:contentmodel];
    return cell;
}



- (void)initCommentInputView
{
    bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight+bottomToolbarHeight, ScreenWidth, bottomToolbarHeight)];
    [bottomToolbar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [bottomToolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    bottomToolbar.backgroundColor = activeViewControllerbackgroundColor;
    
    
    commentInputView = [[UITextView alloc] init];
    commentInputView.delegate =self;
    commentInputView.frame = CGRectMake(0, 0, ScreenWidth - 2*40, textViewHeight);
    commentInputView.returnKeyType = UIReturnKeyDone;//设置返回按钮的样式
    
    
    commentInputView.keyboardType = UIKeyboardTypeDefault;//设置键盘样式为默认
    commentInputView.font = [UIFont fontWithName:@"Arial" size:inputfontSize];
    commentInputView.scrollEnabled = YES;
    commentInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    commentInputView.layer.cornerRadius = 4.0;
    commentInputView.layer.borderWidth = 0.5;
    commentInputView.layer.borderColor = sepeartelineColor.CGColor;
    
    
    UIBarButtonItem* textfieldButtonItem =[[UIBarButtonItem alloc] initWithCustomView:commentInputView];
    
    UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendComment:)];
    
    NSArray *textfieldArray=[[NSArray alloc]initWithObjects:textfieldButtonItem, sendButton, nil];
    [bottomToolbar setItems:textfieldArray animated:YES];
    
    bottomToolbar.hidden = YES;
    
    [self.navigationController.view addSubview:bottomToolbar];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == commentInputView) {
        if ([text isEqualToString:@"\n"]) {
            
            [textView resignFirstResponder];
            
            [self sendComment:nil];
            
            return NO;
            
        }
        return YES;
    }
    return YES;
}


- (void)sendComment:(id)sender
{
    if ([commentInputView.text isEqual:@""]||commentInputView.text == nil) {
        return;
    }
    
    NSLog(@"%@", commentInputView.text);
    
    [commentInputView resignFirstResponder];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    CommentModel* commentModel = [[CommentModel alloc] init];
    UserInfoModel* myUserInfo = [AppDelegate getMyUserInfo];
    
    commentModel.sendUserInfo = myUserInfo;
    ContentModel* contentModel = [selectedCommentCell getMyContentModel];
    commentModel.contentModel = contentModel;
    commentModel.counterUserInfo = contentModel.userInfo;
    commentModel.commentStr = commentInputView.text;
    commentInputView.text = @"";
    
    
//    if (toCommentUser.userID == nil) {
//        toCommentUser = contentModel.userInfo;
//    }
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[commentModel.contentModel.contentID, commentModel.sendUserInfo.userID, commentModel.counterUserInfo.userID, commentModel.commentStr, commentModel.sendUserInfo.nickName, @"/addCommentToContent"] forKeys:@[@"content_id", @"user_id", @"to_user_id", @"comment", @"user_name", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addCommentSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
//        [mbProgress hide:YES];
//        [mbProgress removeFromSuperview];
//        mbProgress = nil;
    } callObject:self];
    
}


- (void)addCommentException:(id)sender
{
    alertMsg(@"添加评论异常");
}

- (void)addCommentError:(id)sender
{
    alertMsg(@"添加评论错误");
}

- (void)addCommentSuccess:(id)sender
{
    alertMsg(@"评论成功");
    
    [selectedCommentCell increaseCommentCount];
}




- (void)showCommentInputView:(ContentTableViewCell*)cell
{
    selectedCommentCell = cell;
    [commentInputView becomeFirstResponder];
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
