//
//  ZFSettingGroup.m
//  ZFSetting
//
//  Created by 任子丰 on 15/9/19.
//  Copyright (c) 2013年 任子丰. All rights reserved.
//

#import "ZFSettingGroup.h"

@implementation ZFSettingGroup

+ (instancetype)groupWithItem:(NSArray *)items{
    ZFSettingGroup *g = [[self alloc]init];
    g.items = items;
    return g;
}
@end
