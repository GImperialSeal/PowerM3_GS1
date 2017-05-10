//
//  GFPopView.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/28.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXPopover;
@interface GFPopView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, copy)   void(^completeBlock)(NSInteger index);

+ (void)popTableViewAtPoint:(CGPoint)point inView:(UIViewController *)vc completion:(void(^)(NSInteger index))complete titles:(NSString *)titles,...;


@end
