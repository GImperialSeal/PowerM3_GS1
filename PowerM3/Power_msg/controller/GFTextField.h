//
//  GFTextField.h
//  12212
//
//  Created by 顾玉玺 on 2017/4/12.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GFTextFieldDelegate <NSObject>

- (void)textFieldDeleteBackward:(UITextField *)textField;


@end
@interface GFTextField : UITextField

@property (nonatomic, assign) id<GFTextFieldDelegate> deleteBackwordDelegate;

@end
