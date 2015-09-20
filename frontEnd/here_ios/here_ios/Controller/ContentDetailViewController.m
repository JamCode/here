//
//  ActiveDetailViewController.m
//  CarSocial
//
//  Created by wang jam on 12/19/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "ContentDetailViewController.h"
#import "Constant.h"
#import "macro.h"
#import "NetWork.h"
#import "UserInfoModel.h"
#import "AppDelegate.h"
#import "FaceView.h"
#import "CommentTableViewCell.h"
#import "ContentModel.h"
#import "ContentView.h"
#import "PublishCommentViewController.h"
#import "Tools.h"
#import <MBProgressHUD.h>
#import "ContentViewController.h"
#import "ContentTableViewCell.h"
#import "ContentView.h"
#import "CommentModel.h"


@interface ContentDetailViewController ()
{
    UserInfoModel* myUserInfo;
    ContentTableViewCell* contentView;
    
    
    UIToolbar* bottomToolbar;
    UITextView* commentInputView;
    
    
    
    CGRect curTextFrame;
    NSMutableArray* comments;
    UIActionSheet* feedbackComments;
    
    UserInfoModel* toCommentUser;
    
    MBProgressHUD* mbProgress;
    
    BOOL getContentCommentsListSuccessFlag;
    
    UITextView* myTextField;
    
    NSString* commentStr;
}
@end

@implementation ContentDetailViewController


static const double bottomToolbarHeight = 48;


static const int inputfontSize = 16;
static const double textViewHeight = 36;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    getContentCommentsListSuccessFlag = false;
    
    myUserInfo = [AppDelegate getMyUserInfo];
    
    //self.tableView.hidden = YES;
    
    if(_contentModel.userInfo.faceImageThumbnailURLStr == nil){
        [self getContentBaseInfo];
    }
    
//    ContentTableViewCell* cell = [[ContentTableViewCell alloc] init];
//    [cell setContentModel:_contentModel];
    
    //UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    
    //[self.tableView setTableHeaderView:view];
    
    //self.tableView.tableHeaderView = cell;
    
    [self getContentCommentsList];
    //[self addSeeCount];
   
    feedbackComments = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复评论", nil];
    toCommentUser = [[UserInfoModel alloc] init];
    
    
    [self initCommentInputView];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == commentInputView) {
        if ([text isEqualToString:@"\n"]) {
            
            [textView resignFirstResponder];
            
            [self sendComment:nil];
            
            return NO;
            
        }
        return YES;
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [myTextField resignFirstResponder];
    }
}

- (void)getContentBaseInfoSuccess:(id)sender
{
    [mbProgress hide:YES];
    [mbProgress removeFromSuperview];
    mbProgress = nil;
    
    
    NSDictionary* feedback = (NSDictionary*)sender;
    NSDictionary* contents = [feedback objectForKey:@"contents"];
    
    
    NSDictionary* element = [contents objectForKey:_contentModel.contentID];
    
    if (element == nil) {
        return;
    }
    
    
    [_contentModel setContentModel:element];
    
    CLLocation* myPosition = [[CLLocation alloc] initWithLatitude:myUserInfo.latitude longitude:myUserInfo.longitude];
    CLLocation* userPosition = [[CLLocation alloc] initWithLatitude:_contentModel.latitude longitude:_contentModel.longitude];
    
    CLLocationDistance meters = [myPosition distanceFromLocation:userPosition];
    _contentModel.distanceMeters = meters;
        
    [self.tableView reloadData];
}

- (void)deleteButtonAction:(id)sender
{
    UIAlertView* choose = [[UIAlertView alloc] initWithTitle:nil message:@"确认删除吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [choose show];
}

- (void)deleteContent
{
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mbProgress];
    [mbProgress show:YES];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_contentModel.contentID, @"/deleteContent"] forKeys:@[@"content_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(deleteContentSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
//        [mbProgress hide:YES];
//        [mbProgress removeFromSuperview];
//        mbProgress = nil;
    } callObject:self];
    
}


- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud == mbProgress) {
        //[_parentContentViewCtrl callLoadingAction];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)deleteContentSuccess:(id)sender
{
    NSLog(@"publishActiveSuccess");
    mbProgress.labelText = @"删除成功";
    mbProgress.delegate = self;
    [mbProgress hide:YES afterDelay:1.0];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteContent];
    }
}

- (void)getContentBaseInfo
{
    
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mbProgress];
    [mbProgress show:YES];
    
    
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_contentModel.contentID, @"/getContentBaseInfo"] forKeys:@[@"content_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentBaseInfoSuccess:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
    NSLog(@"didDismissWithButtonIndex");
    
    if (actionSheet == feedbackComments) {
        NSLog(@"Button %ld", (long)buttonIndex);
        if (buttonIndex == 0) {
            NSIndexPath* indexPath =  [self.tableView indexPathForSelectedRow];
            
            toCommentUser = [[UserInfoModel alloc] init];
            toCommentUser.userID = [[comments objectAtIndex:indexPath.row] objectForKey:@"comment_user_id"];
            toCommentUser.nickName = [[comments objectAtIndex:indexPath.row] objectForKey:@"user_name"];
            _contentModel.to_content = 0;
            [self commentButtonAction:nil];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

}

- (void)addCommentSuccess:(id)sender
{
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    mbProgress.mode = MBProgressHUDModeText;
    [self.view addSubview:mbProgress];
    mbProgress.labelText = @"评论成功";
    [mbProgress show:YES];
    [mbProgress hide:YES afterDelay:1.0];
    
    [self.tableView beginUpdates];
    
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [indexPaths addObject:indexPath];
    
    
    CommentModel* commentModel = [[CommentModel alloc] init];
    commentModel.sendUserInfo = myUserInfo;
    commentModel.contentModel = _contentModel;
    
    
    commentModel.counterUserInfo = toCommentUser;
    if (commentModel.counterUserInfo == nil) {
        commentModel.counterUserInfo = commentModel.contentModel.userInfo;
    }
    
    
    commentModel.commentStr = commentStr;
    commentModel.publish_time = [[NSDate date] timeIntervalSince1970];
    
    [comments insertObject:commentModel atIndex:0];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    self.tableView.tableFooterView = nil;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (commentInputView!=nil) {
        [commentInputView resignFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)keyboardWillHide:(NSNotification*)notification{
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //keyboardHeight = 0;
    
    //CGRect btnFrame = talkTableView.frame;
    CGRect bottomFrame = bottomToolbar.frame;
    //btnFrame.origin.y = 0;
    bottomFrame.origin.y = ScreenHeight;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    bottomToolbar.frame = bottomFrame;
    bottomToolbar.hidden = YES;
    
    // commit animations
    [UIView commitAnimations];
    
}


- (void)keyboardWillShow:(NSNotification*)notification{
    
    //tableview 滚动到最后
    
    //NSLog(@"%f", talkTableView.contentSize.height);
    //NSLog(@"%f", talkTableView.bounds.size.height);
    //[self scrollToBottom:NO addition:0];
    
    commentInputView.text = @"";
    
    NSLog(@"keyboardWillShow");
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    //CGFloat keyboardHeight = keyboardBounds.size.height;
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect bottomFrame = bottomToolbar.frame;
    
    
    bottomFrame.origin.y =  ScreenHeight - keyboardBounds.size.height - bottomToolbarHeight;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    bottomToolbar.frame = bottomFrame;
    bottomToolbar.hidden = NO;
    // commit animations
    [UIView commitAnimations];
    
}


- (void)getContentCommentsListSuccess:(id)sender
{
    NSLog(@"getContentCommentsListSuccess");
    NSDictionary* feedback = (NSDictionary*)sender;
    
    comments = [[NSMutableArray alloc] init];
    
    NSMutableArray* commentsArray = [[NSMutableArray alloc] initWithArray:[feedback objectForKey:@"comments"]];
    
    for (NSDictionary* element in commentsArray) {
        CommentModel* commentModel = [[CommentModel alloc] init];
        [commentModel setCommentModel:element];
        
        commentModel.contentModel = _contentModel;
        
        
        [comments addObject:commentModel];
        
    }
    
    
    if ([comments count]==0) {
        UILabel* footlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        footlabel.text = @"还没有评论哦~";
        footlabel.font = [UIFont fontWithName:@"Arial" size:18];
        footlabel.textColor = [UIColor grayColor];
        footlabel.textAlignment = NSTextAlignmentCenter;
        self.tableView.tableFooterView = footlabel;
        
    }
    self.tableView.hidden = false;
    [self.tableView reloadData];
    
    getContentCommentsListSuccessFlag = true;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.section == 1) {
        CommentModel * commentModel = [comments objectAtIndex:indexPath.row];
        
        
        if ([commentModel.sendUserInfo.userID isEqualToString:myUserInfo.userID]) {
            return;
        }
        
        [feedbackComments showInView:self.view];
    }
}


- (void)msgException:(id)sender
{
    NSLog(@"msgException");
}

- (void)msgError:(id)sender
{
    
    NSLog(@"msgError");
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        CommentTableViewCell* cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"commentcell" commentElement:[comments objectAtIndex:indexPath.row] content_user_id:_contentModel.userInfo.userID nav:self.navigationController];
        
        return cell;
    }
    
    if (indexPath.section == 0) {
        
        
        static NSString* cellIdentifier = @"ContentTableViewCell";
        ContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        // Configure the cell...
        // Configure the cell...
        if (cell==nil) {
            cell = [[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            NSLog(@"new cell");
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        //cell.contentViewCtrl = self;
        //cell.parentViewController = self.navigationController;
        //cell.index = indexPath;
        
        //NSLog(@"set image");
        
        [cell setContentModel:_contentModel];
        
        return cell;
    }
    
    return nil;
}

- (void)showCommentInputView
{
    NSLog(@"detail showCommentInputView");
    
    
    toCommentUser = nil;
    [commentInputView becomeFirstResponder];
    
    //[commentInputView becomeFirstResponder];
}


- (void)initCommentInputView
{
    bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight+bottomToolbarHeight, ScreenWidth, bottomToolbarHeight)];
    [bottomToolbar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [bottomToolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    bottomToolbar.backgroundColor = activeViewControllerbackgroundColor;
    
    
    commentInputView = [[UITextView alloc] init];
    commentInputView.delegate =self;
    commentInputView.frame = CGRectMake(0, 0, ScreenWidth - 2*40, textViewHeight);
    commentInputView.returnKeyType = UIReturnKeyDone;//设置返回按钮的样式
    
    
    commentInputView.keyboardType = UIKeyboardTypeDefault;//设置键盘样式为默认
    commentInputView.font = [UIFont fontWithName:@"Arial" size:inputfontSize];
    commentInputView.scrollEnabled = YES;
    commentInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    commentInputView.layer.cornerRadius = 4.0;
    commentInputView.layer.borderWidth = 0.5;
    commentInputView.layer.borderColor = sepeartelineColor.CGColor;
    commentInputView.delegate = self;
    
    
    UIBarButtonItem* textfieldButtonItem =[[UIBarButtonItem alloc] initWithCustomView:commentInputView];
    
    UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendComment:)];
    
    NSArray *textfieldArray=[[NSArray alloc]initWithObjects:textfieldButtonItem, sendButton, nil];
    [bottomToolbar setItems:textfieldArray animated:YES];
    
    bottomToolbar.hidden = YES;
    
    [self.navigationController.view addSubview:bottomToolbar];
}





- (void)addCommentException:(id)sender
{
    alertMsg(@"添加评论异常");
}

- (void)addCommentError:(id)sender
{
    alertMsg(@"添加评论错误");
}


- (void)sendComment:(id)sender
{
    if ([commentInputView.text isEqual:@""]||commentInputView.text == nil) {
        return;
    }
    
    NSLog(@"%@", commentInputView.text);
    
    [commentInputView resignFirstResponder];
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    CommentModel* commentModel = [[CommentModel alloc] init];
    
    commentModel.sendUserInfo = myUserInfo;
    commentModel.contentModel = _contentModel;
    
    commentModel.counterUserInfo = toCommentUser;
    if (commentModel.counterUserInfo == nil) {
        commentModel.counterUserInfo = _contentModel.userInfo;
    }
    
    
    commentModel.commentStr = commentInputView.text;
    commentStr = commentInputView.text;
    
    commentInputView.text = @"";
    
    
    //    if (toCommentUser.userID == nil) {
    //        toCommentUser = contentModel.userInfo;
    //    }
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[commentModel.contentModel.contentID, commentModel.sendUserInfo.userID, commentModel.counterUserInfo.userID, commentModel.commentStr, commentModel.sendUserInfo.nickName, @"/addCommentToContent"] forKeys:@[@"content_id", @"user_id", @"to_user_id", @"comment", @"user_name", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addCommentSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mbProgress];
    [mbProgress show:YES];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
            [mbProgress hide:YES];
            [mbProgress removeFromSuperview];
            mbProgress = nil;
    } callObject:self];
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    
    [commentInputView resignFirstResponder];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            return [ContentTableViewCell getTotalHeight:_contentModel maxContentHeight:ScreenHeight];
        }
    }
    
    if (indexPath.section == 1) {
        UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
    
    return 0;
    //UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [comments count];
    }
    
    if (section == 0) {
        return 1;
    }
    
    return 0;
}

- (void)commentButtonAction:(id)sender
{
//    if (getContentBaseInfoSuccessFlag == true&& getContentCommentsListSuccessFlag == true) {
//        PublishCommentViewController* publisComment = [[PublishCommentViewController alloc] init];
//        publisComment.contentDetail = self;
//        publisComment.contentModel = contentModel;
//        if(toCommentUser.userID == nil){
//            toCommentUser.userID = contentModel.userInfo.userID;
//        }
//        publisComment.toCommentUser = toCommentUser;
//        
//        [self presentViewController:publisComment animated:YES completion:nil];
//    }
    
    //弹出键盘
    myTextField.hidden = NO;
    [myTextField becomeFirstResponder];
    
}

- (void)getContentCommentsList
{
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_contentModel.contentID, @"/getContentCommentsList"] forKeys:@[@"content_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(getContentCommentsListSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(msgError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(msgException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:GET_COMMENT_LIST], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}

- (void)addSeeCount
{
    NetWork* netWork = [[NetWork alloc] init];
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[_contentModel.contentID, @"/addSeeCount"] forKeys:@[@"content_id", @"childpath"]];
    
    [netWork message:message images:nil feedbackcall:nil complete:nil callObject:self];
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
