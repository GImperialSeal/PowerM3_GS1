//
//  UIImage+Extension.h
//  BasicFramework
//
//  Created by Rainy on 16/10/26.
//  Copyright © 2016年 Rainy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

//  取图片某一点的颜色
- (UIColor *)colorAtPoint:(CGPoint )point;

// 取某一像素的颜色
- (UIColor *)colorAtPixel:(CGPoint)point;

// 缩放
- (UIImage*)scaleToSize:(CGSize)size;
// 恢复
- (UIImage *)restoreMyimage;
// 生成图片
+ (UIImage *)createImageWithColor:(UIColor*)color;
// image -> color
- (UIImage *)imageWithColor:(UIColor *)color;
// Set the image rotation Angle
- (UIImage*)image_RotatedByAngle:(CGFloat)Angle;
//  image from view 截图
+ (UIImage *)snapshot:(UIView *)view;


//   图片的压缩方法
+ (UIImage *)IMGCompressed:(UIImage *)sourceImg targetWidth:(CGFloat)defineWidth;

// 获得灰度图
+ (UIImage *)covertToGrayImageFromImage:(UIImage*)sourceImage;

// 获取BundleIMG
+ (UIImage *)imageNamed:(NSString *)IMGName InBundleNamed:(NSString *)BundleName;

//聊天的文字气泡拉伸
+ (UIImage *)resizedImage:(NSString *)name;

//调整图片大小
+ (UIImage *)resizedImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

/* 裁剪圆形图片 例如：头像 */
+ (UIImage *)clipImage:(UIImage *)image;



#pragma mark - blur image
- (UIImage *)lightImage;
- (UIImage *)extraLightImage;
- (UIImage *)darkImage;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;
- (UIImage *)blurredImageWithRadius:(CGFloat)blurRadius;
- (UIImage *)blurredImageWithSize:(CGSize)blurSize;
- (UIImage *)blurredImageWithSize:(CGSize)blurSize
                        tintColor:(UIColor *)tintColor
            saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                        maskImage:(UIImage *)maskImage;
#pragma mark - Blur
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

@end
