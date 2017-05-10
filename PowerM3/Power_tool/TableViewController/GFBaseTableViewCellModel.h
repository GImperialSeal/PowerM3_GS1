//
//  GFBaseTableViewCellModel.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GFBaseTableViewCell;
typedef enum : NSInteger{
    GFBaseTableViewCellTypeNone, // 什么也没有
    GFBaseTableViewCellTypeArrow, // 箭头
    GFBaseTableViewCellTypeSwitch // 开关
} GFBaseTableViewCellAccessoryType;

typedef enum : NSInteger{
    GFBaseTableViewCellTypeDefault, // leftImage + title
    GFBaseTableViewCellTypeLeftTitle, //lefttitle +  tiltle
    GFBaseTableViewCellTypeRightImage, //lefttitle + rightImage
    GFBaseTableViewCellTypeValue1
} GFBaseTableViewCellTypedef;
@interface GFBaseTableViewCellModel : NSObject

@property (nonatomic) GFBaseTableViewCellAccessoryType accessoryType;
/** cell上开关的操作事件 */
@property (nonatomic) GFBaseTableViewCellTypedef cellType;

@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *centerImage;
@property (nonatomic, strong) NSString *rightImage;

@property (nonatomic, strong) NSString *leftTitle;
@property (nonatomic, strong) NSString *centerTitle;
@property (nonatomic, strong) NSString *rightTitle;

@property (nonatomic, strong) UIColor  *centerBackgroundColor;
@property (nonatomic, strong) UIColor  *centerTitleColor;

@property (nonatomic) CGFloat  centerCornerRadius;

@property (nonatomic, strong) NSString *detailTitle;


@property (nonatomic) CGFloat cellRowHeight;

@property (nonatomic, copy) void (^switchBlock)(BOOL on) ;
@property (nonatomic, copy) void (^block)(GFBaseTableViewCellModel *model,UITableViewCell *cell);
@end
