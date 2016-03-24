//
//  TalkViewController.m
//  miniWeChat
//
//  Created by wang jam on 5/12/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "TalkViewController.h"
#import "Constant.h"
#import "TalkTableViewCell.h"
#import "macro.h"
#import "PriMsgModel.h"
#import "LocDatabase.h"
#import "TalkTimeTableViewCell.h"
#import <MBProgressHUD.h>
#import "NetWork.h"
#import "FriendMsgMode.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "NSString+Emojize.h"
#import "Tools.h"
#import "MessageTableViewController.h"
#import "Waver.h"
#import <AVFoundation/AVFoundation.h>
#import "CocoaSecurity.h"
#import "Mp3Recorder.h"
#import "ConfigAccess.h"
#import "AESCrypt.h"


@interface TalkViewController ()
{
    UITextView* myTextField;
    UIButton* microSendButton;
    
    UITableView* talkTableView;
    UIToolbar* bottomToolbar;
    LocDatabase* locDatabase;
    NSMutableArray* priMsgList;
    
    CGRect curBottomBarFrame;
    CGRect curTableViewFrame;
    
    CGFloat keyboardHeight;
    UIActivityIndicatorView* loading;
    BOOL updatingTalkMessage;
    UserInfoModel* myInfo;
    BOOL getMissedMsg;
    UIActivityIndicatorView* activeView;
    UILabel *navTitle;
    SocketIO* mysocket;
    //NSInteger reconnectCount;
    BOOL firstloading;
    UIActionSheet *sheet;
    MBProgressHUD* loadingView;
    
    UIView* backView;
    
    Waver* waver;
    Mp3Recorder* mp3Recorder;
    double voiceTime;
    
    NSTimer* timer;
    //UIButton* addButton;
    //UIButton* microButton;
    //UIButton* microSendButton;
    
}
@end

@implementation TalkViewController

static const double bottomToolbarHeight = 49;
static const int fontSize = 16;

static const double textViewHeidght = 36;
static const double textViewWidth = 250;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _counterInfo = [[UserInfoModel alloc] init];
        getMissedMsg = false;
    }
    return self;
}

- (void)BackgroundViewButtonAction:(id)sender
{
    [myTextField resignFirstResponder];
}


- (UITableView*)getTableView
{
    return talkTableView;
}


- (void)initTextField
{
    bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight-bottomToolbarHeight, ScreenWidth, bottomToolbarHeight)];
    [bottomToolbar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [bottomToolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    bottomToolbar.backgroundColor = activeViewControllerbackgroundColor;
    
    
    myTextField = [[UITextView alloc] init];
    myTextField.delegate =self;
    
    myTextField.frame = CGRectMake(0, 0, ScreenWidth - 2*55, textViewHeidght);
    myTextField.returnKeyType = UIReturnKeyDone;//设置返回按钮的样式
    myTextField.keyboardType = UIKeyboardTypeDefault;//设置键盘样式为默认
    myTextField.font = [UIFont fontWithName:@"Arial" size:fontSize];
    myTextField.scrollEnabled = YES;
    myTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    myTextField.layer.cornerRadius = 4.0;
    myTextField.layer.borderWidth = 0.5;
    myTextField.layer.borderColor = sepeartelineColor.CGColor;
    
    
    microSendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    microSendButton.frame = CGRectMake(0, 0, ScreenWidth - 2*55, textViewHeidght);
    [microSendButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [microSendButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    microSendButton.layer.borderWidth = 0.3;
    microSendButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    microSendButton.layer.cornerRadius = 4.0;
    
    //实例化长按手势监听
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(microSendButtonClick:)];
    //代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.1;
    //将长按手势添加到需要实现长按操作的视图里
    [microSendButton addGestureRecognizer:longPress];
    
    
    [self.view addSubview:bottomToolbar];
    
}

- (void)showWave
{
    [mp3Recorder startRecord];
    
    //[self setupRecorder];
    
    waver = [[Waver alloc] initWithFrame:CGRectMake(0, ScreenHeight/2+30, CGRectGetWidth(self.view.bounds), 100)];
    
    waver.waverLevelCallback = ^(Waver * waver_temp) {
        
        [mp3Recorder updateMeters];
        //[_recorder updateMeters];
        CGFloat normalizedValue = pow (10, [mp3Recorder averagePowerForChannel:0] / 40);
        
        waver_temp.level = normalizedValue;
        
    };
    
    [backView addSubview:waver];
}

- (void)dismissWave
{
    [waver removeFromSuperview];
    waver = nil;
    
    //double curTime = _recorder.currentTime;
    //[_recorder stop];
    //[_recorder deleteRecording];
    
}


- (void)failRecord
{
    NSLog(@"fail record");
}

- (void)beginConvert
{
    NSLog(@"begin convert");
}

- (void)updateVoiceMsg
{
    NSLog(@"ltet");
}

- (void)endConvertWithData:(NSData *)voiceData
{
    NSLog(@"endConvertWithData");
    
    
    //send voice to server
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        PriMsgModel* priMsgModel = [[PriMsgModel alloc] init];
        priMsgModel.data = voiceData;
        priMsgModel.msg_type = VOICEMSG;
        priMsgModel.send_timestamp = [[NSDate date] timeIntervalSince1970];
        priMsgModel.sender_user_id = myInfo.userID;
        priMsgModel.receive_user_id = _counterInfo.userID;
        priMsgModel.msg_id = NULL;
        priMsgModel.voiceTime = voiceTime;
        priMsgModel.sendStatus = SENDING;
        CocoaSecurityResult *md5 = [CocoaSecurity md5:[[NSString alloc] initWithFormat:@"%@%@%ld", priMsgModel.sender_user_id, priMsgModel.receive_user_id, (long)priMsgModel.send_timestamp]];
        priMsgModel.msg_srno = md5.hex;
        
        [self writePriMsgToLocalDatabase:priMsgModel];
        [self sendDataToServer:priMsgModel];
        [self updateChatList];
        
    });
}

- (void)microSendButtonClick:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        //mp3Recorder.delegate = self;
        backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        backView.backgroundColor = [UIColor clearColor];
        [backView setAlpha:0.0];
        [self.view addSubview:backView];
        
        UIImageView* talkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speaking.png"]];
        talkIcon.frame = CGRectMake(0, 0, 75, 75);
        talkIcon.center = backView.center;
        [backView addSubview:talkIcon];
        
        
        
        [UIView animateWithDuration:0.1 animations:^{
            microSendButton.backgroundColor = [UIColor grayColor];
            [microSendButton setTitle:@"松开结束" forState:UIControlStateNormal];
            backView.backgroundColor = [UIColor darkGrayColor];
            [backView setAlpha:0.5];
            [self showWave];

        } completion:^(BOOL finished) {
            if (finished) {
                
                //[UUProgressHUD show];
                
            }
        }];
    }
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        
        [UIView animateWithDuration:0.1 animations:^{
            [microSendButton setTitle:@"按住说话" forState:UIControlStateNormal];
            microSendButton.backgroundColor = [UIColor clearColor];
            [backView setAlpha:0.0];
            [self dismissWave];
            
        } completion:^(BOOL finished) {
            if (finished) {
                //[UUProgressHUD dismissWithSuccess:@""];
                [backView removeFromSuperview];
                backView = nil;
                
                //send voice
                voiceTime =  [mp3Recorder stopRecord];
            }
        }];
    }
}

- (void)clickMicroButton:(id)sender
{
    UIBarButtonItem* textfieldButtonItem =[[UIBarButtonItem alloc] initWithCustomView:microSendButton];
    
    //UIBarButtonItem* rightButtonItem =[[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    UIButton* writeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [writeButton setBackgroundImage:[UIImage imageNamed:@"written.png"] forState:UIControlStateNormal];
    [writeButton setShowsTouchWhenHighlighted:YES];
    [writeButton addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:writeButton];

    UIButton* addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [addButton setShowsTouchWhenHighlighted:YES];
    [addButton addTarget:self action:@selector(clickImageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightButtonItem =[[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    
    [bottomToolbar setItems:[NSArray arrayWithObjects:leftButtonItem, textfieldButtonItem, rightButtonItem, nil] animated:YES];
    
    //[myTextField resignFirstResponder];
    
    
}

- (void)clickWriteButton:(id)sender
{
    
    UIButton* addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [addButton setShowsTouchWhenHighlighted:YES];
    [addButton addTarget:self action:@selector(clickImageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightButtonItem =[[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    UIButton* microButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [microButton setBackgroundImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal];
    [microButton setShowsTouchWhenHighlighted:YES];
    [microButton addTarget:self action:@selector(clickMicroButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem* leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:microButton];
    
    UIBarButtonItem* textfieldButtonItem =[[UIBarButtonItem alloc] initWithCustomView:myTextField];
    NSArray *textfieldArray=[[NSArray alloc]initWithObjects:leftButtonItem, textfieldButtonItem,rightButtonItem, nil];
    
    [bottomToolbar setItems:textfieldArray animated:YES];
    
    if (sender != nil) {
        [myTextField becomeFirstResponder];
    }

}

-(void)setupRecorder
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
    
    [_recorder prepareToRecord];
    [_recorder setMeteringEnabled:YES];
    [_recorder record];
    
}


- (void)getMsgFromDatabase:(NSNumber*)minTimeStamp
{
    [priMsgList removeObjectAtIndex:0];
    NSArray* tempArray = [locDatabase readPriMsgByUserID:myInfo.userID otherUserID:_counterInfo.userID MinTimeStamp:[minTimeStamp intValue] LimitCount:12];
    
    if ([tempArray count]>0) {
        [priMsgList addObjectsFromArray:tempArray];
        NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[tempArray count] inSection:0];
        
        priMsgList = [self sortMsg:priMsgList];
        [talkTableView reloadData];
        [talkTableView selectRowAtIndexPath:curIndex animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }else{
        [talkTableView reloadData];
    }
    updatingTalkMessage = false;
}

- (NSMutableArray*)sortMsg:(NSMutableArray*)msgArray
{
    
    NSArray* tempArray =  [msgArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PriMsgModel* priMsg1 = obj1;
        PriMsgModel* priMsg2 = obj2;
        
        if (priMsg1.send_timestamp<priMsg2.send_timestamp) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    
    return [[NSMutableArray alloc] initWithArray:tempArray];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange：%@", textView.text);
    
    
    CGSize size = [Tools getTextArrange:textView.text maxRect:CGSizeMake(textViewWidth, 400) fontSize:16];
    
    NSLog(@"%f", size.height);
    NSLog(@"textview height %f", textView.frame.size.height);
    
    
    //需要增加或减少的高度
    
    CGSize addsize = [Tools getTextArrange:@"height" maxRect:CGSizeMake(textViewWidth, 400) fontSize:16];
    
    
//    if (size.height == 0) {
//        //清空的话，新size为一行的高度
//        size = addsize;
//    }
    
    if (size.height>textView.bounds.size.height&&textView.bounds.size.height<textViewHeidght*3) {
        
        CGFloat resizeHeight = MIN(size.height, textViewHeidght*3);
        CGFloat increaseHeight = ABS(resizeHeight - myTextField.frame.size.height+14);

        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        
        // set views with new info
        
        [bottomToolbar setFrame:CGRectMake(bottomToolbar.frame.origin.x, bottomToolbar.frame.origin.y - increaseHeight, bottomToolbar.frame.size.width, bottomToolbar.frame.size.height + increaseHeight)];
        [talkTableView setFrame:CGRectMake(talkTableView.frame.origin.x, talkTableView.frame.origin.y - increaseHeight, talkTableView.frame.size.width, talkTableView.frame.size.height)];
        
        // commit animations
        [UIView commitAnimations];

        NSLog(@"increase");
    }
    
    NSLog(@"%f", textView.bounds.size.height);
    
    if (size.height<textView.bounds.size.height-addsize.height) {
        NSLog(@"%f", size.height);
        
        if (size.height <= addsize.height) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            
            [bottomToolbar setFrame:curBottomBarFrame];
            [talkTableView setFrame:curTableViewFrame];
            [UIView commitAnimations];
        }else{
            CGFloat resizeHeight = MIN(size.height, textViewHeidght*3);
            CGFloat increaseHeight = ABS(resizeHeight - myTextField.frame.size.height+14);
            
            CGFloat newbottomHeight = MAX(bottomToolbar.frame.size.height - increaseHeight, bottomToolbarHeight);
            CGFloat newbottom_y = MIN(bottomToolbar.frame.origin.y + increaseHeight, ScreenHeight-bottomToolbarHeight);
            CGFloat newTalk_y = MIN(talkTableView.frame.origin.y + increaseHeight, 0);
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [bottomToolbar setFrame:CGRectMake(bottomToolbar.frame.origin.x, newbottom_y, bottomToolbar.frame.size.width, newbottomHeight)];
            [talkTableView setFrame:CGRectMake(talkTableView.frame.origin.x, newTalk_y, talkTableView.frame.size.width, talkTableView.frame.size.height)];
            
            [UIView commitAnimations];

        }
        NSLog(@"reduce");
    }
    
}



- (void)initTalkTableView
{
    if (talkTableView == nil) {
        talkTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - bottomToolbarHeight)];
        talkTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //talkTableView.backgroundColor = activeViewControllerbackgroundColor;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BackgroundViewButtonAction:)];
        [talkTableView addGestureRecognizer:tapGesture];
        
        [talkTableView setDelegate:self];
        [talkTableView setDataSource:self];
        [self.view addSubview:talkTableView];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification{
    
    //tableview 滚动到最后
    NSLog(@"%f", talkTableView.contentSize.height);
    NSLog(@"%f", talkTableView.bounds.size.height);
    [self scrollToBottom:NO addition:0];
    
    
    
    NSLog(@"keyboardWillShow");
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardHeight = keyboardBounds.size.height;
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    
    CGRect tableFrame = talkTableView.frame;
    
    CGFloat tableHeight = MIN(talkTableView.bounds.size.height, talkTableView.contentSize.height);
    
    CGRect bottomFrame = bottomToolbar.frame;
    
    if (tableHeight + keyboardBounds.size.height + bottomToolbar.bounds.size.height < ScreenHeight) {
        ;
    }else{
        NSLog(@"%f", tableHeight);
        NSLog(@"%f", keyboardBounds.size.height);
        
        if (tableHeight<talkTableView.bounds.size.height) {
            tableHeight+=64;
        }
        
        tableFrame.origin.y = ScreenHeight - (tableHeight + bottomToolbar.bounds.size.height + keyboardBounds.size.height);
    }
    
    bottomFrame.origin.y =  ScreenHeight - keyboardBounds.size.height - bottomToolbarHeight;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    
    talkTableView.frame = tableFrame;
    bottomToolbar.frame = bottomFrame;
    curTableViewFrame = talkTableView.frame;
    curBottomBarFrame = bottomToolbar.frame;
    
    // commit animations
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification*)notification{
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    keyboardHeight = 0;
    
    CGRect btnFrame = talkTableView.frame;
    CGRect bottomFrame = bottomToolbar.frame;
    btnFrame.origin.y = 0;
    bottomFrame.origin.y = ScreenHeight - bottomToolbar.bounds.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    talkTableView.frame = btnFrame;
    bottomToolbar.frame = bottomFrame;
    
    curBottomBarFrame = bottomFrame;
    curTableViewFrame = btnFrame;
    
    // commit animations
    [UIView commitAnimations];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)dealloc
{
    //talkTableView.dealloc = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == talkTableView) {
        if (talkTableView.contentOffset.y+128<0 && updatingTalkMessage == false) {
            updatingTalkMessage = true;
            NSLog(@"top");
            
            //get history talk from database;
            PriMsgModel* firstMsg = [priMsgList firstObject];
            PriMsgModel* loadingMsg = [[PriMsgModel alloc] init];
            loadingMsg.msg_type = LOADINGMSG;
            loadingMsg.send_timestamp = firstMsg.send_timestamp;
            [priMsgList insertObject:loadingMsg atIndex:0];
            [talkTableView reloadData];
            [self performSelector:@selector(getMsgFromDatabase:) withObject:[[NSNumber alloc] initWithLong:loadingMsg.send_timestamp] afterDelay:2];
            
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"end scroll");
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == talkTableView) {
        [myTextField resignFirstResponder];
    }
    NSLog(@"scrollViewWillBeginDragging");
}

- (void)setTitleView:(NSString*)title
{
    if(activeView == nil){
        activeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activeView.frame = CGRectMake(0, 0, 30, 30);
        [activeView hidesWhenStopped];
    }
    
    if(navTitle == nil){
        navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        [navTitle setTextColor:[UIColor whiteColor]];
        [navTitle setText:title];
        navTitle.textAlignment = NSTextAlignmentCenter;
        navTitle.font = [UIFont boldSystemFontOfSize:20];
        navTitle.center = self.navigationItem.titleView.center;
        self.navigationItem.titleView = navTitle;
        [self.navigationItem.titleView addSubview:activeView];
    }
    
    navTitle.text = title;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    firstloading = true;
    //self.view.backgroundColor = [UIColor whiteColor];
    
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    myInfo = [AppDelegate getMyUserInfo];
    mysocket = [AppDelegate getMySocket];
    
    [mysocket setDelegate:self];
    
    keyboardHeight = 0;
    updatingTalkMessage = false;
    
    
    [self setTitleView:_counterInfo.nickName];
    
    
    locDatabase = [[LocDatabase alloc] init];
    if (![locDatabase connectToDatabase:[AppDelegate getMyUserInfo].userID]) {
        alertMsg(@"本地数据库出错");
        return;
    }
    
    
    UIButton* rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBar.frame = CGRectMake(0, 0, 36, 36);
    [rightBar setTitle:@"资料" forState:UIControlStateNormal];
    [rightBar addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    self.navigationItem.rightBarButtonItem = rightitem;
    
    priMsgList = [[NSMutableArray alloc] initWithArray:[locDatabase readPriMsgByUserID:myInfo.userID otherUserID:_counterInfo.userID MinTimeStamp:[[NSDate date] timeIntervalSince1970] LimitCount:12]];
    

    
    [self initTalkTableView];
    [self initTextField];
    [self clickWriteButton:nil];
    
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"关注Ta",@"加入黑名单", nil];
    
    mp3Recorder = [[Mp3Recorder alloc] initWithDelegate:self];
    
}


- (void)settingButtonAction:(id)sender
{
    SettingViewController* setting = [[SettingViewController alloc] init:_counterInfo];
    
    [self.navigationController pushViewController:setting animated:YES];
    
    //[sheet showInView:self.view];
}

- (void)insertBlackListSuccess:(id)sender
{
    
    [_parentCtrl deleteMsg:_counterInfo.userID];
    [_parentCtrl.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertBlackListError:(id)sender
{
    alertMsg(@"未知错误");
}

- (void)insertBlackListException:(id)sender
{
    alertMsg(@"网络异常");
}



- (void)setToBlackList
{
    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    [loadingView show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[myInfo.userID, _counterInfo.userID, @"/insertBlackList"] forKeys:@[@"user_id", @"counter_user_id", @"childpath"]];
    
        NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(insertBlackListSuccess:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(insertBlackListError:) objCType:@encode(SEL)],[NSValue valueWithBytes:&@selector(insertBlackListException:) objCType:@encode(SEL)] ] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS],[[NSNumber alloc] initWithInt:ERROR],[[NSNumber alloc] initWithInt:EXCEPTION]]];
                                                                         
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;
    } callObject:self];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet == sheet) {
        NSLog(@"Button %ld", buttonIndex);
        
        if (buttonIndex == 0) {
            //关注Ta
//            cell.textLabel.text = @"女";
//            genderSelect = YES;
//            _userInfo.gender = buttonIndex;
        }
        if (buttonIndex==1) {
            //加入黑名单
            [self setToBlackList];
        }
    }
}


- (void)getPriMsgSuccess:(id)sender
{
    
}

- (void)getPriMsgError:(id)sender
{
    alertMsg(@"获取消息列表失败");
}

- (void)getPriMsgException:(id)sender
{
    alertMsg(@"网络问题");
}

- (void)sendRegister:(SocketIO*)socket
{
    //[activeView startAnimating];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:myInfo.userID forKey:@"user_id"];
    [dict setObject:_counterInfo.userID forKeyedSubscript:@"counter_id"];
    
    PriMsgModel* last = nil;
    for (long i = [priMsgList count] - 1; i>=0; --i) {
        last = (PriMsgModel*)[priMsgList objectAtIndex:i];
        if ([last.receive_user_id isEqual: myInfo.userID] == true) {
            break;
        }
    }
    
    
    if (last == nil) {
        [dict setObject:[[NSNumber alloc] initWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"lastTimeStamp"];
    }else{
        [dict setObject:[[NSNumber alloc] initWithInteger:last.send_timestamp] forKey:@"lastTimeStamp"];
    }
    
    
    
    [socket sendEvent:@"register" withData:dict andAcknowledge:^(id argsData) {
        NSDictionary *response = argsData;
        // do something with response
        NSLog(@"%@", response);
        
        [activeView stopAnimating];
        [self handleMissedMsg:response];
        
    }];
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"connect success");
    
    [activeView stopAnimating];
    
    [self sendRegister:socket];
}



- (void)scrollToBottom:(BOOL)animation addition:(CGFloat)height
{

    if ([priMsgList count] == 0) {
        return;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
    
    NSInteger rows = [talkTableView numberOfRowsInSection:0];
    
    if (indexPath.row>=rows||indexPath.row<0) {
        return;
    }
    
    [talkTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animation];
    
    
    if (height>0&&talkTableView.contentSize.height + bottomToolbar.bounds.size.height + keyboardHeight<ScreenHeight) {
        
        NSLog(@"%f", talkTableView.contentSize.height);
        NSLog(@"%f", talkTableView.contentOffset.y);
        
        if (talkTableView.contentSize.height + height + bottomToolbar.bounds.size.height + keyboardHeight > ScreenHeight) {
            NSLog(@"%f", talkTableView.contentSize.height + height - talkTableView.contentOffset.y + bottomToolbar.bounds.size.height + keyboardHeight - ScreenHeight);
            CGRect tableFrame = talkTableView.frame;
            tableFrame.origin.y -= (talkTableView.contentSize.height + height - talkTableView.contentOffset.y + bottomToolbar.bounds.size.height + keyboardHeight - ScreenHeight);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            
            // set views with new info
            
            talkTableView.frame = tableFrame;
            curTableViewFrame = talkTableView.frame;
            
            // commit animations
            [UIView commitAnimations];
        }
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%@", text);
    NSRange strRange = [text rangeOfString:@"\n"];
    
    if (strRange.location != NSNotFound) {
        NSLog(@"enter");
        //[text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [self sendMessage:nil];
        return NO;
    }
    return YES;
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [activeView stopAnimating];
    [self performSelector:@selector(socketConnect) withObject:nil afterDelay:1];
}


- (void)startConnectActiveView
{
    if (mysocket.isConnected == false) {
        [activeView startAnimating];
    }else{
        [activeView stopAnimating];
        [timer invalidate];
        timer = nil;
    }
}

- (void)socketConnect
{
    [timer invalidate];
    timer = nil;
    timer =[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startConnectActiveView) userInfo:nil repeats:YES];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //mysocket.useSecure = YES;
    
    [mysocket connectToHost:app.socketIP onPort:app.socketPort withParams:nil withNamespace:nil withConnectionTimeout:3];
    
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent >>> data: %@", packet.data);
    NSLog(@"%@", packet.type);
    NSLog(@"%@", packet.name);
    NSArray* array = packet.args;
    NSDictionary* feedback = array[0];
    
    if([packet.name isEqualToString:@"msg"]){
        NSLog(@"get msg");
        
        if([[feedback objectForKey:@"from"] isEqualToString:_counterInfo.userID]&&
           [[feedback objectForKey:@"to"] isEqualToString:myInfo.userID]){
            //update chat
            PriMsgModel* priMsgModel = [[PriMsgModel alloc] init];
            priMsgModel.msg_id = [feedback objectForKey:@"msg_id"];
            priMsgModel.sender_user_id = [feedback objectForKey:@"from"];
            priMsgModel.receive_user_id = [feedback objectForKey:@"to"];
            
            
            //decrypt
            CocoaSecurityResult* aesDefault = [CocoaSecurity aesDecryptWithBase64:[feedback objectForKey:@"message"] key:[ConfigAccess msgKey]];
            NSLog(@"%@", aesDefault.utf8String);
            
            priMsgModel.message_content = aesDefault.utf8String;
            priMsgModel.msg_type = [[feedback objectForKey:@"msg_type"] intValue];
            priMsgModel.send_timestamp = [[feedback objectForKey:@"timestamp"] intValue];
            priMsgModel.voiceTime = [[feedback objectForKey:@"voice_time"] intValue];
            priMsgModel.unread = 1;
            priMsgModel.msg_srno = [feedback objectForKey:@"msg_srno"];
            
            NSString* tempData = [feedback objectForKey:@"data"];
            if (tempData == nil) {
                tempData = @"";
            }
            
            priMsgModel.data = [[NSData alloc] initWithBase64EncodedString:tempData options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            [self writePriMsgToLocalDatabase:priMsgModel];
            [self updateChatList];
        }
    }
    
}

- (void)handleMissedMsg:(NSDictionary*)data
{
    if ([[data objectForKey:@"code"] intValue] == ERROR) {
        alertMsg(@"获取最近信息失败");
    }else{
        NSArray* msgList = [data objectForKey:@"data"];
        if ([msgList count]>0) {
            for (long i=[msgList count]-1; i>=0; --i) {
                NSDictionary* element = [msgList objectAtIndex:i];
                PriMsgModel* priMsg = [[PriMsgModel alloc] init];
                
                //decrypt
                CocoaSecurityResult* aesDefault = [CocoaSecurity aesDecryptWithBase64:[element objectForKey:@"message_content"] key:[ConfigAccess msgKey]];
                
                priMsg.message_content = aesDefault.utf8String;
                
                
                priMsg.send_timestamp = [[element objectForKey:@"send_timestamp"] integerValue];
                priMsg.sender_user_id = [element objectForKey:@"sender_user_id"];
                priMsg.receive_user_id = [element objectForKey:@"receive_user_id"];
                priMsg.msg_id = [element objectForKey:@"msg_id"];
                priMsg.msg_type = [[element objectForKey:@"msg_type"] integerValue];
                priMsg.unread = 1;
                priMsg.msg_srno = [element objectForKey:@"msg_srno"];
                
                NSString* tempData = [element objectForKey:@"data"];
                if (tempData == nil) {
                    tempData = @"";
                }
                
                priMsg.data = [[NSData alloc] initWithBase64EncodedString:tempData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                priMsg.voiceTime = [[element objectForKey:@"voice_time"] intValue];
                
                if ((priMsg.msg_type == VOICEMSG||priMsg.msg_type == IMAGEMSG)&&priMsg.data == NULL) {
                    //image or voice null, then not to show
                    continue;
                }
                
                
                if ([locDatabase getPriMsgByMsgID:priMsg.msg_id] == nil) {
                    if([locDatabase writePriMsgToDatabase:priMsg]){
                        [priMsgList addObject:priMsg];
                    }
                }
            }
            
            priMsgList = [self sortMsg:priMsgList];
            PriMsgModel* priMsg = [priMsgList lastObject];
            LastMsgModel* lastMsg = [[LastMsgModel alloc] init];
            
            lastMsg.counter_user_id = _counterInfo.userID;
            lastMsg.counter_nick_name = _counterInfo.nickName;
            lastMsg.counter_face_image_url = _counterInfo.faceImageThumbnailURLStr;
            lastMsg.msg = priMsg.message_content;
            lastMsg.time_stamp = priMsg.send_timestamp;
            lastMsg.msg_type = priMsg.msg_type;
            
            [locDatabase writeLastPriMsgToDatabase:lastMsg];
            
            [talkTableView reloadData];
            NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
            [talkTableView selectRowAtIndexPath:curIndex animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    getMissedMsg = false;
}

- (void)clickImageButton:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //picker.allowsEditing = YES;
    picker.delegate = self;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"did select picture");
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    PriMsgModel* priMsgModel = [[PriMsgModel alloc] init];
    //if (UIImagePNGRepresentation(aImage) == nil) {
        priMsgModel.data = UIImageJPEGRepresentation(aImage, 0.5);
    //} else {
     //   priMsgModel.data = UIImagePNGRepresentation(aImage);
    //}
    
    priMsgModel.msg_type = IMAGEMSG;
    priMsgModel.send_timestamp = [[NSDate date] timeIntervalSince1970];
    priMsgModel.sender_user_id = myInfo.userID;
    priMsgModel.receive_user_id = _counterInfo.userID;
    priMsgModel.msg_id = NULL;
    priMsgModel.voiceTime = 0;
    priMsgModel.sendStatus = SENDING;
    CocoaSecurityResult *md5 = [CocoaSecurity md5:[[NSString alloc] initWithFormat:@"%@%@%ld", priMsgModel.sender_user_id, priMsgModel.receive_user_id, (long)priMsgModel.send_timestamp]];
    priMsgModel.msg_srno = md5.hex;

    [self writePriMsgToLocalDatabase:priMsgModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏白色
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self updateChatList];
        [self sendDataToServer:priMsgModel];
    });
    
    
}


- (void)sendDataToServer:(PriMsgModel*)priMsg
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    
    
    NSString *encryptedData = [AESCrypt encrypt:priMsg.message_content password:[ConfigAccess msgKey]];
    NSLog(@"%@", encryptedData);
    
    CocoaSecurityResult *aesDefault = [CocoaSecurity aesEncrypt:priMsg.message_content key:[ConfigAccess msgKey]];
    
    NSLog(@"%@", aesDefault.base64);
    
    [dict setObject:aesDefault.base64 forKey:@"message"];
    [dict setObject:myInfo.userID forKey:@"from"];
    [dict setObject:_counterInfo.userID forKey:@"to"];
    
    [dict setObject:myInfo.nickName forKey:@"from_name"];
    [dict setObject:myInfo.faceImageThumbnailURLStr forKey:@"from_face_url"];
    [dict setObject:_counterInfo.nickName forKey:@"to_name"];
    [dict setObject:[[NSNumber alloc] initWithInt:priMsg.voiceTime] forKey:@"voice_time"];
    [dict setObject:_counterInfo.faceImageThumbnailURLStr forKey:@"to_face_url"];
    
    
    [dict setObject:[[NSNumber alloc] initWithLong:priMsg.msg_type] forKey:@"msg_type"];
    [dict setObject:[priMsg.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"data"];
    [dict setObject:priMsg.msg_srno forKey:@"msg_srno"];
    
    
    if ([mysocket isConnected] == false) {
        [self socketConnect];
        priMsg.sendStatus = SENDED_FAILED;
        [locDatabase updatePriMsg:priMsg];
        [talkTableView reloadData];
        return;
    }
    
    [activeView stopAnimating];
    
    [mysocket sendEvent:@"msg" withData:dict andAcknowledge:^(id argsData) {
        NSDictionary* feedback = (NSDictionary*)argsData;
        if ([[feedback objectForKey:@"code"] integerValue] == ERROR) {
            alertMsg(@"send msg error");
            priMsg.sendStatus = SENDED_FAILED;
        }else if([[feedback objectForKey:@"code"] integerValue] == BLACK_LIST){
            //alertMsg(@"be in black list");
            [self updateNotifyMsg:@"对方拒绝接收你的消息" senderID:myInfo.userID receiveID:_counterInfo.userID];
        }else{
            NSLog(@"send msg success");
            priMsg.sendStatus = SENDED_SUCCESS;
        }
        [locDatabase updatePriMsg:priMsg];
        [talkTableView reloadData];
    }];
}

- (void)sendMessage:(id)sender
{
    if([myTextField.text isEqualToString:@""]){
        return;
    }
    
    
    [activeView stopAnimating];
    
    NSString* myMessage = [NSString emojizedStringWithString:myTextField.text];
    
    
    myMessage = [myMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![myMessage isEqualToString:@""]) {
        //send to server
        PriMsgModel* priMsgModel = [[PriMsgModel alloc] init];
        priMsgModel.data = [myMessage dataUsingEncoding:NSUTF8StringEncoding];
        priMsgModel.msg_type = USERMSG;
        priMsgModel.send_timestamp = [[NSDate date] timeIntervalSince1970];
        priMsgModel.sender_user_id = myInfo.userID;
        priMsgModel.receive_user_id = _counterInfo.userID;
        priMsgModel.msg_id = NULL;
        priMsgModel.voiceTime = 0;
        priMsgModel.message_content = myMessage;
        priMsgModel.sendStatus = SENDING;
        
        CocoaSecurityResult *md5 = [CocoaSecurity md5:[[NSString alloc] initWithFormat:@"%@%@%ld", priMsgModel.sender_user_id, priMsgModel.receive_user_id, (long)priMsgModel.send_timestamp]];
        priMsgModel.msg_srno = md5.hex;
        
        
        
        [self writePriMsgToLocalDatabase:priMsgModel];
        [self updateChatList];
        [self sendDataToServer:priMsgModel];
        
    }
    
    myTextField.text = @"";
    [self textViewDidChange:myTextField];
    
    //send to server
    NSLog(@"sendMessage");
}

//- (void)handleSendMsgFeedBack:(NSDictionary*)data index:(NSIndexPath*)index
//{
//    
//}

- (void)updateNotifyMsg:(NSString*)myMessage senderID:(NSString*)senderID receiveID:(NSString*)receiveID
{
    PriMsgModel* priMsgModel = [[PriMsgModel alloc] init];
    
    priMsgModel.message_content = myMessage;
    priMsgModel.msg_type = NOTIFYMSG;
    priMsgModel.send_timestamp = [[NSDate date] timeIntervalSince1970]+1;
    priMsgModel.sender_user_id = senderID;
    priMsgModel.receive_user_id = receiveID;
    [priMsgList addObject:priMsgModel];
    [locDatabase writePriMsgToDatabase:priMsgModel];
    
    
    [talkTableView reloadData];
    NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
    [talkTableView selectRowAtIndexPath:curIndex animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)writePriMsgToLocalDatabase:(PriMsgModel*)priMsgModel
{
    PriMsgModel* lastPriMsg = [priMsgList lastObject];
    PriMsgModel* timeMsg = nil;
    if (lastPriMsg!=nil && priMsgModel.send_timestamp - lastPriMsg.send_timestamp>10*60) {
        timeMsg = [[PriMsgModel alloc] init];
        timeMsg.sender_user_id = priMsgModel.sender_user_id;
        timeMsg.receive_user_id = priMsgModel.receive_user_id;
        timeMsg.send_timestamp = priMsgModel.send_timestamp - 1;
        timeMsg.msg_type = TIMEMSG;
        [locDatabase writePriMsgToDatabase:timeMsg];
        [priMsgList addObject:timeMsg];
    }
    
    
    LastMsgModel* lastMsg = [[LastMsgModel alloc] init];
    lastMsg.counter_user_id = _counterInfo.userID;
    lastMsg.counter_face_image_url = _counterInfo.faceImageThumbnailURLStr;
    
    lastMsg.msg = priMsgModel.message_content;
    lastMsg.msg_type = priMsgModel.msg_type;
    lastMsg.time_stamp = priMsgModel.send_timestamp;
    lastMsg.counter_nick_name = _counterInfo.nickName;
    [locDatabase writeLastPriMsgToDatabase:lastMsg];
    
    if([locDatabase writePriMsgToDatabase:priMsgModel]){
        [priMsgList addObject:priMsgModel];
    }
    
}

- (void)updateChatList
{
    [talkTableView reloadData];
    NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
    [talkTableView selectRowAtIndexPath:curIndex animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

- (void) DoneButtonAction:(id)sender {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"talkview delloc");
        //self.view = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [talkTableView setDelegate:nil];
    UUAVAudioPlayer* audio = [UUAVAudioPlayer sharedInstance];
    [audio stopSound];
    audio.delegate = nil;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    //进入前台时调用此函数
    [mysocket setDelegate:self];
    
    if (mysocket.isConnected==false) {
        [self socketConnect];
    }else{
        [self sendRegister:mysocket];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
//    if ([priMsgList count]>0) {
//        NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
//        [talkTableView selectRowAtIndexPath:curIndex animated:NO scrollPosition:UITableViewScrollPositionBottom];
//        //        [talkTableView setContentOffset:CGPointMake(0, talkTableView.contentSize.height -talkTableView.bounds.size.height) animated:NO];
//    }
    [super viewDidAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [talkTableView setDelegate:self];

    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:app];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //[self initTalkTableView];
    
    [mysocket setDelegate:self];
    
    if (mysocket.isConnected==false&&mysocket.isConnecting==false) {
        [self socketConnect];
    }else{
        [self sendRegister:mysocket];
    }
    
    
    [talkTableView reloadData];
//    
//    if ([priMsgList count]>0) {
//        NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
//        [talkTableView selectRowAtIndexPath:curIndex animated:NO scrollPosition:UITableViewScrollPositionBottom];
////        [talkTableView setContentOffset:CGPointMake(0, talkTableView.contentSize.height -talkTableView.bounds.size.height) animated:NO];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [priMsgList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    
    PriMsgModel* priMsg = priMsgList[indexPath.row];
    
    if (priMsg.msg_type == TIMEMSG) {
        return 44;
    }
    
    if (priMsg.msg_type == NOTIFYMSG) {
        return 64;
    }
    
    if (priMsg.msg_type == LOADINGMSG) {
        return 44;
    }
    
    CGFloat cellHeight = 0;
    
    if(priMsg.msg_type == VOICEMSG||priMsg.msg_type == USERMSG){
        cellHeight = [TalkTableViewCell getCellHeight:priMsg.message_content msgButtonHeight:0 msgButtonWidth:0];
        
    }
    
    if (priMsg.msg_type == IMAGEMSG) {
        
        cellHeight = [TalkTableViewCell getImageHeight:priMsg.data];
    }
    

    
    if (indexPath.row == [priMsgList count] - 1) {
        //最后一行高度需要增加
        return cellHeight+25;
        
    }else{
        return cellHeight+15;
    }
    
    
    return 0;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        if (firstloading == true) {
            firstloading = false;
            if ([priMsgList count]>0) {
                NSIndexPath* curIndex = [NSIndexPath indexPathForRow:[priMsgList count]-1 inSection:0];
                [talkTableView selectRowAtIndexPath:curIndex animated:NO scrollPosition:UITableViewScrollPositionBottom];
                //        [talkTableView setContentOffset:CGPointMake(0, talkTableView.contentSize.height -talkTableView.bounds.size.height) animated:NO];
            }
        }
    }
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PriMsgModel* priMsg = [priMsgList objectAtIndex:indexPath.row];
//    if (priMsg.msg_type == USERMSG&&priMsg.sendStatus == SENDED_FAILED&&[priMsg.sender_user_id isEqualToString:myInfo.userID]){
//        priMsg.sendStatus = SENDING;
//        [talkTableView reloadData];
//        [self sendDataToServer:priMsg];
//    }
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"TalkCellIdentifier";
    static NSString* timeCellIdentifier = @"TimeTalkCellIdentifier";
    static NSString* loadingCellIdentifier = @"loadingCellIdentifier";
    static NSString* notifyMsgCellIdentifier = @"notifyMsgCellIdentifier";
    
    
    
    PriMsgModel* priMsg = priMsgList[indexPath.row];
    if (priMsg.msg_type == TIMEMSG) {
        
        TalkTimeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: timeCellIdentifier];
        if (cell == nil) {
            cell = [[TalkTimeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellIdentifier];
            NSLog(@"create cell");
        }
        //cell.backgroundColor = activeViewControllerbackgroundColor;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTimeStamp:priMsg.send_timestamp];
        return cell;
        
    }else if(priMsg.msg_type == NOTIFYMSG){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: notifyMsgCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notifyMsgCellIdentifier];
            NSLog(@"create cell");
        }
        
        for (UIView *subview in [cell.contentView subviews]){
            [subview removeFromSuperview];
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = @"";
        }
        //cell.backgroundColor = activeViewControllerbackgroundColor;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize size = [Tools getTextArrange:priMsg.message_content maxRect:CGSizeMake(ScreenWidth, 64) fontSize:13];
        
        UILabel* msgLabel = [[UILabel alloc] init];
        msgLabel.frame = CGRectMake(0, 0, size.width, size.height);
        msgLabel.text = priMsg.message_content;
        msgLabel.font = [UIFont fontWithName:@"Arial" size:13];
        msgLabel.textColor = [UIColor whiteColor];
        msgLabel.backgroundColor = [UIColor lightGrayColor];
        msgLabel.center = cell.contentView.center;
        
        [cell.contentView addSubview:msgLabel];
        
        return cell;
        
    }else if(priMsg.msg_type == LOADINGMSG){
        UITableViewCell* loadCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellIdentifier];
        loadCell.selectionStyle = UITableViewCellSeparatorStyleNone;
        loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [loading startAnimating];
        loading.center = loadCell.center;
        
        //loadCell.backgroundColor = activeViewControllerbackgroundColor;
        
        [loadCell addSubview:loading];
        return loadCell;
    }
    else{
        
        TalkTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        
        if (cell == nil) {
            cell = [[TalkTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            NSLog(@"create cell");
        }
        
        cell.parentViewCtrl = self;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;//消去边线
        cell.parent = self.navigationController;
        //cell.backgroundColor = activeViewControllerbackgroundColor;
        
        [cell setTalkCell:myInfo counter:_counterInfo msg:priMsg];
        return cell;
    }
    
}

@end
