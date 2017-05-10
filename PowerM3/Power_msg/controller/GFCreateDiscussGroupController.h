//
//  ViewController.h
//  12212
//
//  Created by 顾玉玺 on 2017/4/11.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>

@interface GFCreateDiscussGroupController : UIViewController



/**
 讨论组成员id列表
 */
@property (nonatomic, strong) NSArray *memberListArray;

/**
 区头 字符A~Z
 */
@property (nonatomic, strong) NSArray *sectionTitlesArray;

/**
 数据源 {@"A":@[]}
 */
@property (nonatomic, strong) NSDictionary *sourceDictionary;


/**
 是佛显示字母索引
 */
@property (nonatomic) BOOL  showSectionIndex;



/**
 back  rcinfo id
 */
@property (nonatomic, copy) void(^completeBlock)(NSArray<NSString *> *choosedArray);


@end

