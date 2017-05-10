//
//  GFContactListDelegate.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/31.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Foundation;

@interface GFContactListDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSMutableDictionary *friendsDict;
@property (nonatomic, strong) UINavigationController *newsNavigationController;
@end
