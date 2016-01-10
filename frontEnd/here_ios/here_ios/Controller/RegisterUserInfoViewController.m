//
//  RegisterUserInfoViewController.m
//  CarSocial
//
//  Created by wang jam on 8/29/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "RegisterUserInfoViewController.h"
#import "Constant.h"
#import "TextFieldView.h"
#import "RegisterPhoneNumViewController.h"
#import "RegisterCellViewTableViewCell.h"
#import "Tools.h"

@interface RegisterUserInfoViewController ()
{
    TextFieldView* birthday;
    TextFieldView* gender;
    UITableView* tableView;
    UIImageView* cameraImageView;
    UIActionSheet *sheet;
    
    UIDatePicker *datePicker;
    
    BOOL genderSelect;
    BOOL ageSelect;
    BOOL faceSelect;
}
@end

@implementation RegisterUserInfoViewController


static const int camera_y = 44;
static const int camera_width = 78;
static const int camera_height = 78;

static const int selectField_x = 0;
static const int selectField_y = 160;
static const int selectHeight = 44;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userInfo = [[UserInfoModel alloc] init];
        genderSelect = false;
        ageSelect = false;
        faceSelect = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    [navTitle setText:@"个人资料"];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = navTitle;
    
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep:)];
    
    
//    cameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-camera_width)/2, camera_y, camera_width, camera_height)];
//    cameraImageView.image = [UIImage imageNamed:@"camera178*144.png"];
//    cameraImageView.userInteractionEnabled = YES;
//    cameraImageView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickFaceThumnail:)];
//    [cameraImageView addGestureRecognizer:singleTap];
    
    
    UILabel* cameraLabel = [[UILabel alloc] init];
    cameraLabel.text = @"个人头像";
    cameraLabel.font = [UIFont fontWithName:@"Arial" size:15];
    cameraLabel.textColor = [UIColor grayColor];
    cameraLabel.textAlignment = NSTextAlignmentCenter;
    cameraLabel.frame = CGRectMake(10, cameraImageView.frame.origin.y+cameraImageView.frame.size.height+10, 120, 20);
    cameraLabel.center = CGPointMake(cameraImageView.center.x, cameraLabel.center.y);
    
    [self.view addSubview:cameraLabel];
    
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(selectField_x, selectField_y, ScreenWidth, selectHeight*2-1)];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self.view addSubview:tableView];

    [self.view addSubview:cameraImageView];
    
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"女",@"男", nil];
    
    
    
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenHeight-260, ScreenWidth, 220)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = YES;
    
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.view addSubview:datePicker];
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
    
    UITableViewCell* cell =  [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.textLabel.text = dateDesc;
    _userInfo.age = [curComponents year] - year;
    _userInfo.birthday = dateDesc;
    ageSelect = true;
}

- (void)nextStep:(id)sender
{
    
    if (genderSelect == false) {
        [Tools AlertBigMsg:@"请选择性别"];
        return;
    }
    
    if (ageSelect == false) {
        [Tools AlertBigMsg:@"请选择出生日"];
        return;
    }
    
    if (faceSelect == false) {
        [Tools AlertBigMsg:@"请上传个人头像"];
        return;
    }
    
    if (faceSelect==true&&genderSelect==true&&ageSelect==true) {
        RegisterPhoneNumViewController* registerPhone = [[RegisterPhoneNumViewController alloc] init];
        registerPhone.userInfo = _userInfo;
        [self.navigationController pushViewController:registerPhone animated:YES];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"did select picture");
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    

    
    
    cameraImageView.image = aImage;
    [cameraImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    cameraImageView.contentMode =  UIViewContentModeScaleAspectFill;
    cameraImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cameraImageView.clipsToBounds  = YES;
    cameraImageView.layer.cornerRadius = 6.0;
    _userInfo.faceImage = cameraImageView.image;
    faceSelect = YES;
}

- (void)onClickFaceThumnail:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    NSLog(@"onClickFaceThumnail");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    datePicker.hidden = YES;
    if (indexPath.row == 0) {
        datePicker.hidden = NO;
    }
    if (indexPath.row == 1) {
        [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet == sheet) {
        NSLog(@"Button %ld", buttonIndex);
        UITableViewCell* cell =  [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        if (buttonIndex == 0) {
            cell.textLabel.text = @"女";
            genderSelect = YES;
            _userInfo.gender = buttonIndex;
        }
        if (buttonIndex==1) {
            cell.textLabel.text = @"男";
            genderSelect = YES;
            _userInfo.gender = buttonIndex;
        }
    }
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RegisterCellViewTableViewCell* cell = [[RegisterCellViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCell"];
//    cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 24, 24);
    
    //cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (indexPath.row==0) {
        cell.textLabel.text = @"请选择出生日";
        cell.imageView.image = [UIImage imageNamed:@"birthday64px.png"];
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"请选择性别";
        cell.imageView.image = [UIImage imageNamed:@"sexselect64px.png"];
        NSLog(@"%f", cell.imageView.bounds.size.width);
        NSLog(@"%f", cell.imageView.bounds.size.height);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)birthdayAction:(id)sender
{
    NSLog(@"birthdayAction");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"registeruserinfo delloc");
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
