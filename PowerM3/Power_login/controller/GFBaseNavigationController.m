
//
//  GFBaseNavigationController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/16.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFBaseNavigationController.h"

@interface GFBaseNavigationController ()

@end

@implementation GFBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setNavigationBarTitleColor:(UIColor *)color{
    // 设置title 颜色
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:color}];
}

- (void)setNavigationBarTranslucent:(BOOL)translucent{
    [self.navigationBar setTranslucent:NO];
}

- (void)setNavigationBarBackgroundColor:(UIColor *)color{
    // 设置navigationbar的颜色
    [self.navigationBar setBarTintColor:color];
}


- (void)setNavigationBarItemColor:(UIColor *)color{
    // 设置navigationbar上左右按钮字体颜色
    [self.navigationBar setTintColor:color];
}

- (void)setNavigationBarBottomLineView:(BOOL)hidden{
    UIImage *image = nil;
    if(hidden)image = [UIImage new];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = image;
    
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
