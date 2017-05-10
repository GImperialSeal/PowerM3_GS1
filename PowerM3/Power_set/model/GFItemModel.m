//
//  GFItemModel.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/9.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFItemModel.h"

@implementation GFItemModel

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle headImage:(NSString *)image{
    if (self = [super init]) {
        self.title = title;
        self.subTitle = subTitle;
        self.headImageUrl = image;
    }
    return self;
}
@end
