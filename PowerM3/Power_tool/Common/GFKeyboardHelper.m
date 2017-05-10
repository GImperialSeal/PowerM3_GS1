//
//  GFKeyboardHelper.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/15.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFKeyboardHelper.h"

@implementation GFKeyboardHelper

#pragma mark -  添加通知
//[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
//[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
//[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];


- (void)keyboardChange:(NSNotification *)noti{
    NSDictionary *userInfo = [noti userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (noti.name == UIKeyboardWillShowNotification) {
            
        }else{
            
        }
    } completion:^(BOOL finished) {
        
    }];
}

@end
