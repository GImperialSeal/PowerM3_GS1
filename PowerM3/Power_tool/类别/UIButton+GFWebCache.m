//
//  UIButton+GFWebCache.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/25.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "UIButton+GFWebCache.h"
#import "NSString+Extension.h"
#import "GFImageCache.h"

#define GFImageFilePathWithUrl(url) [self gf_CacheDirectory:@"图片消息" fileName:url.md5String]

@implementation UIButton (GFWebCache)

- (void)gf_loadImagesWithURL:(NSString *)url{
    [self gf_loadImagesWithURL:url state:UIControlStateNormal];
}

// 加载图片
- (void)gf_loadImagesWithURL:(NSString *)url state:(UIControlState)state{
    // 这里添加  placeholder.image
    [self setImage:[UIImage imageNamed:@"icon_default"] forState:state];
    
    [GFImageCache downLoad:url complete:^(UIImage *image) {
        [self setImage:image forState:state];
    }];
    
}


@end
