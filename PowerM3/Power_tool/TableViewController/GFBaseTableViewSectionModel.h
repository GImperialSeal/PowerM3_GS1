//
//  GFBaseTableViewGroupModel.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GFBaseTableViewCellModel;
@interface GFBaseTableViewSectionModel : NSObject
@property (nonatomic, copy) NSString *gf_header; // 头部标题
@property (nonatomic, copy) NSString *gf_footer; // 尾部标题

@property (nonatomic, strong) UIColor *gf_backgroundColor;
@property (nonatomic, strong) UIColor *gf_titleColor;
@property (nonatomic) CGFloat gf_heightForHeader;
@property (nonatomic) CGFloat gf_heightForFooder;

@property (nonatomic,copy)   dispatch_block_t didClick_header;
@property (nonatomic, strong) NSArray<GFBaseTableViewCellModel *> *cellModelArray; // 中间的条目
@end
