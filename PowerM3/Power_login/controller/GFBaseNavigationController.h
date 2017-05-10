//
//  GFBaseNavigationController.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/16.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFBaseNavigationController : UINavigationController
//  导航设置
- (void)setNavigationBarTitleColor:(UIColor *)color;
- (void)setNavigationBarTranslucent:(BOOL)translucent;
- (void)setNavigationBarBackgroundColor:(UIColor *)color;
- (void)setNavigationBarItemColor:(UIColor *)color;
- (void)setNavigationBarBottomLineView:(BOOL)hidden;
@end
