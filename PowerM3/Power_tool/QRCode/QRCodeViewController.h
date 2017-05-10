//
//  QRCodeController.h
//  PowerPMS
//
//  Created by ImperialSeal on 16/5/26.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFLoginViewController.h"
@interface QRCodeViewController : UIViewController

@property(nonatomic, copy) void(^didFinishedScanedQRCode)(NSString *resultstring);

@end
