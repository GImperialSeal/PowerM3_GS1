//
//  GFContactListView.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/15.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFContactListView : UIView
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, strong) NSMutableDictionary *friendsDict;
@property (nonatomic, strong) UINavigationController *newsNavigationController;
@property (nonatomic, strong) UITabBarController *newsTabbarController;
@end
