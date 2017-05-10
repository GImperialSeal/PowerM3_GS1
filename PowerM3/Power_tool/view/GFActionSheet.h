//
//  SheetActionView.h
//  sheet
//
//  Created by 顾玉玺 on 2017/4/10.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFActionSheet : UIView
/**
 *  遮罩层
 *  maskBackgroundColor 遮罩层背景颜色, 默认为blackColor
 *  maskAlpha遮罩层alpha, 默认为0.5
 */
@property (strong, nonatomic) UIColor *maskBackgroundColor;
@property (nonatomic) CGFloat maskAlpha;

/**
 *  title
 *  title font  默认12
 *  title corlor 默认graycorlor
 */
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *titleColor;


/**
 *  按钮
 *  按钮高度 默认为49
 *  按钮颜色 默认红色
 *  取消按钮颜色 默认黑色
 */
@property (assign,nonatomic) CGFloat buttonHeight;
@property (strong, nonatomic) UIColor *btnTitleColor;
@property (strong, nonatomic) UIColor *cancleBtnTitleColor;


+ (instancetype)showActionSheetWithTitle:(NSString *)title
                            buttonTitles:(NSArray *)buttonTitles
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                         completionBlock:(void (^)(NSUInteger buttonIndex))block;


/**
 默认弹框

 @param title 标题
 @param buttonTitles title数组
 @param cancelButtonTitle 取消按钮标题
 @param block 索引  取消索引默认为0
 */
+ (void)ActionSheetWithTitle:(NSString *)title
                buttonTitles:(NSArray *)buttonTitles
           cancelButtonTitle:(NSString *)cancelButtonTitle
             completionBlock:(void (^)(NSUInteger buttonIndex))block;

- (void)show;


@end
