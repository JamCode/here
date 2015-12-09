//
//  inputToolbar.h
//  here_ios
//
//  Created by wang jam on 11/10/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol InputToolbarDelegate <NSObject>

@optional
- (void)sendAction:(NSString*)msg; //点击发送响应函数
@end


@interface InputToolbar : UIToolbar<UITextViewDelegate>

@property id<InputToolbarDelegate> inputDelegate;

- (void)showInput;
- (void)hideInput;


@end
