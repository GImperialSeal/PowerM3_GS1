//
//  GFAlertView.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/5.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFAlertView : UIAlertView

+ (void)alertWithTitle:(NSString*)message;

+ (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
         completionBlock:(void (^)(NSUInteger buttonIndex, GFAlertView *alertView))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles, ...;


@end
