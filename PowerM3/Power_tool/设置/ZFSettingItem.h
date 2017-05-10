//
//  ZFSettingItem.h
//  ZFSetting
//
//  Created by 任子丰 on 15/9/19.
//  Copyright (c) 2013年 任子丰. All rights reserved.
//  一个Item对应一个Cell
// 用来描述当前cell里面显示的内容，描述点击cell后做什么事情

#import <Foundation/Foundation.h>

typedef enum : NSInteger{
    ZFSettingItemTypeNone,      // 什么也没有
    ZFSettingItemTypeArrow,     // 箭头
    ZFSettingItemTypeSwitch,    // 开关
    ZFSettingItemTypeSignout,   // 退出
    ZFSettingItemTypeHeadImage, // 头像
    ZFSettingItemTypeCustom     // 自定义
} ZFSettingItemType;

@interface ZFSettingItem : NSObject
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) UIColor *backCellViewColor;

@property (nonatomic) CGFloat rowHeight;


@property (nonatomic) BOOL switchDefaultState;
@property (nonatomic, assign) ZFSettingItemType type;// Cell的样式
/** cell上开关的操作事件 */
@property (nonatomic, copy) void (^switchBlock)(BOOL on) ;


@property (nonatomic, copy) void (^operation)(ZFSettingItem *item) ; // 点击cell后要执行的操作

+ (id)itemWithIcon:(NSString *)icon title:(NSString *)title  subtitle:(NSString *)subtitle type:(ZFSettingItemType)type;
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
+ (instancetype)itemWithSwichTitle:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title type:(ZFSettingItemType)type;
+ (instancetype)itemWithImage:(NSString *)url title:(NSString *)title;
+ (instancetype)itemWithHeadImage:(NSString *)image title:(NSString *)title subtitle:(NSString *)subtitle;

@end
