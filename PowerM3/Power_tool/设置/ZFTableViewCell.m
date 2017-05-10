//
//  ZFTableViewCell.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/4/11.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "ZFTableViewCell.h"

@implementation ZFTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)addSubview:(UIView *)view{
    
    NSString* className = NSStringFromClass([view class]);
    
    if (![className isEqualToString:@"UIButton"]&&
        ![className isEqualToString:@"UITableViewCellContentView"]){
        return;
    }
    
    [super addSubview:view];
    
}

@end
