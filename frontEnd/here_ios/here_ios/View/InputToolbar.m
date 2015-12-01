//
//  inputToolbar.m
//  here_ios
//
//  Created by wang jam on 11/10/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "InputToolbar.h"
#import "Constant.h"
#import "macro.h"

@implementation InputToolbar
{
    UITextView* commentInputView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static const int inputfontSize = 16;
static const double textViewHeight = 36;
static const double bottomToolbarHeight = 48;

- (id)init
{
    if (self = [super init]) {
        
        self.frame = CGRectMake(0, ScreenHeight+bottomToolbarHeight, ScreenWidth, bottomToolbarHeight);
        
        [self setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
        self.backgroundColor = activeViewControllerbackgroundColor;
        
        
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
        
        
        UIBarButtonItem* textfieldButtonItem =[[UIBarButtonItem alloc] initWithCustomView:commentInputView];
        
        
        
                
        UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMsg)];
        
        NSArray *textfieldArray=[[NSArray alloc]initWithObjects:textfieldButtonItem, sendButton, nil];
        [self setItems:textfieldArray animated:YES];
        
        self.hidden = YES;
        
        //[commentInputView becomeFirstResponder];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        

    }
    return self;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == commentInputView) {
        if ([text isEqualToString:@"\n"]) {
            [self sendMsg];
            return NO;
        }
        return YES;
    }
    return YES;
}


- (void)sendMsg
{
    NSString* msg = [commentInputView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([msg isEqualToString:@""]) {
        return;
    }
    
    if (_inputDelegate != nil) {
        [_inputDelegate sendAction:commentInputView.text];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    if (![commentInputView isFirstResponder]) {
        return;
    }
    
    commentInputView.text = @"";
    
    NSLog(@"keyboardWillShow");
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    //CGFloat keyboardHeight = keyboardBounds.size.height;
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect bottomFrame = self.frame;
    
    
    bottomFrame.origin.y =  ScreenHeight - keyboardBounds.size.height - bottomToolbarHeight;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    self.frame = bottomFrame;
    self.hidden = NO;
    // commit animations
    [UIView commitAnimations];
    
    
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    //keyboardHeight = 0;
    
    //CGRect btnFrame = talkTableView.frame;
    CGRect bottomFrame = self.frame;
    //btnFrame.origin.y = 0;
    bottomFrame.origin.y = ScreenHeight;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    self.frame = bottomFrame;
    self.hidden = YES;
    
    // commit animations
    [UIView commitAnimations];
}


- (void)hideInput
{
    [commentInputView resignFirstResponder];
}

- (void)showInput
{
    if (![commentInputView isFirstResponder]) {
        [commentInputView becomeFirstResponder];
    }
}

@end
