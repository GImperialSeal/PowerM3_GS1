//
//  UIButton+GFWebCache.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/25.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (GFWebCache)

- (void)gf_loadImagesWithURL:(NSString *)url;
- (void)gf_loadImagesWithURL:(NSString *)url state:(UIControlState)state;

@end
