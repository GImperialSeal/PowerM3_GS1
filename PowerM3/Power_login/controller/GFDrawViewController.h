//
//  GFDrawViewController.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/8.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GFDrawViewController : UIViewController


@property (nonatomic,strong) UIViewController *menuViewController;
@property (nonatomic,strong) UIViewController *rootViewController;

@property (nonatomic, copy) dispatch_block_t clickedMaskView;

- (instancetype)initWithRootViewController:(UIViewController*)controller;

- (void)showShowMenuViewControllerWithAnimation;

- (void)dismiss;



@end
