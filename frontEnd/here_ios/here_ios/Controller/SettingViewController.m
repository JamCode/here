//
//  SettingViewController.m
//  CarSocial
//
//  Created by wang jam on 9/13/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "SettingViewController.h"
#import "UserInfoModel.h"
#import "Constant.h"
#import <MBProgressHUD.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "macro.h"
#import "SettingTableViewCell.h"
#import "SettingChildViewController.h"
#import "NetWork.h"
#import "UserImageViewController.h"
#import "TalkViewController.h"
#import "Tools.h"
#import "ComTableViewCtrl.h"
#import "MyContentAction.h"
#import "ImageBrowseAction.h"
#import "VisitListAction.h"
#import "BlackListAction.h"
#import "MasterSettingCtrl.h"
#import "FeedBackCtrl.h"
#import "LocDatabase.h"
#import "FollowListAction.h"
#import "FansListAction.h"


//#import "ImageBrowseViewCtrl.h"
//#import "VisitListCtrl.h"
//#import "VisitPlaceListCtrl.h"
//#import "BlackListTableViewCtrl.h"

@interface SettingViewController ()
{
    UIImageView* faceImageView;
    //UILabel* ageLabel;
    UILabel* visitCityLabel;
    UIImageView* zanImageView;
    UIImageView* genderView;
    UILabel* ageAndStar;
    
    //UILabel* sign;
    //UIView* imageWallView;
    MBProgressHUD* loadingView;
    
    BOOL firstShow;
    //UIScrollView* mainScroll;
    
    
    NSMutableArray* settingStrArray;
    NSMutableArray* settingTitleArray;
    
    NSMutableArray* userImageArray;
    
    CGFloat tableviewHeight;
    
    UIView* backGroundView;
    
    UIImageView* addImageView;
    
    NSURL* curDeleteImageURL;
    
    UIView* backgroundView;
    UIImageView* enlargeFaceView;
    
    UIImageView* faceBackgroundView;
    UIView* headerView;
    
    UILabel* contentLabel;
    UIImageView* contentImageView;
    UILabel* contentPublishTimeLabel;
    
    NSString* contentStr;
    NSString* contentImageUrlStr;
    NSInteger contentPublishTime;
    
    NSMutableDictionary* imageDic;
    
    int visitCityCount;
    
    UIActionSheet* sheet;
    UIActionSheet* backgroundSheet;
    UIActionSheet* genderSheet;
    
    UIDatePicker *datePicker;
    
    
    
    BOOL isInBlack;
    BOOL isFollow;
    
    NSInteger lastUpdateGender;
    NSString* lastBirthday;
    
    //UIImageView* lastVisitUserFace;
}
@end

@implementation SettingViewController

const int faceImage_x = 20;
const int faceImage_y = 20;

const int faceImage_width = 70;
const int faceImage_height = 70;

const int genderView_width = 18;
const int genderView_height = 18;

const int ageLabel_width = 180;


const int carBrandView_width = 22;
const int carBrandView_height = 22;

const int signWidth = 200;

const double imageWall_height = 162.5;
const double image_width = 73.75;

const int settingFontSize = 17;
const int settingCellHeight = 44;


const int bigCellHeight = 88;
const int bigCellImageHeigh = 64;


const int sectionCount = 2;


static const int ageAndGenderHeight = 18;
static const int ageAndGenderWidth = 50;

static const int genderImageHeight = 18;
static const int ageHeight = 18;
static const int ageWidth = 30;



typedef enum {
    publish,
    photo
} publishDetail;


typedef enum {
    follow,
    fans,
    gender,
    age,
    start,
    sign
} userDetail;

typedef enum  {
    publishAndPhoto,
    details,
    support,
    logout
} section;


- (id)init:(UserInfoModel*)whoInfo
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _userInfo = whoInfo;
        imageDic = [[NSMutableDictionary alloc] init];
        visitCityCount = 0;
        isInBlack = false;
    }
    return self;
}

- (void)initMembers
{
    // Custom initialization
    firstShow = FALSE;
    settingStrArray = [[NSMutableArray alloc] init];
    if (_userInfo.career == nil) {
        _userInfo.career = @"";
    }
    if (_userInfo.company == nil) {
        _userInfo.company = @"";
    }
    if (_userInfo.sign == nil) {
        _userInfo.sign = @"";
    }
    if (_userInfo.interest == nil) {
        _userInfo.interest = @"";
    }
    
    
    
    settingTitleArray = [[NSMutableArray alloc] initWithArray:@[@"关注", @"粉丝", @"性别", @"年龄", @"星座", @"个人签名"]];
    
    tableviewHeight = 0;
    _changedFlag = false;
    _deleteUserImageFlag = false;
    userImageArray = [[NSMutableArray alloc] init];
    
}

- (void)settingButtonAction:(id)sender
{

    LocDatabase* loc = [AppDelegate getLocDatabase];
    
    NSString* followStr = @"";
    NSString* blackStr = @"";
    
    if(![loc followedUser:_userInfo.userID]){
        //未关注
        followStr = @"关注";
        isFollow = false;
    }else{
        //已关注
        followStr = @"取消关注";
        isFollow = true;
    }
    
    if(isInBlack == false){
        blackStr = @"加入黑名单";
    }else{
        blackStr = @"解除黑名单";
    }
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:followStr, @"私信", blackStr, nil];
    
    [sheet showInView:self.view];
    
}


- (void)insertBlackListSuccess:(id)sender
{
    
    //    [_parentCtrl deleteMsg:_counterInfo.userID];
    //    [_parentCtrl.tableView reloadData];
    //    [self.navigationController popViewControllerAnimated:YES];
    
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    loadingView.labelText = @"设置黑名单成功";
    loadingView.mode = MBProgressHUDModeText;
    loadingView.removeFromSuperViewOnHide = YES;
    [loadingView show:YES];
    [loadingView hide:YES afterDelay:2];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //[showView show:YES];
    
    //alertMsg(@"设置黑名单成功");
}

- (void)insertBlackListError:(id)sender
{
    alertMsg(@"未知错误");
}

- (void)insertBlackListException:(id)sender
{
    alertMsg(@"网络异常");
}

- (void)deleteBlackListSuccess:(id)sender
{
    
    //    [_parentCtrl deleteMsg:_counterInfo.userID];
    //    [_parentCtrl.tableView reloadData];
    //    [self.navigationController popViewControllerAnimated:YES];
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    loadingView.labelText = @"解除黑名单成功";
    loadingView.mode = MBProgressHUDModeText;
    loadingView.removeFromSuperViewOnHide = YES;
    [loadingView show:YES];
    [loadingView hide:YES afterDelay:2];
    
    //[self.navigationController popViewControllerAnimated:YES];
    
}

- (void)deleteBlackListError:(id)sender
{
    alertMsg(@"未知错误");
}

- (void)deleteBlackListException:(id)sender
{
    alertMsg(@"网络异常");
}


- (void)deleteFromBlackList
{
    [loadingView removeFromSuperview];
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, _userInfo.userID, @"/deleteBlackList"] forKeys:@[@"user_id", @"counter_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(deleteBlackListSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(deleteBlackListError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(deleteBlackListException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;
    } callObject:self];
    
}



- (void)setToBlackList
{
    [loadingView removeFromSuperview];
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, _userInfo.userID, @"/insertBlackList"] forKeys:@[@"user_id", @"counter_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(insertBlackListSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(insertBlackListError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(insertBlackListException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;
    } callObject:self];
    
}

- (void)clickBackground:(id)sender
{
    
    if ([[AppDelegate getMyUserInfo].userID isEqualToString:_userInfo.userID] == false){
        return;
    }
    
    backgroundSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"设置封面", nil];
    [backgroundSheet showInView:self.view];
}


- (void)clickGender:(id)sender
{
    if ([[AppDelegate getMyUserInfo].userID isEqualToString:_userInfo.userID] == false){
        return;
    }
    
    
    genderSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"女",@"男", nil];
    
    [genderSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld", buttonIndex);
    if (actionSheet == backgroundSheet) {
        if(buttonIndex == 0){
            
            UIImagePickerController* picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
        
    }
    
    if (actionSheet == genderSheet) {
        
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        
        if (buttonIndex == 0) {
            //女
            cell.detailTextLabel.text = @"女";
            lastUpdateGender = 0;
            [self updateUserGender:lastUpdateGender];
        }
        
        if (buttonIndex == 1) {
            //男
            cell.detailTextLabel.text = @"男";
            lastUpdateGender = 1;
            [self updateUserGender:lastUpdateGender];
        }
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        
    }
    
    if (actionSheet == sheet) {
        
        if (buttonIndex == 0) {
            //关注
            if (isFollow == true) {
                [self cancelFollowedUser:nil];
            }else{
                [self followedUser:nil];
            }
            
        }
        
        if (buttonIndex == 1) {
            //私信
            TalkViewController* talk = [[TalkViewController alloc] init];
            talk.counterInfo = _userInfo;
            talk.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:talk animated:YES];
        }
        
        if (buttonIndex == 2) {
            //黑名单
            if (isInBlack == false) {
                [self setToBlackList];
            }else{
                [self deleteFromBlackList];
            }
        }
    }
}


//-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    if (viewController == self) {
//        //self.navigationController.navigationBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
//    }else{
//        self.navigationController.navigationBar.alpha =1;
//    }
//}

- (void)followedUser:(id)sender
{
    NetWork* netWork = [[NetWork alloc] init];
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, myInfo.nickName, _userInfo.userID, @"/followUser"] forKeys:@[@"user_id", @"user_name",  @"followed_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(followedUserSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        ;
    } callObject:self];
}

- (void)cancelFollowedUser:(id)sender
{
    NetWork* netWork = [[NetWork alloc] init];
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, _userInfo.userID, @"/cancelFollowUser"] forKeys:@[@"user_id", @"followed_user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(cancelFollowedUserSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        ;
    } callObject:self];
}

- (void)cancelFollowedUserSuccess:(id)sender
{
    LocDatabase* loc = [AppDelegate getLocDatabase];
    [loc delFollowInfo:_userInfo.userID];
    [Tools AlertBigMsg:@"取消关注"];
}

- (void)followedUserSuccess:(id)sender
{
    LocDatabase* loc = [AppDelegate getLocDatabase];
    [loc addFollowInfo:_userInfo.userID];
    [Tools AlertBigMsg:@"关注成功"];
}



- (void)showSetting:(id)sender
{
    MasterSettingCtrl* masterSetting = [[MasterSettingCtrl alloc] initWithStyle:UITableViewStyleGrouped];
    
    masterSetting.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:masterSetting animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationController.delegate =self;
    
    
    //self.view.backgroundColor = myblack;
    
    
    [self initMembers];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([app.myInfo.userID isEqualToString:_userInfo.userID] == false) {
        UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBar.frame = CGRectMake(0, 0, 36, 30);
        [rightBar setBackgroundImage:[UIImage imageNamed:@"dot.png"] forState:UIControlStateNormal];
        
        
        [rightBar setTintColor:[UIColor whiteColor]];
        [rightBar addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
        self.navigationItem.rightBarButtonItem = rightitem;
    }
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:_userInfo.nickName];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    
    
    
    faceBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    faceBackgroundView.backgroundColor = myblack;
    faceBackgroundView.userInteractionEnabled = YES;
    faceBackgroundView.clipsToBounds = YES;
    faceBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickBackground:)];
    [faceBackgroundView addGestureRecognizer:tapGesture];
    
    
    faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, faceBackgroundView.frame.origin.y+ faceBackgroundView.frame.size.height - faceImage_height/2, faceImage_width, faceImage_height)];
    faceImageView.backgroundColor = [UIColor clearColor];
    faceImageView.layer.masksToBounds = YES;
    
    faceImageView.layer.cornerRadius = faceImage_height/2;
    faceImageView.contentMode = UIViewContentModeScaleAspectFill;
    faceImageView.userInteractionEnabled = YES;
    
    [faceImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickFaceImageAction:)]];
    
    
    
    faceImageView.image = [UIImage imageNamed:@"loading.png"];
    //faceImageView.layer.borderWidth = 1.0;
    //faceImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //    [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_userInfo.faceImageURLStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, faceBackgroundView.frame.origin.y+ faceBackgroundView.frame.size.height+60)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.borderWidth = 0.0;
    
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    [headerView addSubview:faceBackgroundView];
    
    [headerView addSubview:faceImageView];
    
    
    
    
    
//    sign = [[UILabel alloc] initWithFrame:CGRectMake(zanImageView.frame.origin.x, zanImageView.frame.origin.y+zanImageView.frame.size.height+10, 200, zanImageView.frame.size.height)];
    //sign.text = _userInfo.sign;
//    if((NSNull*)sign.text != [NSNull null]){
//        sign.textColor = [UIColor grayColor];
//    }
    
    //get user image from server
    [self getUserInfo];
    
    backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.userInteractionEnabled = YES;
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewPress:)]];
    
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenHeight-260, ScreenWidth, 220)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = YES;
    
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.navigationController.view addSubview:datePicker];

    
}

- (void)dateChanged:(id)sender
{
    NSLog(@"date change");
    NSDate* selectDate = datePicker.date;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:selectDate];
    
    NSInteger year= [components year];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateDesc = [formatter stringFromDate:selectDate];
    
    NSLog(@"%@", dateDesc);
    
    NSDateComponents *curComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    UITableViewCell* cell =  [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%ld", [Tools getAgeFromBirthDay:dateDesc]];
    
    lastBirthday = dateDesc;
}


- (void)sendVisitMsg
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID, myInfo.userID,  myInfo.nickName, @"/visit"] forKeys:@[@"user_id", @"visit_user_id",  @"visit_user_name", @"childpath"]];
    
    [netWork message:message images:nil feedbackcall:nil complete:^{
        //[self hideLoading];
    } callObject:self];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset  = scrollView.contentOffset.y;
    
    if (yOffset <= -64) {
        CGRect f =faceBackgroundView.frame;
        f.origin.x = (yOffset + 64)/2;
        f.size.width = ScreenWidth+ABS(yOffset+64);
        f.origin.y = (yOffset + 64);
        f.size.height = ScreenWidth+ABS(yOffset + 64);
        faceBackgroundView.frame = f;
        
    }
    

    
    
    
    if ([Tools getAgeFromBirthDay:lastBirthday]!=[Tools getAgeFromBirthDay:_userInfo.birthday]&&datePicker.hidden == NO) {
        //更新年龄
        
        [self updateBirthDay:lastBirthday];
        
    }
    
    
    datePicker.hidden = YES;
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
}


- (void)updateBirthDay:(NSString*)user_birth_day
{
    //update to server
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID,user_birth_day, @"/updateBirthDay"] forKeys:@[@"user_id", @"user_birth_day", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(updateSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}


- (void)startLoading
{
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
}

- (void)hideLoading
{
    if (loadingView != nil) {
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
    }
    loadingView = nil;
}


- (void)backgroundViewPress:(id)sender
{
    // animations settings
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.3 animations:^{
        enlargeFaceView.frame = [Tools relativeFrameForScreenWithView:faceImageView];
        [backgroundView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [enlargeFaceView removeFromSuperview];
        [backgroundView removeFromSuperview];
    }];
    
}

- (NSMutableArray*)getUserImageArray
{
    return userImageArray;
}

- (void)getUserInfoSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    [_userInfo fillWithData:feedback];
    
    //    ageLabel.text = [[NSString alloc] initWithFormat:@"%ld岁 | %@", [Tools getAgeFromBirthDay:_userInfo.birthday], [Tools getStarDesc:_userInfo.birthday]];
    
    
    //ageLabel.text = [[NSString alloc] initWithFormat:@"%ld", (long)_userInfo.age];
    //sign.text = _userInfo.sign;
    
    isInBlack = [[feedback objectForKey:@"black"] boolValue];
    
    if (_userInfo.gender == 0) {
        genderView.image = [UIImage imageNamed:@"womanSetting.png"];
    }else if (_userInfo.gender == 1){
        genderView.image = [UIImage imageNamed:@"manSetting.png"];
    }else{
        genderView.image = nil;
    }
    
    //NSLog(@"")
    
    [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_userInfo.faceImageThumbnailURLStr]];
    
    contentStr = [Tools getJsonObject:[feedback objectForKey:@"content"]];
    contentImageUrlStr =  [Tools getJsonObject:[feedback objectForKey:@"content_image_url"]];
    contentPublishTime = [[feedback objectForKey:@"content_publish_timestamp"] intValue];
    //visitCityCount = [[feedback objectForKey:@"city_visit_count"] intValue];
    //int goodCount = [[feedback objectForKey:@"good_count"] intValue];
    
    
    //visitCityLabel.text = [[NSString alloc] initWithFormat:@"%d", goodCount];
    
    //    ageAndStar.text = [[NSString alloc] initWithFormat:@"%ld | 去过%d个城市", _userInfo.age, visitCityCount];
    
    
    [settingStrArray removeAllObjects];
    
    
    
    [settingStrArray addObject:[[NSString alloc] initWithFormat:@"%ld", _userInfo.user_follow_count]];
    
    [settingStrArray addObject:[[NSString alloc] initWithFormat:@"%ld", _userInfo.user_fans_count]];
    
    if (_userInfo.gender == 1) {
        [settingStrArray addObject:@"男"];
    }else if(_userInfo.gender == 0) {
        [settingStrArray addObject:@"女"];
    }else{
        [settingStrArray addObject:@""];
    }
    
    if ([_userInfo.birthday isEqual:@""]) {
        [settingStrArray addObject:@""];
    }else{
        [settingStrArray addObject:[[NSString alloc] initWithFormat:@"%ld", [Tools getAgeFromBirthDay:_userInfo.birthday]]];
    }
    
    [settingStrArray addObject:[Tools getStarDesc:_userInfo.birthday]];
    [settingStrArray addObject:_userInfo.sign];
    
    
    
    if (_userInfo.user_background_image_url!=NULL&&(NSNull*)_userInfo.user_background_image_url!=[NSNull null]) {
        [faceBackgroundView sd_setImageWithURL:[[NSURL alloc] initWithString:_userInfo.user_background_image_url]];
    }else{
        faceBackgroundView.image = [UIImage imageNamed:@"default_background.JPG"];
    }
    
    
    [self.tableView reloadData];
    [userImageArray removeAllObjects];
    
    
    
    NSArray* temp = [feedback objectForKey:@"user_image"];
    
    for (int i=0; i<[temp count]; ++i) {
        NSDictionary* element = (NSDictionary*)[temp objectAtIndex:i];
        [userImageArray addObject:[element objectForKey:@"user_image_url"]];
    }
    
    [self setNickNameLabel];
    
    
    lastUpdateGender = _userInfo.gender;
    lastBirthday = _userInfo.birthday;
    
}



- (void)setNickNameLabel
{
    CGSize nickNameSize = [Tools getTextArrange:_userInfo.nickName maxRect:CGSizeMake(120, 80) fontSize:18];
    NSLog(@"%f,%f", nickNameSize.height, nickNameSize.width);
    UILabel* nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x+faceImageView.frame.size.width+10, faceImageView.frame.origin.y+faceImageView.frame.size.height/2+10, nickNameSize.width+5, nickNameSize.height+5)];
    [headerView addSubview:nickNameLabel];
    nickNameLabel.text = _userInfo.nickName;
    nickNameLabel.font = [UIFont fontWithName:@"Arial" size:18];
    nickNameLabel.textColor = [UIColor grayColor];
    
    
    UIView* ageAndGenderView = [[UIView alloc] initWithFrame:CGRectMake(nickNameLabel.frame.origin.x+10+nickNameLabel.frame.size.width, nickNameLabel.frame.origin.y, ageAndGenderWidth, nickNameLabel.frame.size.height - 5)];
    ageAndGenderView.layer.cornerRadius = 4.0;
    
    ageAndGenderView.center = CGPointMake(ageAndGenderView.center.x, nickNameLabel.center.y);
    
    
    UIImageView* genderImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 4, genderImageHeight, genderImageHeight)];
    genderImage.center = CGPointMake(genderImage.center.x, ageAndGenderView.frame.size.height/2);
    
    genderImage.contentMode = UIViewContentModeScaleAspectFill;
    
    
    [ageAndGenderView addSubview:genderImage];
    
    UILabel* ageAndGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(genderImage.frame.origin.x+genderImage.frame.size.width, 2, ageWidth, ageHeight)];
    
    
    ageAndGenderLabel.textAlignment = NSTextAlignmentCenter;
    ageAndGenderLabel.font = [UIFont fontWithName:@"Arial" size:16];
    ageAndGenderLabel.textColor = [UIColor whiteColor];
    ageAndGenderLabel.center = CGPointMake(ageAndGenderLabel.center.x, genderImage.center.y);
    
    [ageAndGenderView addSubview: ageAndGenderLabel];
    
    
    if (_userInfo.birthday == nil||_userInfo.birthday == [NSNull class]
        ||[_userInfo.birthday isEqualToString:@""]) {
        ageAndGenderLabel.text = @"未知";
    }else{
        ageAndGenderLabel.text = [[NSString alloc] initWithFormat:@"%ld", [Tools getAgeFromBirthDay:_userInfo.birthday]];
    }
    
    
    if (_userInfo.gender==0) {
        genderImage.image = [UIImage imageNamed:@"woman32white.png"];
        ageAndGenderView.backgroundColor = genderPink;
    }else if(_userInfo.gender == 1){
        genderImage.image = [UIImage imageNamed:@"man32white.png"];
        ageAndGenderView.backgroundColor = subjectColor;
    }else{
        ageAndGenderView.hidden = YES;
    }
    
    [headerView addSubview:ageAndGenderView];
    
}

- (void)clickAddImageViewAction:(UITapGestureRecognizer*)sender
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickered
{
    [pickered dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)pickered didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    //修改个人背景图片
    [pickered dismissViewControllerAnimated:YES completion:nil];
    
    [self startLoading];
    
    //update image
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[app.myInfo.userID, @"/addUserBackgroundImage"] forKeys:@[@"user_id", @"childpath"]];
    
    
    
    
    NSDictionary* images = [[NSDictionary alloc] initWithObjects:@[aImage] forKeys:@[@"user_background_image"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addUserBackgroundImageSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addUserBackgroundImageError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addUserBackgroundImageException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:ADD_IMAGE_SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:images feedbackcall:feedbackcall complete:^{
        [self hideLoading];
    } callObject:self];
}


- (void)getUserInfoError:(id)sender
{
    alertMsg(@"获取用户信息失败");
}

- (void)getUserInfoException:(id)sender
{
    alertMsg(@"未知问题");
}

//- (void)getLastVisitUserSuccess:(id)sender
//{
//    NSDictionary* feedback = (NSDictionary*)sender;
//    NSArray* data = [feedback objectForKey:@"data"];
//    if ([data count] == 0) {
//        return;
//    }
//    
//    NSDictionary* element = [data objectAtIndex:0];
//    
//    lastVisitUserFace = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
//    lastVisitUserFace.layer.masksToBounds =YES;
//    
//    
//    lastVisitUserFace.layer.cornerRadius = lastVisitUserFace.frame.size.height/2;
//    
//    [lastVisitUserFace sd_setImageWithURL:[[NSURL alloc] initWithString:[element objectForKey:@"user_facethumbnail"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//    }];
//}



- (void)getUserInfo
{
    [self startLoading];
    NetWork* netWork = [[NetWork alloc] init];
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, _userInfo.userID, @"/getUserInfo"] forKeys:@[@"my_user_id", @"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getUserInfoSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [self hideLoading];
    } callObject:self];
}


- (void)addUserBackgroundImageSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    
    if ([feedback objectForKey:@"user_background_image_url"]!=NULL) {
        [faceBackgroundView sd_setImageWithURL:[[NSURL alloc] initWithString:[feedback objectForKey:@"user_background_image_url"]]];
    }
}

- (void)addUserBackgroundImageError:(id)sender
{
    alertMsg(@"添加背景照片失败");
}

- (void)addUserBackgroundImageException:(id)sender
{
    alertMsg(@"网络异常");
}

- (void)clickImageViewBackGroundAction:(id)sender
{
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView animateWithDuration:0.3 animations:^{
        [backGroundView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [backGroundView removeFromSuperview];
        self.tabBarController.tabBar.hidden = NO;
    }];
}

- (void)deleteUserImage:(id)sender
{
    NSLog(@"delete %@", curDeleteImageURL);
}

- (void)setFaceImageView:(NSURL*)url
{
    [faceImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loading.png"]];
}

- (void)clickFaceImageAction:(UITapGestureRecognizer*)sender
{
    UIImageView* imageView = (UIImageView*)sender.view;
    UserInfoModel* myinfo = [AppDelegate getMyUserInfo];
    if ([myinfo.userID isEqualToString:_userInfo.userID]) {
        //go to modify view
        UserImageViewController* userImageDetail = [[UserImageViewController alloc] init];
        userImageDetail.imageURL = [[NSURL alloc] initWithString:myinfo.faceImageURLStr];
        userImageDetail.imageThumbnail = imageView.image;
        userImageDetail.parentView = self;
        userImageDetail.isFaceImage = true;
        [self presentViewController:userImageDetail animated:YES completion:nil];
        
    }else{
        if (enlargeFaceView == nil) {
            enlargeFaceView = [[UIImageView alloc] init];
        }
        
        enlargeFaceView.frame = [Tools relativeFrameForScreenWithView:faceImageView];
        
        //enlargeFaceView.frame = faceImageView.frame;
        [backgroundView addSubview:enlargeFaceView];
        [backgroundView setAlpha:0.0];
        [self.tabBarController.view addSubview:backgroundView];
        
        //        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:enlargeFaceView animated:YES];
        //        hud.mode = MBProgressHUDModeIndeterminate;
        //        [hud show:YES];
        
        [enlargeFaceView sd_setImageWithURL:[[NSURL alloc] initWithString:_userInfo.faceImageURLStr] placeholderImage:faceImageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //[hud hide:YES];
        }];
        
        
        // animations settings
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:0.3 animations:^{
            [backgroundView setAlpha:1.0];
            enlargeFaceView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            enlargeFaceView.contentMode = UIViewContentModeScaleAspectFit;
            
        } completion:^(BOOL finished) {
            ;
        }];
    }
}

- (void)faceImageHide:(id)sender
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([_userInfo.userID isEqual:[app getMyID]]) {
        return 4;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == publishAndPhoto) {
        return 2;
    }else if (section == details){
        return [settingTitleArray count];
    }else if(section == support){
        return 2;
    }else if(section == logout){
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return bigCellHeight;
    }else{
        return 46;
    }
    
    //UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //return cell.frame.size.height;
}

- (CGFloat)getTableViewHeight
{
    CGFloat allHeight = 0;
    for (int i=0; i<[settingStrArray count]; ++i) {
        CGSize boundSize = CGSizeMake(180, CGFLOAT_MAX);
        NSString* str = [settingStrArray objectAtIndex:i];
        
        
        CGSize requireSize = [Tools getTextArrange:str maxRect:boundSize fontSize:16];;
        
        
        NSLog(@"%f", requireSize.height);
        if (settingCellHeight<requireSize.height) {
            allHeight+=(requireSize.height+28);
        }else{
            allHeight+=settingCellHeight;
        }
    }
    return allHeight+settingCellHeight;
}

- (void)logout
{
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    
    [loadingView showAnimated:YES whileExecutingBlock:^{
        
        //清理本地账户信息
        NSUserDefaults *mySettingData = [NSUserDefaults standardUserDefaults];
        [mySettingData removeObjectForKey:@"phone"];
        [mySettingData removeObjectForKey:@"password"];
        [mySettingData synchronize];
        [NSThread sleepForTimeInterval:3.0];
        
        //发送注销请求给服务器
        
    } completionBlock:^{
        //self.parentViewController.view.hidden = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [app backToStartView];
        
        //[self.navigationController popToRootViewControllerAnimated:YES];
        
        //self.view.hidden = NO;
    }];
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == support) {
        return @"支持";
    }
    if (section == details) {
        return @"个人资料";
    }
    return @"";
}


- (void)showBlackList
{
    //[self.navigationController pushViewController:[[BlackListTableViewCtrl alloc] init] animated:YES];
    
    [self.navigationController pushViewController:[[ComTableViewCtrl alloc] init:YES allowPullUp:NO initLoading:YES comDelegate:[[BlackListAction alloc] init]] animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([app.myInfo.userID isEqualToString:_userInfo.userID] == false&&indexPath.section == details) {
        //基本资料只能本用户点击修改
        return;
    }
    
    if(indexPath.section ==details){
        
        if(indexPath.row == follow){
            
            
            FollowListAction* followAction = [[FollowListAction alloc] init];
            followAction.userInfo = _userInfo;
            ComTableViewCtrl* followUserTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:followAction];
            followUserTable.hidesBottomBarWhenPushed = YES;

            [self.navigationController pushViewController:followUserTable animated:YES];
            
        }
        
        if(indexPath.row == fans){
            FansListAction* fansAction = [[FansListAction alloc] init];
            fansAction.userInfo = _userInfo;
            ComTableViewCtrl* fansUserTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:fansAction];
            fansUserTable.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:fansUserTable animated:YES];
        }
        
        
        if(indexPath.row == sign){
            _changedFlag = false;
            SettingChildViewController* settingChild = [[SettingChildViewController alloc] init];
            settingChild.settingStrArray = settingStrArray;
            settingChild.settingTitleArray = settingTitleArray;
            settingChild.parent = self;
            settingChild.hidesBottomBarWhenPushed = YES;
            settingChild.index = indexPath.row;
            [self.navigationController pushViewController:settingChild animated:YES];
        }
        
        
        if(indexPath.row == gender){
            //性别
            [self clickGender:nil];
            
        }
        
        if(indexPath.row == age){
            //年龄
            datePicker.hidden = NO;
        }
        
        
    }
    
    if(indexPath.section == publishAndPhoto&&indexPath.row == 0){
        //发布
        ComTableViewCtrl* comTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[MyContentAction alloc] init:_userInfo.userID]];
        comTable.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:comTable animated:YES];
        
    }
    
    if(indexPath.section == publishAndPhoto && indexPath.row == 1){
        //发布的图片
        ComTableViewCtrl* comTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[ImageBrowseAction alloc] init:_userInfo.userID]];
        comTable.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:comTable animated:YES];
        
    }
    
    if (indexPath.section == logout) {
        [self logout];
    }
    
    if (indexPath.section == support) {
        
        if(indexPath.row == 1){
            FeedBackCtrl* feedback = [[FeedBackCtrl alloc] init];
            feedback.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:feedback animated:YES];

        }
        
        if(indexPath.row == 0){
            //黑名单
            ComTableViewCtrl* comTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:NO initLoading:YES comDelegate:[[BlackListAction alloc] init]];
            comTable.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:comTable animated:YES];
        }
    }
    
}

- (void)updateSuccess:(id)sender
{
    NSLog(@"更新资料成功");
    [Tools AlertBigMsg:@"更新资料成功"];
    
    _userInfo.gender = lastUpdateGender;
    _userInfo.birthday = lastBirthday;
    
    if (_userInfo.gender == 0) {
        [settingStrArray setObject:@"女" atIndexedSubscript:gender];

    }
    
    if (_userInfo.gender == 1) {
        [settingStrArray setObject:@"男" atIndexedSubscript:gender];
    }
    
    _userInfo.age = [Tools getAgeFromBirthDay:_userInfo.birthday];
    
    [settingStrArray setObject:[[NSString alloc] initWithFormat:@"%ld", _userInfo.age]  atIndexedSubscript:age];
    
}

- (void)updateError:(id)sender
{
    alertMsg(@"更新资料失败");
    [Tools AlertBigMsg:@"更新资料失败"];

}

- (void)updateException:(id)sender
{
    alertMsg(@"未知问题");
    [Tools AlertBigMsg:@"更新资料失败"];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    datePicker.hidden = YES;
    
    //[self.navigationController.navigationBar lt_reset];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (_changedFlag == true) {
        
        [self.tableView reloadData];
        NSLog(@"changed user info");
        
        [self updateUserInfo];
        
        _changedFlag = false;
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
    

    
}


- (void)updateUserGender:(NSInteger)user_gender
{
    //update to server
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID,[[NSNumber alloc] initWithInteger:user_gender], @"/updateUserGender"] forKeys:@[@"user_id", @"user_gender", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(updateSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}

- (void)updateUserInfo
{
    //update to server
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID, _userInfo.career, _userInfo.company, _userInfo.sign, _userInfo.interest, @"/updateUserInfo"] forKeys:@[@"user_id", @"user_career", @"user_company", @"user_sign", @"user_interest", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(updateSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"tablecell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tablecell"];
    }
    
    for (UIView *subview in [cell.contentView subviews]){
        [subview removeFromSuperview];
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = @"";
    }
    
    
    if (indexPath.section == logout) {
        cell.textLabel.text = @"退出账户";
        cell.textLabel.textColor = subjectColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if(indexPath.section == support){
        if (indexPath.row == 1) {
            cell.textLabel.text = @"用户反馈";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(indexPath.row == 0){
            cell.textLabel.text = @"黑名单";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
       
    }
    
    if (indexPath.section == details) {
        cell.textLabel.text = [settingTitleArray objectAtIndex:indexPath.row];
        
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if ([settingStrArray count]>indexPath.row) {
            cell.detailTextLabel.text = [settingStrArray objectAtIndex:indexPath.row];
        }
            
        cell.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:settingFontSize];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        CGSize boundSize = CGSizeMake(180, CGFLOAT_MAX);
            
            
        CGSize requireSize = [Tools getTextArrange:cell.detailTextLabel.text maxRect:boundSize fontSize:16];
            
        if (cell.frame.size.height<requireSize.height) {
            [cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, requireSize.height+28)];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    }
    

    if (indexPath.section == publishAndPhoto) {
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"发布";
            if (contentPublishTime != 0) {
                if (contentImageUrlStr == NULL||(NSNull*)contentImageUrlStr == [NSNull null]||[contentImageUrlStr isEqualToString:@""]) {
                    
                    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, (bigCellHeight - bigCellImageHeigh)/2, 3*bigCellImageHeigh, (2/3.0)*bigCellHeight - 15)];
                    contentLabel.text = contentStr;
                    
                    contentLabel.numberOfLines = 0;
                    contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                    contentLabel.font = [UIFont fontWithName:@"Arial" size:16];
                    contentLabel.textColor = [UIColor grayColor];
                    [cell.contentView addSubview:contentLabel];
                    
                    
                    contentPublishTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y+contentLabel.frame.size.height, 2*bigCellImageHeigh, (1.0/3)*bigCellHeight)];
                    contentPublishTimeLabel.font = [UIFont fontWithName:@"Arial" size:14];
                    contentPublishTimeLabel.textColor = [UIColor grayColor];
                    contentPublishTimeLabel.text = [Tools showTime:contentPublishTime];
                    [cell.contentView addSubview:contentPublishTimeLabel];
                    
                }else{
                    contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(88, (bigCellHeight - bigCellImageHeigh)/2, bigCellImageHeigh, bigCellImageHeigh)];
                    contentImageView.contentMode = UIViewContentModeScaleAspectFill;
                    contentImageView.clipsToBounds = YES;
                    
                    [contentImageView sd_setImageWithURL:[[NSURL alloc] initWithString:contentImageUrlStr] placeholderImage:[UIImage imageNamed:@"loading.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        
                        
                    }];
                    
                    [cell.contentView addSubview:contentImageView];
                    
                    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentImageView.frame.origin.x+contentImageView.frame.size.width+10, contentImageView.frame.origin.y, 2*bigCellImageHeigh, (2/3.0)*bigCellHeight - 15)];
                    contentLabel.text = contentStr;
                    
                    contentLabel.numberOfLines = 0;
                    contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                    contentLabel.font = [UIFont fontWithName:@"Arial" size:16];
                    contentLabel.textColor = [UIColor grayColor];
                    [cell.contentView addSubview:contentLabel];
                    
                    
                    contentPublishTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y+contentLabel.frame.size.height, 2*bigCellImageHeigh, (1.0/3)*bigCellHeight)];
                    contentPublishTimeLabel.font = [UIFont fontWithName:@"Arial" size:14];
                    contentPublishTimeLabel.textColor = [UIColor grayColor];
                    contentPublishTimeLabel.text = [Tools showTime:contentPublishTime];
                    [cell.contentView addSubview:contentPublishTimeLabel];
                }
                
            }
            
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = @"相册";
            for (int i=0; i<[userImageArray count]&& i<3; ++i) {
                UIImageView* imageview = [[UIImageView alloc] initWithFrame:CGRectMake((bigCellImageHeigh+5)*i+88, (bigCellHeight - bigCellImageHeigh)/2, bigCellImageHeigh, bigCellImageHeigh)];
                imageview.contentMode = UIViewContentModeScaleAspectFill;
                imageview.clipsToBounds = YES;
                
                
                [imageview sd_setImageWithURL:[[NSURL alloc] initWithString:[userImageArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"loading.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
                
                [cell.contentView addSubview:imageview];
            }
            
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"settingview delloc");
        //userImageArray = nil;
        //imageWallView = nil;
        //mainScroll = nil;
        //self.view = nil;
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



