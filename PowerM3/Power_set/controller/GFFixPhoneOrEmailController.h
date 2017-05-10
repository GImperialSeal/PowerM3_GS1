//
//  GFFixPhoneOrEmailController.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/19.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFSettingItem;
@interface GFFixPhoneOrEmailController : UIViewController

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic) BOOL isPhone;
@property (nonatomic,strong) ZFSettingItem *model;

@end
