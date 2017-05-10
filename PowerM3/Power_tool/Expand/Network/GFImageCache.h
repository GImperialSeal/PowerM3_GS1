//
//  GFImageCache.h
//  09-多图片多线程下载
//
//  Created by 顾玉玺 on 2017/4/26.
//  Copyright © 2017年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface GFImageCache : NSObject


+ (void)downLoad:(NSString *)url complete:(void(^)(UIImage *image))block;

@end
