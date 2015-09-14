//
//  UserImageViewController.m
//  CarSocial
//
//  Created by wang jam on 10/7/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "UserImageViewController.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import <MBProgressHUD.h>
#import "macro.h"


@interface UserImageViewController ()
{
    MBProgressHUD* loadingView;
    UIImageView* imageView;
}
@end

@implementation UserImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    UIBarButtonItem *leftitem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(navigationBackButton:)];
    
    
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:nil];
    
    navigationBarTitle.leftBarButtonItem = leftitem;
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([_parentView.userInfo.userID isEqualToString:app.myInfo.userID]) {
        UIBarButtonItem *rightitem = nil;
        if (_isFaceImage == true) {
            rightitem = [[UIBarButtonItem alloc] initWithTitle:@"替换" style:UIBarButtonItemStylePlain target:self action:@selector(changeButton:)];
        }else{
            rightitem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButton:)];
        }
        
        navigationBarTitle.rightBarButtonItem = rightitem;
    }
    
    [navigationBar setItems:[NSArray arrayWithObject: navigationBarTitle]];
    navigationBar.backgroundColor = [UIColor blackColor];
    navigationBar.barTintColor = [UIColor blackColor];
    navigationBar.tintColor = [UIColor whiteColor];
    
    [self.view addSubview: navigationBar];
    
    imageView = [[UIImageView alloc] init];
    imageView.frame = self.view.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [imageView sd_setImageWithURL:_imageURL placeholderImage:_imageThumbnail];
    [self.view addSubview:imageView];
    

}

- (void)deleteUserImageSuccess:(id)sender
{
    NSMutableArray* userImageArray = [self.parentView getUserImageArray];
    for (int i=0; i<[userImageArray count]; ++i) {
        if ([userImageArray objectAtIndex:i] == _imageURL.absoluteString) {
            [userImageArray removeObjectAtIndex:i];
            break;
        }
    }
    [loadingView hide:YES];
    loadingView = nil;
    self.parentView.deleteUserImageFlag = true;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteUserImageError:(id)sender
{
    alertMsg(@"删除图片失败");
}

- (void)deleteUserImageException:(id)sender
{
    alertMsg(@"未知问题");
}


- (void)changeUserFaceSuccess:(id)sender
{
    [loadingView hide:YES];
    loadingView = nil;
    
    NSDictionary* feedback = (NSDictionary*)sender;
    
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    SDImageCache* cache = [SDImageCache sharedImageCache];
    
    [cache removeImageForKey:myInfo.faceImageThumbnailURLStr];
    [cache removeImageForKey:myInfo.faceImageURLStr];
    
    myInfo.faceImageThumbnailURLStr = [feedback objectForKey:@"facethumbnail"];
    myInfo.faceImageURLStr = [feedback objectForKey:@"user_image_url"];
    
    [self.parentView setFaceImageView:[[NSURL alloc] initWithString:myInfo.faceImageThumbnailURLStr]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeUserFaceError:(id)sender
{
    alertMsg(@"更换头像失败");
}

- (void)changeUserFaceException:(id)sender
{
    alertMsg(@"未知问题");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    
    
    
    imageView.image = aImage;
    
    //update image
    //addImageView.image = aImage;
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[app.myInfo.userID, @"/changeFace"] forKeys:@[@"user_id", @"childpath"]];
    
    NSDictionary* images = [[NSDictionary alloc] initWithObjects:@[aImage] forKeys:@[@"user_image"]];
    
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(changeUserFaceSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(changeUserFaceError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(changeUserFaceException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:images feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
        loadingView = nil;
    } callObject:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色

    
}


- (void)changeButton:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)deleteButton:(id)sender
{
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[app.myInfo.userID, _imageURL.absoluteString, @"/deleteUserImage"] forKeys:@[@"user_id", @"user_image_url", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(deleteUserImageSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(deleteUserImageError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(deleteUserImageException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:DEL_IMAGE_SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
        loadingView = nil;
    } callObject:self];

}

- (void)navigationBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"userimage delloc");
        self.view = nil;
    }
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
