//
//  UISearchBar+Extension.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/17.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "UISearchBar+Extension.h"

@implementation UISearchBar (Extension)

- (void)hiddenLinesWithColor:(UIColor *)color{
    //self.searchBarStyle = UISearchBarStyleMinimal;
    UIImageView *barImageView = [[[self.subviews firstObject] subviews] firstObject];
    barImageView.layer.borderColor = color.CGColor;
    barImageView.layer.borderWidth = 1;
}

- (void)settingSearchBar{
    // 取消 以及 光标的颜色
    self.tintColor = GFThemeColor;
    
    UITextField *searchField=[self valueForKey:@"_searchField"];
    
    // 设置输入框背景色
    searchField.backgroundColor = [UIColor whiteColor];

    // field style
    searchField.borderStyle = UITextBorderStyleRoundedRect;

    // 未尝试
    // searchField.background = [UIImage imageNamed:@"ic_top"];
    // searchField.leftViewMode = UITextFieldViewModeNever;
    // searchField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"ic_map_topbar_search"]];
    // searchField.textColor=[UIColor whiteColor];
    // 改变placeholder的颜色
    // [searchField setValue:[UIColor whiteColor]forKeyPath:@"_placeholderLabel.textColor"];

    // 去除边框线
    UIImageView *barImageView = [[[self.subviews firstObject] subviews] firstObject];
    barImageView.layer.borderColor = self.barTintColor.CGColor;
    barImageView.layer.borderWidth = 1;
}

@end
