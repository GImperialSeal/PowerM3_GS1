//
//  ViewController.h
//  jjj
//
//  Created by 顾玉玺 on 2017/4/7.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFTextFieldController : UIViewController

@property (nonatomic, strong) NSString *footer;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, copy) void(^completeBlock)(NSString *text);


@end

