//
//  GFPickerHelper.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/2/23.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFPickerHelper : NSObject
+ (void)pickerImages:(UIViewController *)vc didFinishPicking:(void(^)(NSArray *images))complete;
+ (void)pickerVideoWithPresentController:(UIViewController *)vc didFinishPicking:(void(^)(NSString *path))complete;

@end
