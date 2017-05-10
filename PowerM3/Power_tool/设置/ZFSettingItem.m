//
//  ZFSettingItem.m
//  ZFSetting
//
//  Created by 任子丰 on 15/9/19.
//  Copyright (c) 2013年 任子丰. All rights reserved.
//

#import "ZFSettingItem.h"

@implementation ZFSettingItem
+ (id)itemWithIcon:(NSString *)icon title:(NSString *)title  subtitle:(NSString *)subtitle type:(ZFSettingItemType)type
{
    ZFSettingItem *item = [[self alloc] init];
    item.icon = icon;
    item.title = title;
    item.type = type;
    item.subtitle = subtitle;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle{
    ZFSettingItem *item = [[self alloc] init];
    item.title = title;
    item.type = ZFSettingItemTypeArrow;
    item.subtitle = subtitle;
    return item;
}

+ (instancetype)itemWithImage:(NSString *)url title:(NSString *)title{
    ZFSettingItem *item = [[self alloc] init];
    item.title = title;
    item.type = ZFSettingItemTypeNone;
    item.icon = url;
    return item;
}

+ (instancetype)itemWithSwichTitle:(NSString *)title {
    ZFSettingItem *item = [[self alloc] init];
    item.title = title;
    item.type = ZFSettingItemTypeSwitch;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title type:(ZFSettingItemType)type{
    ZFSettingItem *item = [[self alloc] init];
    item.title = title;
    item.type = type;
    return item;
}


+ (instancetype)itemWithHeadImage:(NSString *)image title:(NSString *)title subtitle:(NSString *)subtitle{
    ZFSettingItem *item = [[self alloc] init];
    item.title = title;
    item.subtitle = subtitle;
    item.type = ZFSettingItemTypeHeadImage;
    item.icon = image;
    item.rowHeight = 80;
    return item;
}


- (instancetype)init{
    if ([super init]) {
      
        self.rowHeight = 44;
        self.backCellViewColor = [UIColor redColor];
    }
    
    return self;
}
@end
