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
#import "PublishCommentViewController.h"
#import "Tools.h"
#import <MBProgressHUD.h>
#import "ContentTableViewCell.h"
#import "CommentModel.h"
#import "InputToolbar.h"


@interface ContentDetailViewController ()
{
    UserInfoModel* myUserInfo;
    
    NSMutableArray* comments;
    UIActionSheet* feedbackComments;
    
    UserInfoModel* toCommentUser;
    
    MBProgressHUD* mbProgress;
    
    BOOL getContentCommentsListSuccessFlag;
    
    CommentModel* lastCommentModel;
    
    ContentTableViewCell* contentCell;
    InputToolbar* inputToolbar;
}
@end

@implementation ContentDetailViewController



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
    
    
    
    
    
    [self getContentCommentsList];
    //[self addSeeCount];
   
    feedbackComments = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"赞", @"回复评论", nil];
    toCommentUser = [[UserInfoModel alloc] init];
    
    
    //[self initCommentInputView];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    
    if ([_contentModel.userInfo.userID isEqualToString:myUserInfo.userID]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonAction:)];

    }
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        //[myTextField resignFirstResponder];
        [inputToolbar hideInput];
        [inputToolbar removeFromSuperview];
        inputToolbar = nil;
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
        if (buttonIndex == 1) {
            NSIndexPath* indexPath =  [self.tableView indexPathForSelectedRow];
            
            NSLog(@"%ld", indexPath.row);
            
            CommentModel* commentModel = [comments objectAtIndex:indexPath.row];
            
            toCommentUser = [[UserInfoModel alloc] init];
            toCommentUser.userID = commentModel.sendUserInfo.userID;
            toCommentUser.nickName = commentModel.sendUserInfo.nickName;
            
            _contentModel.to_content = 0;
            [self commentButtonAction:nil];
        }
        
        if (buttonIndex == 0) {
            //赞评论
            NSIndexPath* indexPath =  [self.tableView indexPathForSelectedRow];
            CommentModel* commentModel = [comments objectAtIndex:indexPath.row];
            [self commentGoodAction:commentModel];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

}

- (void)commentGoodActionSuccess:(id)sender
{
    
}

- (void)commentGoodActionRepeat:(id)sender
{
    [Tools AlertBigMsg:@"不能重复点赞"];
}

- (void)commentGoodAction:(CommentModel*)commentModel
{
    NetWork* netWork = [[NetWork alloc] init];
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[commentModel.content_comment_id, myUserInfo.userID, @"/commentGood"] forKeys:@[@"content_comment_id", @"user_id", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(commentGoodActionSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(commentGoodActionRepeat:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:COMMENT_GOOD_EXIST]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}

- (void)addDetailCommentSuccess:(id)sender
{
    CommentModel* commentModel = lastCommentModel;
    
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
    
    
    
    
    [comments insertObject:commentModel atIndex:0];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    self.tableView.tableFooterView = nil;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    

}

- (void)sendAction:(NSString *)msg
{
    [inputToolbar hideInput];
    [inputToolbar removeFromSuperview];
    inputToolbar = nil;
    [self sendDetailComment:msg];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
    
    if (inputToolbar!=nil) {
        [inputToolbar hideInput];
        [inputToolbar removeFromSuperview];
        inputToolbar = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        cell.contentDetail = self;
        
        contentCell = cell;
        return cell;
    }
    
    return nil;
}









- (void)addCommentException:(id)sender
{
    alertMsg(@"添加评论异常");
}

- (void)addCommentError:(id)sender
{
    alertMsg(@"添加评论错误");
}


- (void)sendDetailComment:(id)sender
{
    NSString* msg = (NSString*)sender;
    
    NetWork* netWork = [[NetWork alloc] init];
    
    
    lastCommentModel = [[CommentModel alloc] init];
    
    lastCommentModel.sendUserInfo = myUserInfo;
    lastCommentModel.contentModel = _contentModel;
    
    lastCommentModel.counterUserInfo = toCommentUser;
    if (lastCommentModel.counterUserInfo == nil) {
        lastCommentModel.counterUserInfo = _contentModel.userInfo;
    }
    
    
    lastCommentModel.commentStr = msg;
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[lastCommentModel.contentModel.contentID, lastCommentModel.sendUserInfo.userID, lastCommentModel.counterUserInfo.userID, lastCommentModel.commentStr, lastCommentModel.sendUserInfo.nickName, @"/addCommentToContent"] forKeys:@[@"content_id", @"user_id", @"to_user_id", @"comment", @"user_name", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addDetailCommentSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
//    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:mbProgress];
//    [mbProgress show:YES];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
            //[mbProgress hide:YES];
            //[mbProgress removeFromSuperview];
            //mbProgress = nil;
    } callObject:self];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
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
    inputToolbar = [[InputToolbar alloc] init];
    inputToolbar.inputDelegate = self;
    
    [[Tools curNavigator].view addSubview:inputToolbar];
    
    [inputToolbar showInput];
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
