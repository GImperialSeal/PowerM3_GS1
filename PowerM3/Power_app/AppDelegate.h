//
//  AppDelegate.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/3.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "GFDrawViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) GFDrawViewController *drawViewController;

- (void)loginWithNeedLogin:(BOOL)logined;

@end

