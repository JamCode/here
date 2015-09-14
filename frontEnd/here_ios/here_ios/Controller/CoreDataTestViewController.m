//
//  CoreDataTestViewController.m
//  CarSocial
//
//  Created by wang jam on 9/26/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "CoreDataTestViewController.h"
#import "LocDatabase.h"
#import "Pri_msg.h"
#import "PriMsgModel.h"

@interface CoreDataTestViewController ()
{
    LocDatabase* locDatabase;
}
@end

@implementation CoreDataTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(50, 100, 64, 64);
    
    loginButton.backgroundColor = [UIColor blackColor];
    loginButton.layer.cornerRadius = 6;
    
    [loginButton setTitle:[[NSString alloc] initWithFormat:@"插入"] forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [loginButton addTarget:self action:@selector(insert:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
    UIButton* otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.frame = CGRectMake(150, 100, 64, 64);
    
    otherButton.backgroundColor = [UIColor blackColor];
    otherButton.layer.cornerRadius = 6;
    
    [otherButton setTitle:[[NSString alloc] initWithFormat:@"获取"] forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [otherButton addTarget:self action:@selector(get:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherButton];
    
    locDatabase = [[LocDatabase alloc] init];
    
}

- (void)insert:(id)sender
{
    if([locDatabase connectToDatabase]==false){
        NSLog(@"connect database failed");
        return;
    }
    PriMsgModel* msgModel = [[PriMsgModel alloc] init];
    //msgModel.sender_user_id = @"12345";
    //msgModel.receive_user_id = @"67890";
    msgModel.message_content = @"testetest";
    msgModel.send_timestamp = [[NSDate date] timeIntervalSince1970];
    
    
    [locDatabase writePriMsgToDatabase:msgModel];
}

- (void)get:(id)sender
{
    if([locDatabase connectToDatabase]==false){
        NSLog(@"connect database failed");
        return;
    }
    
//    NSArray* msgArray = [locDatabase readPriMsgBySenderID:@"12345" ReceiveID:@"67890" MinTimeStamp:[[NSDate date] timeIntervalSince1970] LimitCount:10];
    
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
