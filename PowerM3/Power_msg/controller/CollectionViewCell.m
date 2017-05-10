//
//  CollectionViewCell.m
//  12212
//
//  Created by 顾玉玺 on 2017/4/11.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.tag = 303;
        imageView.image = [UIImage imageNamed:@"123.jpg"];
        [self.contentView addSubview:imageView];
    }
    
    
    return self;
}

// 选中时候添加 maskview
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        UIView *view = [[UIView alloc]initWithFrame:self.bounds];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        view.tag = 100;
        [self addSubview:view];
    }else{
        [[self viewWithTag:100] removeFromSuperview];
    }
}
@end
