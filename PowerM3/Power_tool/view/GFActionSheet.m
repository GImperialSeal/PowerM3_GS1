//
//  SheetActionView.m
//  sheet
//
//  Created by 顾玉玺 on 2017/4/10.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//
#define DefaultButtonHeight 49
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#define DefaultButtonTextFont [UIFont systemFontOfSize:17]
#define DefaultButtonTextColor [UIColor blackColor]
#define DefaultButtonBackgroundColor [UIColor whiteColor]
#define PingFangSCRegular(fontSize) [UIFont fontWithName:@"PingFang-SC-Regular" size:fontSize]

#import "GFActionSheet.h"
#import "PureLayout.h"
#import <objc/runtime.h>
@interface GFActionSheet ()
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIWindow *actionWindow;
@property (strong, nonatomic) UIButton *cancelButton;
@property (weak, nonatomic) id delegate;
@property (nonatomic) BOOL isShow;

@end
@implementation GFActionSheet


+ (instancetype)showActionSheetWithTitle:(NSString *)title
                            buttonTitles:(NSArray *)buttonTitles
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                         completionBlock:(void (^)(NSUInteger buttonIndex))block{
    GFActionSheet *action = [[GFActionSheet alloc]initWithTitle:title buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle completionBlock:block];
    return action;
}

+ (void)ActionSheetWithTitle:(NSString *)title
                            buttonTitles:(NSArray *)buttonTitles
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                         completionBlock:(void (^)(NSUInteger buttonIndex))block{
    GFActionSheet *action = [[GFActionSheet alloc]initWithTitle:title buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle completionBlock:block];
    [action show];
}

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
            cancelButtonTitle:(NSString *)cancelButtonTitle
              completionBlock:(void (^)(NSUInteger buttonIndex))block
                     {
    if (self = [super init]) {
        _titleColor = [UIColor grayColor];
        _titleFont = [UIFont systemFontOfSize:12];
        _buttonHeight = DefaultButtonHeight;
        _maskBackgroundColor = [UIColor blackColor];
        _maskAlpha = 0.5;
        _cancleBtnTitleColor = [UIColor blackColor];
        _btnTitleColor = [UIColor redColor];
        
        objc_setAssociatedObject(self, @"block", block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setFrame:(CGRect){0, 0, SCREEN_SIZE}];
        [self.actionWindow addSubview:self];

        // mask view
        UIView *maskView = [[UIView alloc] init];
        [maskView setAlpha:0];
        [maskView setUserInteractionEnabled:NO];
        [maskView setBackgroundColor:_maskBackgroundColor];
        [self addSubview:maskView];
        _maskView = maskView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [maskView addGestureRecognizer:tap];
        
        // bottomview
        UIView *bottomView = [[UIView alloc] init];
        [self addSubview:bottomView];
        [bottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        _bottomView = bottomView;
        
        if (title.length) {
            UIView *titleView = [UIView newAutoLayoutView];
            [titleView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
            [bottomView addSubview:titleView];
            _titleView = titleView;
            UILabel *label = [[UILabel alloc] init];

            [label setText:title];
            [label setTextColor:_titleColor];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:_titleFont];
            [label setNumberOfLines:0];
            [titleView addSubview:label];
            
            [titleView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
            [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
            [titleView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:titleView];

        }
        
        if (buttonTitles.count) {
            UIButton    *previousBtn  = nil;
            for (int i = 0; i < buttonTitles.count; i++) {
                UIImageView *line = [[UIImageView alloc] init];
                line.backgroundColor = [UIColor lightGrayColor];
                [bottomView addSubview:line];
                [self.lines addObject:line];
                
                // 所有按钮
                UIButton *btn = [[UIButton alloc] init];
                [btn setTag:i+1];
                [btn setTitle:buttonTitles[i] forState:UIControlStateNormal];
                [btn setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
                [btn setTitleColor:_btnTitleColor forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
                [bottomView addSubview:btn];
                [self.buttons addObject:btn];
                
                
                if (previousBtn) {
                    [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousBtn];
                }else{
                    if (_titleView) {
                        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleView];
                    }else{
                        [line autoPinEdgeToSuperviewEdge:ALEdgeTop];
                    }
                }
                [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
                [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
                [line autoSetDimension:ALDimensionHeight toSize:.5];
                [btn autoSetDimension:ALDimensionHeight toSize:_buttonHeight];
                [btn autoPinEdgeToSuperviewEdge:ALEdgeLeft];
                [btn autoPinEdgeToSuperviewEdge:ALEdgeRight];
                [btn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
                previousBtn  = btn;
            }
        }
        
        UIImageView *line = [[UIImageView alloc] init];
        line.backgroundColor = [UIColor clearColor];
        [bottomView addSubview:line];
        
        if (self.buttons.lastObject) {
            [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.buttons.lastObject];
        }else{
            if (self.titleView) {
                [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleView];
            }else{
                [line autoPinEdgeToSuperviewEdge:ALEdgeTop];
            }
        }
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoSetDimension:ALDimensionHeight toSize:6];
        // 取消按钮
        UIButton *cancelBtn = [[UIButton alloc] init];
        [cancelBtn setTag:0];
        [cancelBtn setTitleColor:_cancleBtnTitleColor forState:UIControlStateNormal];
        [cancelBtn setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
        [cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:cancelBtn];
        [cancelBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
        [cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [cancelBtn autoSetDimension:ALDimensionHeight toSize:_buttonHeight];

        [self.buttons addObject:cancelBtn];
        _cancelButton = cancelBtn;
       
        
        // 模糊
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
        [bottomView addSubview:effectView];
        [bottomView sendSubviewToBack:effectView];
        [effectView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        [maskView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [maskView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:bottomView];

    }
    
    return self;
}

- (void)show {
    if (self.isShow) {
        return;
    }
    
    _actionWindow.hidden = NO;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [_maskView setAlpha:_maskAlpha];
                         [_maskView setUserInteractionEnabled:YES];
                         [_bottomView autoSetDimension:ALDimensionHeight toSize:CGRectGetMaxY(_cancelButton.frame)];
                         [self layoutIfNeeded];

                     }
                     completion:nil];
    
    self.isShow = YES;
}

- (void)dismiss:(UITapGestureRecognizer *)tap {
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [_maskView setAlpha:0];
                         [_maskView setUserInteractionEnabled:NO];
                         _bottomView.transform = CGAffineTransformMakeTranslation(0, CGRectGetMaxY(_cancelButton.frame));
                     }
                     completion:^(BOOL finished) {
                         _actionWindow.hidden = YES;
                         
                         [self removeFromSuperview];
                         self.isShow = NO;
                     }];
}

- (UIWindow *)actionWindow {
    if (_actionWindow == nil) {
        
        _actionWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _actionWindow.windowLevel       = UIWindowLevelStatusBar;
        _actionWindow.backgroundColor   = [UIColor clearColor];
        _actionWindow.hidden = NO;
    }
    
    return _actionWindow;
}
- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [[NSMutableArray alloc] init];
    }
    return _buttons;
}

- (NSMutableArray *)lines {
    if (!_lines) {
        _lines = [[NSMutableArray alloc] init];
    }
    return _lines;
}


#pragma mark - click func

- (void)didClickBtn:(UIButton *)btn {
    [self dismiss:nil];

    void (^complete)(NSUInteger index) = objc_getAssociatedObject(self, @"block");

    if (complete) {
        complete(btn.tag);
    }
}
@end
