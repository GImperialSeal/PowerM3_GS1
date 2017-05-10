//
//  WKDelegateController.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/8.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@protocol WKDelegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
@end


@interface WKDelegateController : UIViewController<WKScriptMessageHandler>

@property (weak , nonatomic) id delegate;

@end
