//
//  Constant.h
//  miniWeChat
//
//  Created by wang jam on 5/5/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#ifndef miniWeChat_Constant_h
#define miniWeChat_Constant_h

#define RoyalBlue [UIColor colorWithRed:65.0/255.0 green:105.0/255.0 blue:225/255.0 alpha:1.0]
#define CornflowerBlue [UIColor colorWithRed:100.0/255.0 green:149.0/255.0 blue:237/255.0 alpha:1.0]


#define OurBlue [UIColor colorWithRed:49.0/255.0 green:117.0/255.0 blue:181.0/255.0 alpha:1.0]

#define activeViewControllerbackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]


#define bottomBackgroundColor [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0]



#define genderPink [UIColor colorWithRed:233/255.0 green:107/255.0 blue:160/255.0 alpha:1.0]


#define tabbarBackgroundColor [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0]

#define sepeartelineColor activeViewControllerbackgroundColor


#define layerColor [UIColor colorWithRed:224/255.0 green:220/255.0 blue:217/255.0 alpha:1.0]

#define myblack [UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1.0]

#define subjectColor OurBlue




#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height



#define alertMsg(x) MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];hud.mode = MBProgressHUDModeText;hud.labelText = x;hud.removeFromSuperViewOnHide = YES;[hud hide:YES afterDelay:2];

#define alertMsgByView(x) MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];hud.mode = MBProgressHUDModeText;hud.labelText = x;hud.removeFromSuperViewOnHide = YES;[hud hide:YES afterDelay:2];


#define alertMsgParent MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_parentViewController animated:YES];hud.mode = MBProgressHUDModeText;hud.labelText = x;hud.removeFromSuperViewOnHide = YES;[hud hide:YES afterDelay:2];


#define alertMsgFromView(x, id) UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"消息" message: x delegate: id cancelButtonTitle:nil otherButtonTitles:@"OK",nil]; [alert show];


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



#ifdef DEBUG
#define SocketIP @"112.74.102.178"
#define SocketPort 10666
#else
#define SocketIP @"123.57.229.67"
#define SocketPort 10666
#endif


#ifdef DEBUG
#define ServerDomain @"http://112.74.102.178:8080"
#else
#define ServerDomain @"http://123.57.229.67:8080"
#endif


//ad version
//#define gaodeKey @"6c9781e21fe0aacac37199da85548ec2"

//dev version
#define gaodeKey @"b72db2635a1fac3e3b89a2bea45f8a13"



#define totalLocationTryCount 6


#endif
