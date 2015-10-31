//
//  PublishActivityViewController.m
//  CarSocial
//
//  Created by wang jam on 11/20/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "PublishContentViewController.h"
#import "Constant.h"
#import "TextFieldView.h"
#import "AppDelegate.h"
#import "NetWork.h"
#import "macro.h"
#import "ContentModel.h"
#import "Tools.h"

//#import <QBImagePickerController/QBImagePickerController.h>


@interface PublishContentViewController ()
{
    UITableView* tableView;
    TextFieldView* commentTextField;
    TextFieldView* destinationTextField;
    
    UIDatePicker *datePicker;
    UIPickerView *countPickerView;
    
    NSArray* countPickerArray;
    MBProgressHUD* loadingView;
    MBProgressHUD* feedbackTextView;
    
    int activeTimestamp;
    
    ContentModel* activeMode;
    
    UITextView* contentTextView;
    
    BOOL addImage;
    UIImageView* addImageview;
    UISwitch* anonymousSwitch;
    
    UILabel* placeholder;
    
    CGFloat oldOffset;
    CLLocationManager* locationManager;
    
    NSString* cityDesc;
    
    NSMutableArray* imageArray;
}
@end

@implementation PublishContentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = activeViewControllerbackgroundColor;
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    UIBarButtonItem *leftitem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(navigationBackButton:)];
    
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publishContentButton:)];
    
    
    
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@""];
    
    navigationBarTitle.leftBarButtonItem = leftitem;
    navigationBarTitle.rightBarButtonItem = rightitem;
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [navTitle setTextColor:[UIColor whiteColor]];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];

    navigationBarTitle.titleView = navTitle;
    
    
    [navigationBar setItems:[NSArray arrayWithObject: navigationBarTitle]];
    navigationBar.backgroundColor = [UIColor blackColor];
    navigationBar.barTintColor = [UIColor blackColor];
    navigationBar.tintColor = [UIColor whiteColor];
    
    [self.view addSubview: navigationBar];
    //self.view.userInteractionEnabled = YES;
    
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.origin.y+navigationBar.frame.size.height, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    
    [self.view addSubview:tableView];
    
    
    UIView* mainView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.origin.y+navigationBar.frame.size.height, ScreenWidth, 210)];
    mainView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:mainView];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, ScreenWidth - 20, 100)];
    contentTextView.font = [UIFont fontWithName:@"Arial" size:18];
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 120, 32)];
    placeholder.text = @"此刻的想法";
    placeholder.backgroundColor = [UIColor clearColor];
    placeholder.enabled = NO;
    [contentTextView addSubview:placeholder];
    contentTextView.delegate = self;
    
    
    [mainView addSubview:contentTextView];
    
    addImageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, contentTextView.frame.origin.y+contentTextView.frame.size.height+10, 73.75, 73.75)];
    addImageview.userInteractionEnabled = YES;
    addImageview.image = [UIImage imageNamed:@"addImage49px.png"];
    addImageview.layer.borderWidth = 0.5;
    addImageview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    addImageview.contentMode = UIViewContentModeScaleAspectFill;
    addImageview.clipsToBounds = YES;
    addImageview.backgroundColor = [UIColor clearColor];
    
    
    [mainView addSubview:addImageview];
    
    [addImageview addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAddImageViewAction:)]];
    
    addImage = false;
    
    tableView.tableHeaderView = mainView;
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    
    //匿名发送按钮
//    UIView* firstSeperateLine = [[UIView alloc] initWithFrame:CGRectMake(10, addImageview.frame.origin.y+addImageview.frame.size.height+10, ScreenWidth - 10, 0.5)];
//    firstSeperateLine.backgroundColor = sepeartelineColor;
//    [mainView addSubview:firstSeperateLine];
//    
//    UILabel* anonymousLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, firstSeperateLine.frame.origin.y, 80, 36)];
//    anonymousLabel.text = @"匿名发送";
//    anonymousLabel.textColor = [UIColor grayColor];
//    anonymousLabel.font = [UIFont fontWithName:@"Arial" size:18];
//    [mainView addSubview:anonymousLabel];
//    
//    anonymousSwitch = [[ UISwitch alloc]initWithFrame:CGRectMake(ScreenWidth/5*4,anonymousLabel.frame.origin.y+5,0.0,0.0)];
//    [mainView addSubview:anonymousSwitch];
//    
//    [contentTextView becomeFirstResponder];
//
    
    
    anonymousSwitch = [[ UISwitch alloc]initWithFrame:CGRectMake(ScreenWidth/5*4, 0, 0.0 ,0.0)];
    
    
    
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView hide:YES];
//
    feedbackTextView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:feedbackTextView];
    feedbackTextView.mode = MBProgressHUDModeText;
    [feedbackTextView hide:YES];
//
    feedbackTextView.delegate = self;
    _address = @"";
    cityDesc = @"";
    
    //获取用户地理信息
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled] == false) {
        alertMsg(@"定位服务无法使用");
        return;
    }
    
    [locationManager setDelegate:self];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5.0f;
    //[locationManager startUpdatingLocation];
    [Tools startLocation:locationManager];
    
    imageArray = [[NSMutableArray alloc] init];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    alertMsg(@"无法获取地理位置信息可能导致相关功能不可用");
    
    
    [locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    //[loadingView stopAnimating];
    
    
    [locationManager stopUpdatingLocation];
    
    CLLocation* newLocation = [locations lastObject];
    
    //CLLocation* newLocation = [[CLLocation alloc] initWithLatitude:34.0307 longitude:-118.1434];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    app.myInfo.latitude = newLocation.coordinate.latitude;
    app.myInfo.longitude = newLocation.coordinate.longitude;
    
    //newLocation.coordinate.latitude = 34.0307;
    //newLocation.coordinate.longitude = -118.1434;
    
    
    
    //app.myInfo.latitude = 34.0307;
    //app.myInfo.longitude = -118.1434;
    
    //ios get city by latitude and longitude
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark* placemark in placemarks) {
            NSString* test = [placemark locality];
            NSLog(@"%@", test);
            cityDesc = [placemark administrativeArea];
            
            _address = [NSString stringWithFormat:@"%@·%@·%@", [placemark country], [placemark administrativeArea], [placemark subLocality]];
        }
        
        [tableView reloadData];
        
    }];
    
    
    
    
//    searchLocation = [[AMapSearchAPI alloc] initWithSearchKey:gaodeKey Delegate:self];
//    
//    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
//    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//    regeoRequest.searchType = AMapSearchType_ReGeocode;
//    
//    regeoRequest.location = [AMapGeoPoint locationWithLatitude:app.myInfo.latitude longitude:app.myInfo.longitude];
//    regeoRequest.radius = 200;
//    regeoRequest.requireExtension = YES;
//    
//    //发起逆地理编码
//    [searchLocation AMapReGoecodeSearch: regeoRequest];
}

////实现逆地理编码的回调函数
//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    
//    if(response.regeocode != nil){
//        //通过AMapReGeocodeSearchResponse对象处理搜索结果
//        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
//        NSLog(@"ReGeo: %@", result);
//        NSLog(@"%@", response.regeocode.addressComponent.province);
//        NSLog(@"%@", response.regeocode.addressComponent.city);
//        NSLog(@"%@", response.regeocode.addressComponent.building);
//        
//        //        AMapPOI* noChoose = [[AMapPOI alloc] init];
//        //        noChoose.name = @"未选择";
//        //        [addrArray addObject:noChoose];
//        
//        AMapPOI* cityPoint = [[AMapPOI alloc] init];
//        cityPoint.name = [[NSString alloc] initWithFormat:@"%@%@", response.regeocode.addressComponent.province, response.regeocode.addressComponent.city];
//        _address = cityPoint.name;
//        cityDesc = cityPoint.name;
//    }
//    
//    [tableView reloadData];
//    
//    //[searchLocation am]
//}


- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error.domain);
    alertMsg(error.domain);
}



- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        placeholder.text = @"此刻的想法";
    }else{
        placeholder.text = @"";
    }
}

- (void)clickAddImageViewAction:(UITapGestureRecognizer*)sender
{
    
    
//    QBImagePickerController *imagePickerController = [QBImagePickerController new];
//    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = YES;
//    imagePickerController.maximumNumberOfSelection = 3;
//    imagePickerController.showsCancelButton = YES;
//    imagePickerController.showsNumberOfSelectedAssets = YES;
//    
//    [self presentViewController:imagePickerController animated:YES completion:NULL];
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}


//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
//    
////    for (PHAsset *asset in assets) {
////        // Do something with the asset
////    }
//    
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}


//- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色

    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    
    
    addImage = true;
    
    UIImageView* imageview = [[UIImageView alloc] init];
    imageview.frame = addImageview.frame;
    imageview.clipsToBounds = YES;
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    [tableView.tableHeaderView addSubview:imageview];
    
    if (aImage.size.width>aImage.size.height) {
        imageview.image = [Tools scaleToSize:aImage size:CGSizeMake(aImage.size.width*2*imageview.frame.size.height/aImage.size.height, 2*imageview.frame.size.height)];

    }else{
        imageview.image = [Tools scaleToSize:aImage size:CGSizeMake(2*imageview.frame.size.width, aImage.size.height*2*imageview.frame.size.width/aImage.size.width)];
    }
    
    
    [imageArray addObject:aImage];
    
    if ([imageArray count] >= 3) {
        addImageview.hidden = YES;
    }else{
        addImageview.frame = CGRectMake(addImageview.frame.origin.x+addImageview.frame.size.width+5, addImageview.frame.origin.y, addImageview.frame.size.width, addImageview.frame.size.height);
        
        addImageview.layer.borderWidth = 0.5;
        addImageview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    
    
    
    //addImageview.image = aImage;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    [tableView reloadData];
}

- (void)publishContentButton:(id)sender
{
    NSString* content = contentTextView.text;
    if (([content isEqualToString: @""]||content == nil)&&addImage == false) {
        return;
    }
    
    int anonymous = 0;
    if (anonymousSwitch.on) {
        anonymous = 1;
    }
    
    
    
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary* images = [[NSMutableDictionary alloc] init];
    int addImageCount = (int)[imageArray count];
    
    for (int i=0; i<[imageArray count]; ++i) {
        [images setObject:[imageArray objectAtIndex:i] forKey:[[NSString alloc] initWithFormat:@"content_image_%d", i]];
    }
        
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[app.myInfo.userID, content, [[NSNumber alloc] initWithDouble:app.myInfo.latitude], [[NSNumber alloc] initWithDouble:app.myInfo.longitude], [[NSNumber alloc] initWithInt:anonymous], [[NSNumber alloc] initWithInt:addImageCount], _address, cityDesc, @"/publishContent"] forKeys:@[@"user_id", @"content", @"publish_latitude", @"publish_longitude", @"anonymous", @"imageCount", @"address", @"cityDesc", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(publishActiveSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(publishActiveError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(publishException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    [loadingView show:YES];
    [netWork message:message images:images feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
    } callObject:self];
}


- (void)publishException:(id)sender
{
    alertMsg(@"未知错误");
}

- (void)publishActiveError:(id)sender
{
    alertMsg(@"发布失败");
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud == feedbackTextView) {
        [self dismissViewControllerAnimated:YES completion:^{
            
            //AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            //[app.sideMenu closeMenuAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pullDown" object:nil];
        }];
    }
}

- (void)publishActiveSuccess:(id)sender
{
    NSLog(@"publishActiveSuccess");
    feedbackTextView.labelText = @"发布成功";
    [feedbackTextView show:YES];
    [feedbackTextView hide:YES afterDelay:2.0];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [countPickerArray count];
    
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [countPickerArray objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"select");
    //UITableViewCell* cell =  [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    //cell.detailTextLabel.text = [countPickerArray objectAtIndex:row];
}



- (void)BackgroundViewButtonAction:(id)sender
{
    [destinationTextField resignFirstResponder];
    [commentTextField resignFirstResponder];
    datePicker.hidden = YES;
    countPickerView.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    if (section == 1) {
        return 2;
    }

    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y>oldOffset&&scrollView == tableView) {
        [contentTextView resignFirstResponder];
    }
    oldOffset = scrollView.contentOffset.y;
}


- (void)tableView:(UITableView *)tableViewed didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    datePicker.hidden = YES;
//    if (indexPath.row == 0) {
//        datePicker.hidden = NO;
//    }
    
    
    [tableViewed deselectRowAtIndexPath:[tableViewed indexPathForSelectedRow] animated:YES];

    NSLog(@"enter didSelectRowAtIndexPath");
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        return;
        
        //[sheet showInView:self.view];
        
        
        //LocationListViewController* locationList = [[LocationListViewController alloc] init];
        //locationList.parentViewCtrl = self;
        
        //[self presentViewController:locationList animated:YES completion:nil];
        
    }
    
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *smallCellIdentifier = @"smallCellIdentifier";
    
    UITableViewCell* cell = nil;
    if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:smallCellIdentifier];
    }
    
    if (indexPath.row == 0 && indexPath.section == 1) {
        cell.textLabel.text = @"匿名发布";
        
        anonymousSwitch.frame = CGRectMake(ScreenWidth/5*4, (cell.frame.size.height - anonymousSwitch.frame.size.height)/2, 0.0, 0.0);
        [cell.contentView addSubview:anonymousSwitch];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if(indexPath.row == 1 && indexPath.section == 1){
        cell.textLabel.text = @"地点";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (_address!=nil) {
            cell.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:14];
            cell.detailTextLabel.textColor = subjectColor;
            cell.detailTextLabel.text = _address;
        }
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    return cell;
    
}

- (void)navigationBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
