//
//  TalkCellViewTableViewCell.m
//  miniWeChat
//
//  Created by wang jam on 5/18/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "TalkTableViewCell.h"
#import "Constant.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Tools.h"
#import "macro.h"
#import "AppDelegate.h"
#import "LocDatabase.h"
#import "TalkViewController.h"


@implementation TalkTableViewCell
{
    NSMutableDictionary* faceImageDic;
    PriMsgModel* myPriMsgModel;
    UIImageView* voiceImageview;
    BOOL voiceStart;
    UUAVAudioPlayer* audio;
    UIImageView* enlargeImageview;
    UIScrollView* backgroundView;
}


static const int faceImageHeight = 50;
static const int faceImageWidth = 50;
static const int minCellHeight = 60;
static const int maxMsgButtonWidth = 200;
static const int maxMsgButtonHeight = 400;

static const int otherchatLeftMargin = 20;
static const int otherchatRightMargin = 20;
static const int topMargin = 15;
static const int bottomMargin = 15;
static const int mychatLeftMargin = 20;
static const int mychatRightMargin = 20;

static const int fontSize = 16;


static const int maxImageButtonWidth = 160;
static const int maxImageButtonHeight = 160;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _msgButton = [[UIButton alloc] init];
        _faceImage = [[FaceView alloc] init];
        _activeLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        faceImageDic = [[NSMutableDictionary alloc] init];
        _unreadNotify = [[UIView alloc] init];
        _sendFailedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wrong.png"]];
        
        _sendFailedIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(failIconClick:)];
        [_sendFailedIcon addGestureRecognizer:singleTap];
        
        
        
        [self.contentView addSubview:self.activeLoadingView];
        [self.contentView addSubview:self.faceImage];
        [self.contentView addSubview:self.msgButton];
        [self.contentView addSubview:self.unreadNotify];
        [self.contentView addSubview:self.sendFailedIcon];
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight:(NSString*) msg msgButtonHeight:(CGFloat*)msgButtonHeight msgButtonWidth:(CGFloat*)msgButtonWidth
{
    //    [msg boundingRectWithSize:CGSizeMake(115, 400) options:<#(NSStringDrawingOptions)#> attributes:<#(NSDictionary *)#> context:<#(NSStringDrawingContext *)#>]
    
    
    CGSize size = [Tools getTextArrange:msg maxRect:CGSizeMake(maxMsgButtonWidth, maxMsgButtonHeight) fontSize:fontSize];
    
    
    if (msgButtonHeight!=0&&msgButtonWidth!=0) {
        *msgButtonHeight = size.height+topMargin+bottomMargin;
        *msgButtonWidth = size.width + mychatLeftMargin+mychatRightMargin;
    }
    
    
    if (size.height+topMargin+bottomMargin+5< minCellHeight) {//判断对话框的高度，如果比头像矮就设置为头像高度，否则就设置为对话框的文本高度加上间隔
        return minCellHeight;
    }
    else{
        return size.height+topMargin+bottomMargin+5;//与边线的间隔加上文本的上下缩进
    }
}

+ (int)getVoiceMsgWidth:(int)voiceTime
{
    int minWidth = 90;
    int blockWidth = 10;
    return MIN(maxMsgButtonWidth, minWidth+voiceTime*blockWidth);
}

- (void)setTalkCell:(UserInfoModel*)myInfo counter:(UserInfoModel*)counter msg:(PriMsgModel*)priMsg
{
    UserInfoModel* userInfo = nil;
    myPriMsgModel = priMsg;
    BOOL isMe;
    if ([priMsg.sender_user_id isEqual:myInfo.userID]) {
        isMe = true;
        userInfo = myInfo;
    }else{
        isMe = false;
        userInfo = counter;
    }
    
    
    for (UIView* view in self.msgButton.subviews) {
        if (view.tag == 111||view.tag == 112) {
            [view removeFromSuperview];
        }
    }
    
    
    //[self.faceImage sd_setImageWithURL:[[NSURL alloc] initWithString:userInfo.faceImageURLStr]];
    
    [self.faceImage sd_setImageWithURL:[[NSURL alloc] initWithString:userInfo.faceImageThumbnailURLStr] placeholderImage:[UIImage imageNamed:@"loading.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [self.faceImage setUserInfo:userInfo nav:_parent];
        self.faceImage.primsgButtonShow = false;
        self.faceImage.clipsToBounds = YES;
        
    }];
    
    
    
    
    CGFloat msgButtonHeight = 0.0;
    CGFloat msgButtonWidth = 0.0;
    
    if (priMsg.msg_type == VOICEMSG) {
        [TalkTableViewCell getCellHeight:@"这是一条语音信息" msgButtonHeight:&msgButtonHeight msgButtonWidth:&msgButtonWidth];
        msgButtonWidth = [TalkTableViewCell getVoiceMsgWidth:myPriMsgModel.voiceTime];
    }
    
    if (priMsg.msg_type == USERMSG) {
        [TalkTableViewCell getCellHeight:priMsg.message_content msgButtonHeight:&msgButtonHeight msgButtonWidth:&msgButtonWidth];
    }
    
    UIImage* image = [UIImage imageWithData:priMsg.data];
    if (priMsg.msg_type == IMAGEMSG) {
        NSLog(@"%f, %f", image.size.height, image.size.width);
        if (image.size.height>image.size.width) {
            msgButtonHeight = maxImageButtonHeight;
            msgButtonWidth = maxImageButtonHeight*(image.size.width/image.size.height);
            
            if (msgButtonHeight/msgButtonWidth>ScreenHeight/ScreenWidth) {
                msgButtonWidth = msgButtonHeight*(ScreenWidth/ScreenHeight);
            }
            
            
        }else{
            msgButtonWidth = maxImageButtonWidth;
            msgButtonHeight = maxImageButtonWidth*image.size.height/image.size.width;
            
        }
    }
    
    
    UIEdgeInsets insets;
    UIImage* charImage;
    
    if (isMe == true) {
        self.faceImage.frame = CGRectMake(ScreenWidth-faceImageWidth-5, 10, faceImageWidth, faceImageHeight);
        charImage = [UIImage imageNamed:@"mychat_normal.png"];
        insets = UIEdgeInsetsMake(topMargin, mychatLeftMargin, bottomMargin, mychatRightMargin);//设置文本的内边框
        [self.msgButton setContentEdgeInsets:insets];//设置缩进
        [self.msgButton setFrame:CGRectMake(self.frame.size.width-msgButtonWidth-faceImageWidth-5, 10,msgButtonWidth, msgButtonHeight)];
        [self.msgButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.activeLoadingView setFrame:CGRectMake(self.msgButton.frame.origin.x - 25, self.msgButton.frame.origin.y+(self.msgButton.frame.size.height-24)/2, 24, 24)];
        [self.activeLoadingView hidesWhenStopped];
        
    }else{
        self.faceImage.frame = CGRectMake(5, 10, faceImageWidth, faceImageHeight);
        charImage = [UIImage imageNamed:@"otherchat_normal.png"];
        insets = UIEdgeInsetsMake(topMargin, otherchatLeftMargin, bottomMargin, otherchatRightMargin);//设置文本的内边框
        [self.msgButton setContentEdgeInsets:insets];//设置缩进
        [self.msgButton setFrame:CGRectMake(faceImageWidth+5, 10,msgButtonWidth, msgButtonHeight)];
        [self.msgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
    charImage = [charImage stretchableImageWithLeftCapWidth:charImage.size.width*0.3 topCapHeight:charImage.size.height*0.5];//设置图片拉伸区域
    
    
    [self.msgButton setBackgroundImage:charImage forState:UIControlStateNormal];//设置对话框图片
    [self.msgButton setContentEdgeInsets:insets];//设置缩进
    self.msgButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:fontSize];
    self.msgButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.msgButton.titleLabel.numberOfLines = 0;
    [self.msgButton addTarget:self action:@selector(contentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (priMsg.msg_type == USERMSG) {
        
        [self.msgButton setTitle:priMsg.message_content forState:UIControlStateNormal];
    }
    
    if (priMsg.msg_type == IMAGEMSG) {
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 112;
        imageView.frame = CGRectMake(0, 0, self.msgButton.frame.size.width, self.msgButton.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self makeMaskView:imageView withImage:charImage];
        [self.msgButton addSubview:imageView];
        [self.msgButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
    
    //红外线感应监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    
    self.unreadNotify.hidden = YES;
    [self.activeLoadingView stopAnimating];
    self.sendFailedIcon.hidden = YES;
    
    
    
    
    if (priMsg.msg_type == VOICEMSG) {
        

        if (isMe) {
            voiceImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_animation_white3.png"]];
            voiceImageview.tag = 111;
            voiceImageview.frame = CGRectMake(msgButtonWidth*2/3, (msgButtonHeight-15)/2, 15, 15);
            
            voiceImageview.animationImages = [NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"chat_animation_white1"],
                                              [UIImage imageNamed:@"chat_animation_white2"],
                                              [UIImage imageNamed:@"chat_animation_white3"],nil];
            
            
            [self.msgButton addSubview:voiceImageview];
            [self.msgButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            
        }else{
            voiceImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_animation3.png"]];
            voiceImageview.tag = 111;
            voiceImageview.frame = CGRectMake(msgButtonWidth*1/3 - 15, (msgButtonHeight-15)/2, 15, 15);
            voiceImageview.animationImages = [NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"chat_animation1"],
                                              [UIImage imageNamed:@"chat_animation2"],
                                              [UIImage imageNamed:@"chat_animation3"],nil];
            
            
            [self.msgButton addSubview:voiceImageview];
            
            if (myPriMsgModel.unread == 1) {
                self.unreadNotify.frame = CGRectMake(self.msgButton.frame.origin.x+self.msgButton.frame.size.width+5, self.msgButton.frame.origin.y+5, 8, 8);
                self.unreadNotify.backgroundColor = [UIColor redColor];
                self.unreadNotify.layer.cornerRadius = self.unreadNotify.frame.size.height/2;
                self.unreadNotify.layer.masksToBounds = YES;
                self.unreadNotify.hidden = NO;
            }
        }
        
        voiceImageview.animationDuration = 1;
        voiceImageview.animationRepeatCount = 0;
        if (myPriMsgModel.voiceStart == true) {
            [voiceImageview startAnimating];
        }
        
        
        [self.msgButton setTitle:[[NSString alloc] initWithFormat:@"%d's", (int)priMsg.voiceTime] forState:UIControlStateNormal];
    }
    
    
    if (priMsg.sendStatus == SENDING&&isMe) {
        [self.activeLoadingView startAnimating];
    }else if(priMsg.sendStatus == SENDED_FAILED) {
        
        self.sendFailedIcon.frame = CGRectMake(self.activeLoadingView.frame.origin.x, self.activeLoadingView.frame.origin.y, self.activeLoadingView.frame.size.width, self.activeLoadingView.frame.size.height);
        self.sendFailedIcon.hidden = NO;
    }
}

- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image
{
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
    view.layer.mask = imageViewMask.layer;
}


- (void)UUAVAudioPlayerBeiginLoadVoice
{
    NSLog(@"UUAVAudioPlayerBeiginLoadVoice");
}

- (void)UUAVAudioPlayerBeiginPlay
{
    NSLog(@"UUAVAudioPlayerBeiginPlay");
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

+ (CGFloat)getImageHeight:(NSData*)data
{
    UIImage* image = [UIImage imageWithData:data];
    CGFloat msgButtonHeight;
    //CGFloat msgButtonWidth;
    
    if (image.size.height>image.size.width) {
        msgButtonHeight = maxImageButtonHeight;
        //msgButtonWidth = 1.0*maxImageButtonHeight*image.size.width/image.size.height;
    }else{
        //msgButtonWidth = maxImageButtonWidth;
        msgButtonHeight = 1.0*maxImageButtonWidth*image.size.height/image.size.width;
    }
    
    return msgButtonHeight;
}

- (void)UUAVAudioPlayerDidFinishPlay
{
    NSLog(@"UUAVAudioPlayerDidFinishPlay");
    //关闭红外线感应tn
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [voiceImageview stopAnimating];
    myPriMsgModel.voiceStart = false;
    [[UUAVAudioPlayer sharedInstance]stopSound];
}


//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}


- (void)failIconClick:(id)sender
{
    UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
    if (myPriMsgModel.sendStatus == SENDED_FAILED&&[myPriMsgModel.sender_user_id isEqualToString:myInfo.userID]) {
        myPriMsgModel.sendStatus = SENDING;
        [[_parentViewCtrl getTableView] reloadData];
        [_parentViewCtrl sendDataToServer:myPriMsgModel];
    }
}


- (void)contentButtonClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    
    if (myPriMsgModel.msg_type == VOICEMSG) {
        myPriMsgModel.unread = 0;
        
        LocDatabase* locDatabase = [[LocDatabase alloc] init];
        if (![locDatabase connectToDatabase]) {
            NSLog(@"database error");
        }
        
        if (myPriMsgModel.msg_srno == nil) {
            myPriMsgModel.msg_srno = myPriMsgModel.msg_id;
        }
        
        [locDatabase updatePriMsg:myPriMsgModel];
        
        [self.unreadNotify removeFromSuperview];
        
        NSLog(@"voiceButtonClick");
        if (myPriMsgModel.voiceStart == true) {
            [self UUAVAudioPlayerDidFinishPlay];
            
            
        }else{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            
            
            [voiceImageview startAnimating];
            myPriMsgModel.voiceStart = true;
            
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
            [audio playSongWithData:myPriMsgModel.data];
            
        }
    }
    
//    if (myPriMsgModel.msg_type == USERMSG) {
//        UserInfoModel* myInfo = [AppDelegate getMyUserInfo];
//        if (myPriMsgModel.sendStatus == SENDED_FAILED&&[myPriMsgModel.sender_user_id isEqualToString:myInfo.userID]) {
//            myPriMsgModel.sendStatus = SENDING;
//            [[_parentViewCtrl getTableView] reloadData];
//            [_parentViewCtrl sendDataToServer:myPriMsgModel];
//        }
//        
//    }
    
    if (myPriMsgModel.msg_type == IMAGEMSG) {
        NSLog(@"contentImagePress");
        
        enlargeImageview = [[UIImageView alloc] init];
        enlargeImageview.frame = [Tools relativeFrameForScreenWithView:button];
        enlargeImageview.image = [UIImage imageWithData:myPriMsgModel.data];
        enlargeImageview.contentMode = UIViewContentModeScaleAspectFit;
        enlargeImageview.backgroundColor = [UIColor blackColor];
        enlargeImageview.multipleTouchEnabled = YES;
        
        
        
        backgroundView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* singleTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewPress:)];
        [singleTab setNumberOfTapsRequired:1];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
        
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [backgroundView addGestureRecognizer:doubleTapGestureRecognizer];
        [backgroundView addGestureRecognizer:singleTab];
        [singleTab requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
        
        
        backgroundView.delegate = self;
        //设置最大伸缩比例
        backgroundView.maximumZoomScale=1.8;
        //设置最小伸缩比例
        backgroundView.minimumZoomScale=0.8;
        backgroundView.scrollEnabled = YES;
        //backgroundView.contentSize = enlargeImageview.image.size;
        
        [backgroundView addSubview:enlargeImageview];
        
        [backgroundView setAlpha:0.0];
        
        //[_parentViewController.navigationController.view addSubview:backgroundView];
        
        
        [_parentViewCtrl BackgroundViewButtonAction:nil];
        [_parentViewCtrl.tabBarController.view addSubview:backgroundView];
        
        
        // animations settings
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:0.3 animations:^{
            [backgroundView setAlpha:1];
            
            NSLog(@"%f", enlargeImageview.image.size.height);
            
            if(enlargeImageview.image.size.height/enlargeImageview.image.size.width>ScreenHeight/ScreenWidth){
                enlargeImageview.frame = CGRectMake(0, 0, ScreenWidth,ScreenWidth*enlargeImageview.image.size.height/enlargeImageview.image.size.width);
                
            }else{
                enlargeImageview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            }
            
            enlargeImageview.contentMode = UIViewContentModeScaleAspectFit;
            
            //UIImage* image = [UIImage imageWithData:myPriMsgModel.data];
            
            
            backgroundView.contentSize = CGSizeMake(enlargeImageview.frame.size.width, enlargeImageview.frame.size.height);
            [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
            
            
        } completion:^(BOOL finished) {
            ;
            //隐藏导航栏和tab栏
            
        }];
    }
    
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (enlargeImageview == view) {
        if (view.frame.size.width < ScreenWidth) {
            [scrollView setZoomScale:1.0 animated:YES];
        }
    }
}


//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return enlargeImageview;
}

- (void)zoomImage:(id)sender
{
    if(backgroundView.zoomScale == backgroundView.maximumZoomScale){
        [backgroundView setZoomScale:1 animated:YES];
    }else{
        [backgroundView setZoomScale:backgroundView.maximumZoomScale animated:YES];
    }
}

- (void)backgroundViewPress:(id)sender
{
    
    // animations settings
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.3 animations:^{
        enlargeImageview.frame = [Tools relativeFrameForScreenWithView:self.msgButton];
        [backgroundView setAlpha:0.0];
        [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
        //        if ([_parentViewController tabbarHidden] == true) {
        //            [_parentViewController hiddenTabbarAndNavBar];
        //        }else{
        //            [_parentViewController showTabbarAndNavBar];
        //        }
    } completion:^(BOOL finished) {
        [enlargeImageview removeFromSuperview];
        [backgroundView removeFromSuperview];
        backgroundView = nil;
        enlargeImageview = nil;
        
    }];
}

@end
