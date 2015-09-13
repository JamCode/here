//
//  CertificateViewController.m
//  CarSocial
//
//  Created by wang jam on 8/14/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "CertificateViewController.h"
#import "Constant.h"
#import "TextFieldView.h"
#import "CarSelectListTableViewController.h"
#import <MBProgressHUD.h>

@interface CertificateViewController ()
{
    UIImageView* certificateImageView;
    TextFieldView* certificateNoTextField;
    BOOL selectCertificateImage;
    MBProgressHUD* loadingView;
    UILabel* selectCarType;
    UIImageView* selectCarIcon;
}

@end

@implementation CertificateViewController

const int notice_x = 20;
const int notice_y = 10;
const int notice_height = 66;

const int certificateImage_x = 20;
const int certificateImage_y = notice_height+10+10;
const int certificateImageHeight = 160;

const int certificateNo_x = 20;
const int certificateNo_Y = certificateImage_y+certificateImageHeight+10;
const int certificateNo_height = 40;



const int registerButton_x = 20;
const int registerButton_y = certificateNo_Y+certificateNo_height+10;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.userInfo = [[UserInfoModel alloc] init];
        self.view.backgroundColor = [UIColor whiteColor];
        selectCertificateImage = false;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
}



- (void)onClickCertificateImage:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    //save all textfield value
    self.userInfo.certificateNo = certificateNoTextField.text;
    
    [self presentViewController:picker animated:YES completion:nil];
    NSLog(@"onClickCertificateImage");
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"did select picture");
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //addPicRect.frame.origin.
    certificateImageView.image = aImage;
    [certificateImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    certificateImageView.contentMode =  UIViewContentModeScaleAspectFill;
    certificateImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    certificateImageView.clipsToBounds  = YES;
    //chooseFaceImage = TRUE;
    //NSLog(@"nickname %@", nickNameTextView.text);
    
    //recover textfield value
    certificateNoTextField.text = _userInfo.certificateNo;
    selectCertificateImage = TRUE;
}

- (void) nextButtonActionWithoutCertificate:(id)sender
{
    NSLog(@"nextButtonActionWithoutCertificate");
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    loadingView.labelText = @"请稍后";
    [self.view addSubview:loadingView];
    [loadingView show:YES];
}

- (void) nextButtonAction:(id)sender
{
    NSLog(@"nextButtonAction");
    if (selectCertificateImage==false) {
        alertMsg(@"请选择行驶证车辆照片");
        return;
    }else{
        //_userInfo.certificateImage = certificateImageView.image;
    }
    if (certificateNoTextField.text==nil||certificateNoTextField.text.length==0) {
        alertMsg(@"请输入发动机号");
        return;
    }else{
        _userInfo.certificateNo = certificateNoTextField.text;
    }
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    loadingView.labelText = @"请稍后";
    [self.view addSubview:loadingView];
    [loadingView show:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navigationItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳过认证" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonActionWithoutCertificate:)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(notice_x, notice_y, ScreenWidth-40, notice_height)];
    label.text = @"请上传行驶证第一页包含发动机号的车辆照片，我们承诺图片仅用于车型认证，如不认证可跳过此项";
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;//表示label可以多行显示
    [self.view addSubview:label];
    
    
    //行驶证上传
    certificateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(certificateImage_x, certificateImage_y, ScreenWidth-2*20, certificateImageHeight)];
    certificateImageView.image = [UIImage imageNamed:@"xingshizheng.png"];
    certificateImageView.contentMode =  UIViewContentModeScaleAspectFit;
    
    certificateImageView.layer.cornerRadius = 6.0;
    certificateImageView.layer.masksToBounds = YES;
    certificateImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickCertificateImage:)];
    [certificateImageView addGestureRecognizer:singleTap];
    [self.view addSubview: certificateImageView];
    
    
    certificateNoTextField = [[TextFieldView alloc] initWithFrame:CGRectMake(certificateNo_x, certificateNo_Y, (ScreenWidth - 2*20)/2, certificateNo_height)];
    certificateNoTextField.placeholder = @"发动机号";
    certificateNoTextField.layer.cornerRadius = 6.0;
    certificateNoTextField.layer.masksToBounds = YES;
    certificateNoTextField.layer.borderWidth = 0.3;
    certificateNoTextField.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.view addSubview: certificateNoTextField];
    
    
    //选择车型按钮
    selectCarType = [[UILabel alloc] init];
    selectCarType.frame = CGRectMake(certificateNo_x+(ScreenWidth - 2*20)/2+50, certificateNo_Y, (ScreenWidth - 2*20)/3, certificateNo_height);
    selectCarType.text = @"选择车型";
    selectCarType.textColor = subjectColor;
    selectCarType.userInteractionEnabled = YES;
    singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickSelectCarType:)];
    [selectCarType addGestureRecognizer:singleTap];
    
    [self.view addSubview: selectCarType];
    
    //下一步
    UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(registerButton_x, registerButton_y, ScreenWidth - 2*registerButton_x, certificateNo_height);
    nextButton.backgroundColor = subjectColor;
    nextButton.layer.cornerRadius = 6;
    nextButton.layer.masksToBounds = YES;
    [nextButton setTitle:@"注册" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:nextButton];

    
    //NSLog(@"%@", userInfo.nickName);
    // Do any additional setup after loading the view.
}

- (void)onClickSelectCarType:(id)sender
{
    NSLog(@"onClickSelectCarType");
    UINavigationController* rootCarSelectListNav = [[UINavigationController alloc] initWithRootViewController:[[CarSelectListTableViewController alloc] init]];
    rootCarSelectListNav.navigationBar.barTintColor = subjectColor;
    rootCarSelectListNav.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:rootCarSelectListNav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
