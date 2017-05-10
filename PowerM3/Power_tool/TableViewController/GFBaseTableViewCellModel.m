//
//  GFBaseTableViewCellModel.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFBaseTableViewCellModel.h"

@implementation GFBaseTableViewCellModel

#pragma mark - 缩放图片
- (UIImage *)scaleImage:(UIImage *)image width:(CGFloat)scaleWidth{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGSize size ;
    if (width >200) {
        CGFloat scale = width/200;
        CGFloat newHeght = height/scale;
        if (newHeght>200) {
            CGFloat scale = newHeght/200;
            size = CGSizeMake(200/scale, 200);
        }else{
            size = CGSizeMake(200, newHeght);
        }
    }else{
        if (height>200) {
            CGFloat scale = height/200;
            size = CGSizeMake(width/scale, 200);
        }else{
            size = CGSizeMake(width, height);
        }
    }
    self.cellRowHeight = size.height;

    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

@end
