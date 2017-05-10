//
//  GFItemModel.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/9.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *headImageUrl;
@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) void(^didSelectedRowBlock)(UITableView *tableView,NSIndexPath *indexPath) ;
- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle headImage:(NSString *)image;

@end
