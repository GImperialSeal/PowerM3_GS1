//
//  GFPrefix.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/4.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#ifndef GFPrefix_h
#define GFPrefix_h

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ImperialMacros.h"
#import "GFAlertView.h"
#import "MBProgressHUD+Add.h"
#import "MagicalRecord.h"
#import "UIImageView+PowerCache.h"
#import "UIDevice+Extension.h"
#import "NSDictionary+Extension.h"
#import "GFNetworkHelper.h"
#import "HSDownloadManager.h"
#import "GFCommonHelper.h"
#import "GFDomainManager.h"
#import "GFDomainError.h"
#import "GlobalConstant.h"
#endif



#define MAINSTORYBOARD(indentifier) [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:indentifier]


// 下载的ip
#define POWERSERVERFILEPATH(fileid) [NSString stringWithFormat:@"%@/PowerPlat/Control/File.ashx?action=browser&_type=ftp&_fileid=%@",POWERM3URL,fileid]


#define POWERM3AUTOLOGINKEY [NSString stringWithFormat:@"%@_autoLogin",POWERM3URL]


// 字体
#define PingFangSCRegular(fontSize) [UIFont fontWithName:@"PingFang-SC-Regular" size:fontSize]

// 颜色
#define GFThemeColor UIColorFromRGB(0x05a499)


#define kNoNetwork @"no network"

#define GFUserDefault [NSUserDefaults standardUserDefaults]

#define GFNotification   [NSNotificationCenter defaultCenter]

#define POWERM3URL   [GFUserDefault stringForKey:PowerOnWebsiteUserDefaultKey]





#endif /* GFPrefix_h */
