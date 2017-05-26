//
//  CheckedSessionIDModel.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/10.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFWebsiteCoreDataModel+CoreDataProperties.h"

typedef NS_ENUM(NSInteger, GFReplaceRootViewOptions) {
    ReplaceWithTabbarController           = 0 , //
    ReplaceWithLoginController            = 1 , //
} __TVOS_PROHIBITED;

@class LoginSuccessedDataSource;
@interface GFCommonHelper : NSObject

+ (void)login:(NSString *)username code:(NSString *)password completion:(void(^)(LoginSuccessedDataSource *obj))complete failure:(void(^)(NSError *error))fail;


// 验证sessionID
+ (void)validateCookieSessionidCompletion:(dispatch_block_t)completion;

// 
+ (void)setJPushAlias:(NSString *)alias;

+ (void)replaceRootViewControllerOptions:(GFReplaceRootViewOptions)options;


// rc4 加密
+ (NSString *)HloveyRC4:(NSString *)input key:(NSString *)key;

+ (GFWebsiteCoreDataModel *)currentWebSite;

+ (void)websiteSetValue:(id)value forKey:(NSString *)key;

+ (void)loadWebViewCookie:(NSString *)sessionID;

/**
 查看本地cookie

 @param del 是否删除所有的cookie
 @return 判断本地cookie 是否已经过期  返回 NO cookie未过期,本地cookie依然有效
 */
+ (BOOL)lookupWebViewCookieDeleteOrNot:(BOOL)del;

@end
