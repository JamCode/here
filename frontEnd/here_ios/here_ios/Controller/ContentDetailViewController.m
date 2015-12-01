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
    
    inputToolbar = [[InputToolbar alloc] init];
    inputToolbar.inputDelegate = self;
    
    [[Tools curNavigator].view addSubview:inputToolbar];
    
    
    
    [self getContentCommentsList];
    //[self addSeeCount];
   
    feedbackComments = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"赞", @"回复评论", nil];
    
    
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStylePlain target:self action:@selector(commentButtonAction:)];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [inputToolbar showInput];

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
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

        }
        
        if (buttonIndex == 0) {
            //赞评论
            NSIndexPath* indexPath =  [self.tableView indexPathForSelectedRow];
            CommentModel* commentModel = [comments objectAtIndex:indexPath.row];
            [self commentGoodAction:commentModel];
        }
    }
    

}

- (void)commentGoodActionSuccess:(id)sender
{
    
    NSIndexPath* indexpath = [self.tableView indexPathForSelectedRow];
    CommentModel* commentmodel = [comments objectAtIndex:indexpath.row];
    commentmodel.comment_good_count++;
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];

}

- (void)commentGoodActionRepeat:(id)sender
{
    [Tools AlertBigMsg:@"不能重复点赞"];
}

- (void)commentGoodAction:(CommentModel*)commentModel
{
    NetWork* netWork = [[NetWork alloc] init];
    
    NSLog(@"%@", commentModel.sendUserInfo.userID);
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[commentModel.content_comment_id, myUserInfo.userID, commentModel.sendUserInfo.userID, myUserInfo.nickName,  @"/commentGood"] forKeys:@[@"content_comment_id", @"user_id", @"comment_user_id", @"user_name",  @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(commentGoodActionSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(commentGoodActionRepeat:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:COMMENT_GOOD_EXIST]]];
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:nil callObject:self];
}


- (void)addNewCommentCell:(CommentModel*)commentModel
{
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    mbProgress.mode = MBProgressHUDModeText;
    [self.view addSubview:mbProgress];
    mbProgress.labelText = @"评论成功";
    [mbProgress show:YES];
    [mbProgress hide:YES afterDelay:1.0];
    
    [self.tableView beginUpdates];
    
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject:indexPath];
    
    
    
    
    [comments insertObject:commentModel atIndex:0];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    self.tableView.tableFooterView=[[UIView alloc]init];
}

- (void)addDetailCommentSuccess:(id)sender
{
    CommentModel* commentModel = lastCommentModel;
    
    [self addNewCommentCell:commentModel];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];


}

- (void)sendAction:(NSString *)msg
{
    msg = [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([msg isEqualToString:@""]) {
        return;
    }
    
    [inputToolbar hideInput];
    [self sendDetailComment:msg];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [inputToolbar hideInput];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
    
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
    if (indexPath.section == 0) {
        CommentTableViewCell* cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"commentcell" commentElement:[comments objectAtIndex:indexPath.row] content_user_id:_contentModel.userInfo.userID nav:self.navigationController];
        
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
    
    
    if (toCommentUser != nil) {
        lastCommentModel.counterUserInfo = toCommentUser;
        lastCommentModel.to_content = 0;
    }else{
        lastCommentModel.counterUserInfo = _contentModel.userInfo;
        lastCommentModel.to_content = 1;
    }
    
    lastCommentModel.publish_time = [[NSDate date] timeIntervalSince1970];
    lastCommentModel.commentStr = msg;
    
    
    NSDictionary* message = [[NSDictionary alloc] initWithObjects:@[lastCommentModel.contentModel.contentID, lastCommentModel.sendUserInfo.userID, lastCommentModel.counterUserInfo.userID, lastCommentModel.commentStr, lastCommentModel.sendUserInfo.nickName, [[NSNumber alloc] initWithInteger:lastCommentModel.to_content], @"/addCommentToContent"]forKeys:@[@"content_id", @"user_id", @"to_user_id", @"comment", @"user_name", @"to_content", @"childpath"]];
    
    NSDictionary* feedbackcall = [[NSDictionary alloc] initWithObjects:@[[NSValue valueWithBytes:&@selector(addDetailCommentSuccess:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentError:) objCType:@encode(SEL)], [NSValue valueWithBytes:&@selector(addCommentException:) objCType:@encode(SEL)]] forKeys:@[[[NSNumber alloc] initWithInt:SUCCESS], [[NSNumber alloc] initWithInt:ERROR], [[NSNumber alloc] initWithInt:EXCEPTION]]];
    
    
    [netWork message:message images:nil feedbackcall:feedbackcall complete:^{
        toCommentUser = nil;
    } callObject:self];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.tableView){
        if(inputToolbar!=nil){
            [inputToolbar hideInput];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentButtonHide" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentKeyboardHide" object:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        return [CommentTableViewCell getCellHeight:[comments objectAtIndex:indexPath.row]];
    }
    
    return 0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [comments count];
    }
    
    return 0;
}

- (void)commentButtonAction:(id)sender
{
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
