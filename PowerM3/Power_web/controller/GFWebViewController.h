//
//  PowerM3Controller.h
//  PowerPMS
//
//  Created by ImperialSeal on 16/5/28.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFBaseViewController.h"
@import JavaScriptCore;

@class PowerProjectListModel,HandleJSCommand;

@interface GFWebViewController : GFBaseViewController
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) HandleJSCommand *handleJS;
@property (nonatomic,strong) JSContext *context;

@end
