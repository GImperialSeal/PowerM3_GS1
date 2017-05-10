//
//  HandleJSCommand.h
//  PowerPMS
//
//  Created by ImperialSeal on 16/8/25.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;
#import "RFJModel.h"
@class UploadParameterModel;

@interface HandleJSCommand : RFJModel

@property (nonatomic, strong) UIWebView *webview;

@property (nonatomic, strong) JSContext *context;

@property (nonatomic, strong) NSString  *order;

@property (nonatomic, strong) NSString  *more;

@property (nonatomic, strong) UIViewController *currentController;

@property (nonatomic, strong) NSDictionary *pamattersDic;

JProperty(NSDictionary *uploadServer, uploadServer);
JProperty(BOOL translateBase64, translateBase64);
JProperty(BOOL filePath, filePath);

@property (nonatomic,strong) NSString *function;


@end


@interface UploadParameterModel : RFJModel
JProperty(NSString *keyword, keyword);
JProperty(NSString *keyvalue, keyvalue);
JProperty(CGFloat width, width);
JProperty(CGFloat height, height);
JProperty(BOOL upload, upload);

@end
