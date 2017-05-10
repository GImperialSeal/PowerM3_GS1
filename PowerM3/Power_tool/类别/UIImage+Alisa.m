//
//  UIImage+Alisa.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/9/27.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "UIImage+Alisa.h"

@implementation UIImage (Alisa)
- (UIImage *)gf_scaleImageToWidth:(CGFloat)scaleWidth{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGSize size ;
    if (width >scaleWidth) {
        CGFloat scale = width/scaleWidth;
        CGFloat newHeght = height/scale;
        if (newHeght>scaleWidth) {
            CGFloat scale = newHeght/scaleWidth;
            size = CGSizeMake(scaleWidth/scale, scaleWidth);
        }else{
            size = CGSizeMake(scaleWidth, newHeght);
        }
    }else{
        if (height>200) {
            CGFloat scale = height/scaleWidth;
            size = CGSizeMake(width/scale, scaleWidth);
        }else{
            size = CGSizeMake(width, height);
        }
    }
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // 开始上下文 目标大小是 这么大
    UIGraphicsBeginImageContext(rect.size);
    
    // 在指定区域内绘制图像
    [self drawInRect:rect];
    
    // 从上下文中获得绘制结果
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文返回结果
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)gf_scaleImageToSize:(CGSize)size{
    if ( size.width <= 0) {
        return nil;
    }
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // 开始上下文 目标大小是 这么大
    UIGraphicsBeginImageContext(rect.size);
    
    // 在指定区域内绘制图像
    [self drawInRect:rect];
    
    // 从上下文中获得绘制结果
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文返回结果
    UIGraphicsEndImageContext();
    return resultImage;
}



@end
