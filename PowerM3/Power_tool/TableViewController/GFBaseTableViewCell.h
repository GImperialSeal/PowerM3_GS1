//
//  GFBaseTableViewCell.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/6.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFBaseTableViewCellModel;

@interface GFBaseTableViewCell : UITableViewCell

@property (copy, nonatomic) void(^switchChangeBlock)(BOOL on);

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)configCellWithModel:(GFBaseTableViewCellModel *)model;
@end
