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
#import "ContentViewController.h"
#import "ComTableViewCtrl.h"
#import "MyContentAction.h"
#import "ImageBrowseAction.h"
#import "VisitListAction.h"
#import "BlackListAction.h"

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
    
    UILabel* sign;
    UIView* imageWallView;
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
    
    BOOL isInBlack;
    
    UIImageView* lastVisitUserFace;
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


const int sectionCount = 4;

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
    
    
    
    settingTitleArray = [[NSMutableArray alloc] initWithArray:@[@"年龄", @"星座", @"职业", @"公司", @"个人签名", @"兴趣爱好"]];
    
    tableviewHeight = 0;
    _changedFlag = false;
    _deleteUserImageFlag = false;
    userImageArray = [[NSMutableArray alloc] init];

}

- (void)settingButtonAction:(id)sender
{
//    TalkViewController* talk = [[TalkViewController alloc] init];
//    talk.counterInfo = _userInfo;
//    talk.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:talk animated:YES];
    
    if (isInBlack == false) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"关注Ta", @"私信", @"加入黑名单", nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"关注Ta", @"私信", @"解除黑名单", nil];
    }
    
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
    
    if (actionSheet == sheet) {
        if (buttonIndex == 0) {
            //关注Ta
            ;
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
        rightBar.frame = CGRectMake(0, 0, 24, 24);
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
    
    
    faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, faceBackgroundView.frame.origin.y+ faceBackgroundView.frame.size.height - faceImage_height/3, faceImage_width, faceImage_height)];
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
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, faceBackgroundView.frame.origin.y+ faceBackgroundView.frame.size.height+70)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.borderWidth = 0.0;
    
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    [headerView addSubview:faceBackgroundView];

    [headerView addSubview:faceImageView];
    
    
    genderView = [[UIImageView alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x + faceImageView.frame.size.width +10, faceImageView.frame.origin.y+faceImageView.frame.size.height/2, genderView_width, genderView_height)];
    [headerView addSubview:genderView];

    
    
    zanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(faceImageView.frame.origin.x + faceImageView.frame.size.width +10, genderView.frame.origin.y+genderView.frame.size.height+10, genderView_width, genderView_height)];
    zanImageView.image = [UIImage imageNamed:@"zan-active.png"];
    
    [headerView addSubview:zanImageView];
    
    
    
    
    
    
    ageAndStar = [[UILabel alloc] initWithFrame:CGRectMake(genderView.frame.origin.x+genderView.frame.size.width + 10, genderView.frame.origin.y, ageLabel_width, 20)];
    ageAndStar.font = [UIFont fontWithName:@"Arial" size:15];
    ageAndStar.textColor = [UIColor grayColor];
    
    [headerView addSubview: ageAndStar];
    
    visitCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(zanImageView.frame.origin.x + zanImageView.frame.size.width +10, zanImageView.frame.origin.y, 120, 20)];
    visitCityLabel.font = [UIFont fontWithName:@"Arial" size:15];
    visitCityLabel.textColor = [UIColor grayColor];
    
    [headerView addSubview: visitCityLabel];
    
    
    
    sign = [[UILabel alloc] initWithFrame:CGRectMake(zanImageView.frame.origin.x, zanImageView.frame.origin.y+zanImageView.frame.size.height+10, 200, zanImageView.frame.size.height)];
    //sign.text = _userInfo.sign;
    if((NSNull*)sign.text != [NSNull null]){
        sign.textColor = [UIColor grayColor];
    }
    
    //get user image from server
    [self getUserInfo];
    [self getLastVisitUser];
    
    backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.userInteractionEnabled = YES;
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewPress:)]];
    
    
    //send visit msg if user_id not equal my user_id
    if ([_userInfo.userID isEqual:app.myInfo.userID] == FALSE) {
        //send visit msg
        [self sendVisitMsg];
    }
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(refreshUserInfo:) forControlEvents:UIControlEventValueChanged];
//    self.refreshControl.tintColor = [UIColor grayColor];
    
}


//- (void)refreshUserInfo:(id)sender
//{
//    [self getUserInfo];
//}


- (void)sendVisitMsg
{
    NetWork* netWork = [[NetWork alloc] init];
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID, myInfo.userID,  myInfo.nickName, @"/visit"] forKeys:@[@"user_id", @"visit_user_id",  @"visit_user_name", @"childpath"]];
    
//    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getUserInfoSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(getUserInfoError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(getUserInfoException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
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
    sign.text = _userInfo.sign;
    
    isInBlack = [[feedback objectForKey:@"black"] boolValue];
    
    if (_userInfo.gender == 0) {
        genderView.image = [UIImage imageNamed:@"womanSetting.png"];
    }else{
        genderView.image = [UIImage imageNamed:@"manSetting.png"];
    }
    
    //NSLog(@"")
    
    [faceImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_userInfo.faceImageThumbnailURLStr]];
    
    contentStr = [Tools getJsonObject:[feedback objectForKey:@"content"]];
    contentImageUrlStr =  [Tools getJsonObject:[feedback objectForKey:@"content_image_url"]];
    contentPublishTime = [[feedback objectForKey:@"content_publish_timestamp"] intValue];
    visitCityCount = [[feedback objectForKey:@"city_visit_count"] intValue];
    int goodCount = [[feedback objectForKey:@"good_count"] intValue];
    
    
    visitCityLabel.text = [[NSString alloc] initWithFormat:@"%d", goodCount];
    
    ageAndStar.text = [[NSString alloc] initWithFormat:@"%ld | 去过%d个城市", _userInfo.age, visitCityCount];
    
    
    [settingStrArray removeAllObjects];
    
    [settingStrArray addObject:[[NSString alloc] initWithFormat:@"%ld", _userInfo.age]];
    [settingStrArray addObject:[Tools getStarDesc:_userInfo.birthday]];
    [settingStrArray addObject:_userInfo.career];
    [settingStrArray addObject:_userInfo.company];
    [settingStrArray addObject:_userInfo.sign];
    [settingStrArray addObject:_userInfo.interest];
    
    
    
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

- (void)getLastVisitUserSuccess:(id)sender
{
    NSDictionary* feedback = (NSDictionary*)sender;
    NSArray* data = [feedback objectForKey:@"data"];
    if ([data count] == 0) {
        return;
    }
    
    NSDictionary* element = [data objectAtIndex:0];
    
    lastVisitUserFace = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    lastVisitUserFace.layer.masksToBounds =YES;
    

    lastVisitUserFace.layer.cornerRadius = lastVisitUserFace.frame.size.height/2;
    
    [lastVisitUserFace sd_setImageWithURL:[[NSURL alloc] initWithString:[element objectForKey:@"user_facethumbnail"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
}

- (void)getLastVisitUser
{
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID, @"/getLastVisitUser"] forKeys:@[@"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getLastVisitUserSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        //[self hideLoading];
    } callObject:self];

}

- (void)getUserInfo
{
    [self startLoading];
    NetWork* netWork = [[NetWork alloc] init];
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, _userInfo.userID, @"/getUserInfo"] forKeys:@[@"my_user_id", @"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getUserInfoSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(getUserInfoError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(getUserInfoException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
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
    if ([[AppDelegate getMyUserInfo].userID isEqualToString:_userInfo.userID] == false){
        return sectionCount -1;
    }else{
        return sectionCount;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return [settingTitleArray count];
    }else if (section == 0){
        return 2;
    }else if (section == 1 ) {
        return 2;
    }else if(section == 3){
        return 2;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return bigCellHeight;
    }else{
        return 44;
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
        //self.view.hidden = NO;
    }];
}


- (void)showBlackList
{
    //[self.navigationController pushViewController:[[BlackListTableViewCtrl alloc] init] animated:YES];
    
    [self.navigationController pushViewController:[[ComTableViewCtrl alloc] init:YES allowPullUp:NO initLoading:YES comDelegate:[[BlackListAction alloc] init]] animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([app.myInfo.userID isEqualToString:_userInfo.userID] == false&&indexPath.section == 2) {
        //基本资料只能本用户点击修改
        return;
    }
    
    
    
    if (indexPath.section ==3) {
        //logout
        if (indexPath.row == 0) {
            [self showBlackList];
        }else if(indexPath.row == 1){
            [self logout];
        }
        
    }else if(indexPath.section ==2){
        
//        if (indexPath.row == 0||indexPath.row == 1||indexPath.row == 2) {
//            //年龄，星座，性别无法修改
//            return;
//        }
        
        _changedFlag = false;
        SettingChildViewController* settingChild = [[SettingChildViewController alloc] init];
        settingChild.settingStrArray = settingStrArray;
        settingChild.settingTitleArray = settingTitleArray;
        settingChild.parent = self;
        settingChild.hidesBottomBarWhenPushed = YES;
        settingChild.index = indexPath.row;        
        [self.navigationController pushViewController:settingChild animated:YES];
        
    }else if(indexPath.section == 0&&indexPath.row == 0){
        //发布
        ComTableViewCtrl* comTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[MyContentAction alloc] init:_userInfo.userID]];
        comTable.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:comTable animated:YES];

    }else if(indexPath.section == 0 && indexPath.row == 1){
        //发布的图片
        ComTableViewCtrl* comTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:YES initLoading:YES comDelegate:[[ImageBrowseAction alloc] init:_userInfo.userID]];
        comTable.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:comTable animated:YES];
        
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            //最近来访
            ComTableViewCtrl* comTable = [[ComTableViewCtrl alloc] init:YES allowPullUp:NO initLoading:YES comDelegate:[[VisitListAction alloc] init]];
            comTable.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:comTable animated:YES];
            
        }
        if (indexPath.row == 1) {
            //去过的城市
            //VisitPlaceListCtrl* visitPlace = [[VisitPlaceListCtrl alloc] init];
            //visitPlace.userInfo = _userInfo;
            //visitPlace.hidesBottomBarWhenPushed = YES;
            //[self.navigationController pushViewController:visitPlace animated:YES];
        }
    }
}

- (void)updateSuccess:(id)sender
{
    NSLog(@"更新资料成功");
}

- (void)updateError:(id)sender
{
    alertMsg(@"更新资料失败");
}

- (void)updateException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[super viewWillDisappear:animated];
    //[self.navigationController.navigationBar lt_reset];
}

- (void)viewWillAppear:(BOOL)animated
{

    
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (_changedFlag == true) {
        
        [self.tableView reloadData];
        NSLog(@"changed user info");
        
        //update to server
        NetWork* netWork = [[NetWork alloc] init];
        NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_userInfo.userID, _userInfo.career, _userInfo.company, _userInfo.sign, _userInfo.interest, @"/updateUserInfo"] forKeys:@[@"user_id", @"user_career", @"user_company", @"user_sign", @"user_interest", @"childpath"]];
        
        NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(updateSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(updateException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
        
        [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
        _changedFlag = false;
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色

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
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"黑名单";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"退出登录";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    if (indexPath.section == 2) {

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
    
    if (indexPath.section == 1) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        if (indexPath.row == 0) {
            cell.textLabel.text = @"最近来访";
            lastVisitUserFace.frame = CGRectMake(ScreenWidth - 64, 10, lastVisitUserFace.frame.size.width, lastVisitUserFace.frame.size.height);
            [cell.contentView addSubview:lastVisitUserFace];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"去过的城市";
            cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", visitCityCount];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    
    if (indexPath.section == 0) {
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


