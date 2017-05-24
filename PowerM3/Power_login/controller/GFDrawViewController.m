//
//  GFDrawViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/8.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFDrawViewController.h"
#import "GFTabBarController.h"
#import "GFMenuViewController.h"
#import "PureLayout.h"
#define OffX KW-80

@interface GFDrawViewController ()

@end

@implementation GFDrawViewController

- (id)initWithRootViewController:(UIViewController*)controller{
    if (self = [super init]) {
        _rootViewController = controller;

    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.rootViewController.view];
    [self.rootViewController.view autoPinEdgesToSuperviewEdges];
    [self addChildViewController:_rootViewController];
}

- (void)showShowMenuViewControllerWithAnimation{
    
    // mask view
    
    UITabBarController *tabbar = (UITabBarController *)_rootViewController;
    
    UINavigationController *nav =  tabbar.viewControllers.firstObject;
    
    UIViewController *vc = nav.topViewController;
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    
    effectView.tag = 100;
    
    effectView.frame = vc.view.bounds;
    
    [vc.view addSubview:effectView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [effectView addGestureRecognizer:tap];
    
    // menu view
    _menuViewController.view.frame = CGRectMake(0, 0, OffX, KH);
    _menuViewController.view.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_menuViewController.view  atIndex:0];
    //[_menuViewController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
    [self addChildViewController:_menuViewController];
    
    // animate
    [UIView animateWithDuration:.3 animations:^{
    self.rootViewController.view.transform = CGAffineTransformMakeTranslation(OffX, 0);
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:.3 animations:^{
        self.rootViewController.view.transform = CGAffineTransformIdentity;
        self.clickedMaskView();
    } completion:^(BOOL finished) {
        [_menuViewController.view removeFromSuperview];
        [_menuViewController removeFromParentViewController];
        [[_rootViewController.view viewWithTag:100] removeFromSuperview];
    }];
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
