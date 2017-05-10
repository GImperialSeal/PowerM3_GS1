//
//  UIImageView+PowerCache.h
//  PowerPMS
//
//  Created by ImperialSeal on 16/9/6.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (PowerCache)
// 加载图片
- (void)gf_loadImagesWithURL:(NSString *)url;

- (void)gf_loadImagesWithURL:(NSString *)url completion:(dispatch_block_t)block;

// 弹出图片浏览器
- (void)showAvatarBrowserImage;

@end

