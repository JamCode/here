//
//  MessageTableViewController.m
//  CarSocial
//
//  Created by wang jam on 8/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "MessageTableViewController.h"
#import "UserInfoModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "PriMsgTableViewCell.h"
#import "TalkViewController.h"
#import "AppDelegate.h"
#import "LocDatabase.h"
#import "PriMsgModel.h"
#import "TimeFunction.h"
#import "SocketIO.h"
#import "Constant.h"
#import "NetWork.h"
#import "Constant.h"
#import "macro.h"
#import "FriendMsgMode.h"
#import "Tools.h"
#import <MBProgressHUD.h>
#import "ConfigAccess.h"



@interface MessageTableViewController ()
{
    NSMutableArray* priMsgFriendArray;
    
    UserInfoModel* myInfo;
    SocketIO* mysocket;
    
    UIActivityIndicatorView* activeView;
    UILabel* navTitle;
    UIRefreshControl* refreshControl;
    
    BOOL firstGetMsgList;
    
    NSInteger lastRegisterTimestamp;
    LocDatabase* locDatabase;
    
    BOOL getMissedMsg;
    
    NSInteger reconnectCount;
    
    BOOL connectFlag;
    BOOL recvMissedMsgFlag;
    NSString* loadingTitle;
    
    
    NSMutableDictionary* imageDic;
    
    NSTimer* timer;
    
}
@end

@implementation MessageTableViewController


const int priMsgCellHeight = 65;
static const int noticeLabelHeight = 20;



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        firstGetMsgList = false;
        lastRegisterTimestamp = 0;
        priMsgFriendArray = [[NSMutableArray alloc] init];
        getMissedMsg = false;
        reconnectCount = 10;
        imageDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)getPriMsgFriendList
{
    priMsgFriendArray = [locDatabase getLastMsgFromDatabase];
    [self.tableView reloadData];
    
}


- (void)getPriMsgFriendListException:(id)sender
{
    alertMsg(@"网络问题");

}

- (void)getPriMsgFriendListError:(id)sender
{
    alertMsg(@"获取私信列表失败");

}

- (void)socketConnect
{
    connectFlag = false;
    [self setTitleView:@"消息"];
    
    [timer invalidate];
    timer = nil;
    timer =[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startConnectActiveView) userInfo:nil repeats:YES];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    //mysocket.useSecure = YES;
    
    
    [mysocket connectToHost:app.socketIP onPort:app.socketPort withParams:nil withNamespace:nil withConnectionTimeout:3];
    
}






- (void)startConnectActiveView
{
    if (mysocket.isConnected == false) {
        [self setTitleView:@"连接中"];
        [activeView startAnimating];
    }else{
        [self setTitleView:@"消息"];
        [activeView stopAnimating];
        [timer invalidate];
        timer = nil;
    }
}

- (void)stopActiveView:(NSString*)title
{
    [activeView stopAnimating];
    [self setTitleView:title];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [self stopActiveView:@"连接异常"];
    
    NSLog(@"socketIODidDisconnect %@", error.domain);
    
    [self performSelector:@selector(socketConnect) withObject:nil afterDelay:1];
}

- (void)startGetMissedMsgActiveView
{
    if (recvMissedMsgFlag == false) {
        [self setTitleView:@"收取中"];
        [activeView startAnimating];
    }
}

- (void)sendRegister:(SocketIO*)socket
{
    recvMissedMsgFlag = false;
    
    
    [self performSelector:@selector(startGetMissedMsgActiveView) withObject:nil afterDelay:2];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:myInfo.userID forKey:@"user_id"];
    
    
    [socket sendEvent:@"register" withData:dict andAcknowledge:^(id argsData) {
        NSDictionary *response = argsData;
        // do something with response
        NSLog(@"%@", response);
        
        recvMissedMsgFlag = true;
        [self stopActiveView:@"消息"];
        
        [self handleAllMissedMsg:response];
    }];
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"connect success");
    reconnectCount = 10;
    
    connectFlag = true;
    
    [self sendRegister:socket];
}


- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet;
{
    NSLog(@"didReceivemsg >>> data: %@", packet.data);
}

- (void)handleAllMissedMsg:(NSDictionary*)data
{
    if ([[data objectForKey:@"code"] intValue] == ERROR) {
        alertMsg(@"获取最近信息失败");
    }else{
        NSArray* msgList = [data objectForKey:@"data"];
        NSMutableDictionary* receiveCountDic = [[NSMutableDictionary alloc] init];
        
        for (long i=[msgList count]-1; i>=0; --i) {
            NSDictionary* element = [msgList objectAtIndex:i];
            PriMsgModel* priMsg = [[PriMsgModel alloc] init];
            priMsg.message_content = [element objectForKey:@"message_content"];
            priMsg.send_timestamp = [[element objectForKey:@"send_timestamp"] integerValue];
            priMsg.sender_user_id = [element objectForKey:@"sender_user_id"];
            priMsg.receive_user_id = [element objectForKey:@"receive_user_id"];
            priMsg.msg_id = [element objectForKey:@"msg_id"];
            priMsg.msg_type = [[element objectForKey:@"msg_type"] integerValue];
            priMsg.voiceTime = [[element objectForKey:@"voice_time"] intValue];
            priMsg.unread = 1;
            priMsg.msg_srno = [element objectForKey:@"msg_srno"];
            
            NSString* tempData = [element objectForKey:@"data"];
            if (tempData == nil) {
                tempData = @"";
            }
            
            priMsg.data = [[NSData alloc] initWithBase64EncodedString:tempData options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            
            if([locDatabase getPriMsgByMsgID:priMsg.msg_id] == nil){
                
                LastMsgModel* oldLastPriMsg = [locDatabase getLastMsgByUser:priMsg.sender_user_id];
                
                PriMsgModel* timeMsg = nil;
                
                if (oldLastPriMsg!=nil && priMsg.send_timestamp - oldLastPriMsg.time_stamp>5*60) {
                    timeMsg = [[PriMsgModel alloc] init];
                    timeMsg.sender_user_id = priMsg.sender_user_id;
                    timeMsg.receive_user_id = priMsg.receive_user_id;
                    timeMsg.send_timestamp = priMsg.send_timestamp - 1;
                    timeMsg.msg_type = TIMEMSG;
                    [locDatabase writePriMsgToDatabase:timeMsg];
                }

                [locDatabase writePriMsgToDatabase:priMsg];
                if ([receiveCountDic objectForKey:priMsg.sender_user_id]==nil) {
                    [receiveCountDic setObject:[[NSNumber alloc] initWithInt:1] forKey:priMsg.sender_user_id];
                }else{
                    [receiveCountDic setObject:[[NSNumber alloc] initWithLong:[[receiveCountDic objectForKey:priMsg.sender_user_id] integerValue]+1] forKey:priMsg.sender_user_id];
                }
            }else{
                continue;
            }
            
            NSLog(@"%@", [element objectForKey:@"user_id"]);
            
            LastMsgModel* lastMsg = [locDatabase getLastMsgByUser:[element objectForKey:@"user_id"]];
            
            if (lastMsg == nil) {
                lastMsg = [[LastMsgModel alloc] init];
            }
            
            
            if (lastMsg.time_stamp<priMsg.send_timestamp) {
                lastMsg.counter_user_id = [element objectForKey:@"user_id"];
                lastMsg.counter_nick_name = [element objectForKey:@"user_name"];
                lastMsg.counter_face_image_url = [element objectForKey:@"user_facethumbnail"];
                
                
                lastMsg.msg = priMsg.message_content;
                lastMsg.time_stamp = priMsg.send_timestamp;
                lastMsg.msg_type = priMsg.msg_type;
                [locDatabase writeLastPriMsgToDatabase:lastMsg];
            }
        }
        
        for (NSString* sender in receiveCountDic) {
            LastMsgModel* lastMsg = [locDatabase getLastMsgByUser:sender];
            lastMsg.unreadCount = [[receiveCountDic objectForKey:sender] integerValue];
            [locDatabase writeLastPriMsgToDatabase:lastMsg];
        }
        
        
        priMsgFriendArray = [locDatabase getLastMsgFromDatabase];
        [self.tableView reloadData];
        
    }
    
    [self updateTabCount];
}

- (void)stopActiveLoading
{
    [self setTitleView:@"消息"];
    [activeView stopAnimating];
}


- (void)handleMsg:(NSDictionary*)feedback
{
    NSString* to_id = [feedback objectForKey:@"to"];
    
    NSString* from_id = [feedback objectForKey:@"from"];
    NSString* from_name = [feedback objectForKey:@"from_name"];
    NSString* from_face_url = [feedback objectForKey:@"from_face_url"];
    NSInteger timestamp = [[feedback objectForKey:@"timestamp"] intValue];
    NSString* msg = [feedback objectForKey:@"message"];
    
    if([to_id isEqual:myInfo.userID] == false){
        NSLog(@"error pri msg");
        return;
    }
    NSInteger curUnreadCount = 0;
    for (int i=0; i<[priMsgFriendArray count]; ++i) {
        LastMsgModel* lastMsg = [priMsgFriendArray objectAtIndex:i];
        if ([from_id isEqual:lastMsg.counter_user_id]) {
            curUnreadCount = lastMsg.unreadCount;
            [priMsgFriendArray removeObject:lastMsg];
            break;
        }
    }
    
    
    
    PriMsgModel* priMsg = [[PriMsgModel alloc] init];
    priMsg.sender_user_id = from_id;
    priMsg.receive_user_id = to_id;
    priMsg.message_content = msg;
    priMsg.send_timestamp = timestamp;
    priMsg.msg_id = [feedback objectForKey:@"msg_id"];
    priMsg.msg_type = [[feedback objectForKey:@"msg_type"] integerValue];
    priMsg.voiceTime = [[feedback objectForKey:@"voice_time"] intValue];
    priMsg.unread = 1;
    priMsg.msg_srno = [feedback objectForKey:@"msg_srno"];
    
    NSString* tempData = [feedback objectForKey:@"data"];
    if (tempData == nil) {
        tempData = @"";
    }
    
    priMsg.data = [[NSData alloc] initWithBase64EncodedString:tempData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    
    if ([locDatabase getPriMsgByMsgID:priMsg.msg_id] == nil) {
        
        
        LastMsgModel* oldLastPriMsg = [locDatabase getLastMsgByUser:from_id];
        PriMsgModel* timeMsg = nil;
        
        if (oldLastPriMsg!=nil && priMsg.send_timestamp - oldLastPriMsg.time_stamp>5*60) {
            timeMsg = [[PriMsgModel alloc] init];
            timeMsg.sender_user_id = priMsg.sender_user_id;
            timeMsg.receive_user_id = priMsg.receive_user_id;
            timeMsg.send_timestamp = priMsg.send_timestamp - 1;
            timeMsg.msg_type = TIMEMSG;
            [locDatabase writePriMsgToDatabase:timeMsg];
        }

        [locDatabase writePriMsgToDatabase:priMsg];
    }
    
    
    LastMsgModel* lastMsg = [[LastMsgModel alloc] init];
    lastMsg.counter_user_id = from_id;
    lastMsg.counter_nick_name = from_name;
    lastMsg.counter_face_image_url = from_face_url;
    lastMsg.msg = msg;
    lastMsg.time_stamp = timestamp;
    lastMsg.unreadCount = curUnreadCount + 1;
    lastMsg.msg_type = priMsg.msg_type;
    [priMsgFriendArray insertObject:lastMsg atIndex:0];
    [locDatabase writeLastPriMsgToDatabase:lastMsg];
    
    
    [self.tableView reloadData];
    
    //update tab count
    [self updateTabCount];

}


//- (void)sendMissedMsgEvent:(SocketIO*)socket
//{
//    if (getMissedMsg == true) {
//        return;
//    }
//    
//    getMissedMsg = true;
//    
//    [self setTitleView:@"收取中"];
//    [activeView startAnimating];
//    
//    //get missed msg
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:myInfo.userID forKey:@"user_id"];
//    
//    [socket sendEvent:@"missedMsg" withData:dict andAcknowledge:^(id argsData) {
//        NSDictionary *response = argsData;
//        [self handleAllMissedMsg:response];
//    }];
//
//}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent >>> data: %@", packet.data);
    NSLog(@"%@", packet.type);
    NSLog(@"%@", packet.name);
    
    NSArray* array = packet.args;
    NSDictionary* feedback = array[0];
    
    if ([packet.name isEqualToString:@"msg"]) {
        [self handleMsg:feedback];
    }
}



- (void)setTitleView:(NSString*)title
{
    if(activeView == nil){
        activeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activeView.frame = CGRectMake(0, 0, 30, 30);
        [activeView setCenter:CGPointMake(200, 15)];//指定进度轮中心点
        [activeView hidesWhenStopped];
    }
    
    if(navTitle == nil){
        navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        [navTitle setTextColor:[UIColor whiteColor]];
        [navTitle setText:title];
        navTitle.textAlignment = NSTextAlignmentCenter;
        navTitle.font = [UIFont boldSystemFontOfSize:20];
        self.navigationItem.titleView = navTitle;
        [self.navigationItem.titleView addSubview:activeView];
    }
    
    navTitle.text = title;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    priMsgFriendArray = [[NSMutableArray alloc] init];

    
    [self setTitleView:@"消息"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    myInfo = [AppDelegate getMyUserInfo];
    mysocket = [AppDelegate getMySocket];
    [mysocket setDelegate:self];
    
    locDatabase = [[LocDatabase alloc] init];
    if(![locDatabase connectToDatabase:myInfo.userID]){
        alertMsg(@"数据库问题");
        return;
    }
    
    //[self.tableView setEditing:YES animated:YES];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"message didReceiveMemoryWarning");
    
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"messagetableview delloc");
        //self.view = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return priMsgCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [priMsgFriendArray count];
}

- (void)deleteMsg:(NSString*)user_id
{
    LastMsgModel* lastMsg = [[LastMsgModel alloc] init];
    lastMsg.counter_user_id = user_id;
    [locDatabase deleteMsg:lastMsg];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PriMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];

    if (cell == nil) {
        cell = [[PriMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"messageCell"];
    }
    //cell.editingStyle = UITableViewCellEditingStyleDelete;
    
    LastMsgModel* friMsgMode = [priMsgFriendArray objectAtIndex:indexPath.row];
    
    
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    [cell.imageView sd_setImageWithURL:[[NSURL alloc] initWithString:friMsgMode.counter_face_image_url] placeholderImage:[UIImage imageNamed:@"loading.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    
    
    //cell.imageView.contentMode =  UIViewContentModeScaleAspectFill;
    //cell.imageView.clipsToBounds  = YES;
    //cell.imageView.layer.cornerRadius = 6.0;
    
    NSLog(@"%f", cell.imageView.frame.size.width);
    
    for(UIView *view in [cell.imageView subviews]){
        [view removeFromSuperview];
    }
    
    
    if(friMsgMode.unreadCount>0){
        
        NSLog(@"%f, %f, %f, %f", cell.noticeCount.frame.origin.x, cell.noticeCount.frame.origin.y, cell.noticeCount.frame.size.width, cell.noticeCount.frame.size.height);
        
        cell.noticeCount.hidden = NO;
        cell.noticeCount.backgroundColor = [UIColor redColor];
        cell.noticeCount.layer.cornerRadius = noticeLabelHeight/2;
        cell.noticeCount.layer.masksToBounds = YES;
        cell.noticeCount.text = [[NSString alloc] initWithFormat:@"%ld", (long)friMsgMode.unreadCount];
        cell.noticeCount.textColor = [UIColor whiteColor];
        cell.noticeCount.textAlignment = NSTextAlignmentCenter;
        cell.noticeCount.tag = 111;
    }else{
        cell.noticeCount.hidden = YES;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:17];
    cell.textLabel.text = friMsgMode.counter_nick_name;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:14];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if(friMsgMode.msg_type == VOICEMSG){
        cell.detailTextLabel.text = @"[语音]";
    }else if(friMsgMode.msg_type == IMAGEMSG){
        cell.detailTextLabel.text = @"[图片]";
    }else{
        cell.detailTextLabel.text = friMsgMode.msg;
    }
    cell.lastTime.font = [UIFont fontWithName:@"Arial" size:14];
    cell.lastTime.textColor = [UIColor grayColor];
    cell.lastTime.text = [TimeFunction showTime:friMsgMode.time_stamp];
    // Configure the cell...
    
    return cell;
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"%@", error);
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateTabCount
{
    int totalUnreadCount = 0;
    
    for (int i=0; i<[priMsgFriendArray count]; ++i) {
        LastMsgModel* last = [priMsgFriendArray objectAtIndex:i];
        totalUnreadCount+=last.unreadCount;
    }
    if (totalUnreadCount>0) {
            [[[[[self tabBarController] viewControllers] objectAtIndex:2] tabBarItem] setBadgeValue:[[NSString alloc] initWithFormat:@"%d", totalUnreadCount]];
        
    }else{
            [[[[[self tabBarController] viewControllers] objectAtIndex:2] tabBarItem] setBadgeValue:nil];
    }
}

- (void)checkMissedMsg
{
    [mysocket setDelegate:self];
    
    if (mysocket.isConnected==false&&mysocket.isConnecting==false) {
        [self socketConnect];
    }
    
    if (mysocket.isConnected == true) {
        [self sendRegister:mysocket];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self getPriMsgFriendList];
    [self checkMissedMsg];
    [self updateTabCount];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
    //update tab count
    //[self updateTabCount];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self checkMissedMsg];
}


- (void)removeCellNotice:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    PriMsgTableViewCell* cell = (PriMsgTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.noticeCount.hidden = YES;
//    for (UIView* view in cell.imageView.subviews) {
//        if (view.tag == 111) {
//            [view removeFromSuperview];
//        }
//    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LastMsgModel* friMsg = [priMsgFriendArray objectAtIndex:indexPath.row];
    
    //[self removeCellNotice:tableView indexPath:indexPath];
    
    TalkViewController* talk = [[TalkViewController alloc] init];
    
    talk.parentCtrl = self;
    talk.counterInfo.userID = friMsg.counter_user_id;
    talk.counterInfo.faceImageThumbnailURLStr = friMsg.counter_face_image_url;
    
    talk.counterInfo.nickName = friMsg.counter_nick_name;
    talk.hidesBottomBarWhenPushed = YES;
    

    
    [self.navigationController pushViewController:talk animated:YES];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    if (friMsg.unreadCount>0) {
        friMsg.unreadCount = 0;
        [locDatabase writeLastPriMsgToDatabase:friMsg];
        [self.tableView reloadData];
    }
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        LastMsgModel* deleteLastMsgModel = [priMsgFriendArray objectAtIndex:indexPath.row];
        if ([locDatabase deleteMsg:deleteLastMsgModel]) {
            [priMsgFriendArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            alertMsg(@"删除失败");
        }
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
