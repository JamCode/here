//
//  inputToolbar.h
//  here_ios
//
//  Created by wang jam on 11/10/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol inputToolbarDelegate <NSObject>

@optional
- (void)sendAction:(NSString*)msg; //点击发送响应函数
@end


@interface inputToolbar : UIToolbar<UITextViewDelegate>

@property id<inputToolbarDelegate> inputDelegate;

- (void)showInput;
- (void)hideInput;


@end
