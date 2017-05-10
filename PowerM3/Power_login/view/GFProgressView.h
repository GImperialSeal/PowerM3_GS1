//
//  ProgressView.h
//  PowerPMS
//
//  Created by ImperialSeal on 16/6/6.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface GFProgressView : UIView
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,strong) CAGradientLayer *gradient;
@property (nonatomic,strong) NSTimer *timer;
@end
