//
//  PowerM3TextField.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/8/4.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "PowerM3TextField.h"

@implementation PowerM3TextField
- (CGRect)textRectForBounds:(CGRect)bounds{
    CGFloat width = CGRectGetWidth(self.leftView.frame);
    bounds.origin.x = 15+bounds.origin.x+width;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    CGFloat width = CGRectGetWidth(self.leftView.frame);
    bounds.origin.x = 15+bounds.origin.x+width;
    
    return bounds;
}

@end
