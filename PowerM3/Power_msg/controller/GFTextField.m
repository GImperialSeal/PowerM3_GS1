//
//  GFTextField.m
//  12212
//
//  Created by 顾玉玺 on 2017/4/12.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import "GFTextField.h"

@implementation GFTextField

- (CGRect)editingRectForBounds:(CGRect)bounds{
    CGFloat width = CGRectGetWidth(self.leftView.frame);
    bounds.origin.x = bounds.origin.x+width + 8;
    return bounds;
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    CGFloat width = CGRectGetWidth(self.leftView.frame);
    bounds.origin.x = bounds.origin.x+width + 8;
    return bounds;
}


- (void)deleteBackward{
    // 代理方法在   删除  字符前面响应
    if (_deleteBackwordDelegate&&[_deleteBackwordDelegate respondsToSelector:@selector(textFieldDeleteBackward:)]) {
        [_deleteBackwordDelegate textFieldDeleteBackward:self];
    }

    [super deleteBackward];
}

@end
