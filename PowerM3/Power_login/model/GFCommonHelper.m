//
//  CheckedSessionIDModel.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/10.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFCommonHelper.h"
#import "JPUSHService.h"
#import "LoginDataSource.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "NSString+Extension.h"
#import "AppDelegate.h"

#import "GFTabBarController.h"
#import "GFMenuViewController.h"



@import JavaScriptCore;


@implementation GFCommonHelper

+ (GFWebsiteCoreDataModel *)currentWebSite{
    GFWebsiteCoreDataModel *model = [GFWebsiteCoreDataModel MR_findFirstByAttribute:@"url" withValue:POWERM3URL];
    if (!model) {
        model = [GFWebsiteCoreDataModel MR_createEntity];
        model.url = POWERM3URL;
    }
    return model;
}

+ (void)websiteSetValue:(id)value forKey:(NSString *)key{
    GFWebsiteCoreDataModel *model = [GFWebsiteCoreDataModel MR_findFirstByAttribute:@"url" withValue:POWERM3URL];
    [model setValue:value forKey:key];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (void)replaceRootViewControllerOptions:(GFReplaceRootViewOptions)options{
    switch (options) {
        case ReplaceWithTabbarController:{
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.drawViewController = [[GFDrawViewController alloc]initWithRootViewController:[[GFTabBarController alloc]init]];
            app.drawViewController.menuViewController = [[UINavigationController alloc]initWithRootViewController:[[GFMenuViewController alloc]init]];
            [UIApplication sharedApplication].delegate.window.rootViewController = app.drawViewController;

            break;
        }
        case ReplaceWithLoginController:{
            [UIApplication sharedApplication].delegate.window.rootViewController = MAINSTORYBOARD(@"GFLoginNavigationController");
            break;
        }

        default:
            break;
    }
    

}



+ (void)login:(NSString *)username code:(NSString *)password completion:(void(^)(LoginSuccessedDataSource *obj))complete failure:(void(^)(NSError *error))fail{
    
    NSDictionary  *parametersDic = @{@"userName":[self  HloveyRC4:username key:@"PowerM3"],
                                     @"password":[self  HloveyRC4:password key:@"PowerM3"]};
    [GFNetworkHelper POST:NormalLogin parameters:parametersDic success:^(id jsonDic) {
        BLog(@"login   in        : %@",jsonDic);
        if ([jsonDic[@"success"] boolValue]) {
            LoginSuccessedDataSource *model = [[LoginSuccessedDataSource alloc]initWithJsonDict:jsonDic[@"data"]];
            
            [self setJPushAlias:model.humanid];
            [self addWebsiteWithModel:model user:username code:password];
            if(complete)complete(model);
        }else{
            if (fail) {
                fail([GFDomainError errorCode:GFErrorLoginFail localizedDescript:jsonDic[@"message"]]);
            }
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail([GFDomainError errorCode:GFErrorNONetwork localizedDescript:@"网络连接失败 "]);
        }
    }];
}

#pragma mark - 验证session 是否有效
+ (void)validateCookieSessionidCompletion:(dispatch_block_t)completion{
    
    GFWebsiteCoreDataModel *model = [self currentWebSite];
    NSString *sessionID  = model.sessionID;
    NSString *userName   = model.admin;
    NSString *passWord   = model.password;
    NSString *epsprojid  = model.epsprojectID;
    
    
    assert(sessionID.length);
    assert(epsprojid.length);
    
    
    NSDictionary *dic = @{@"sessionid":sessionID,
                          @"usercode":[self  HloveyRC4:userName key:@"PowerM3"],
                          @"password":[self  HloveyRC4:passWord key:@"PowerM3"],
                          @"epsprojid":epsprojid};
    
    [GFNetworkHelper POST:CheckSession
               parameters:dic
                  success:^(id responseObject) {
                      
                      
                      if([responseObject[@"success"] boolValue]){
                          if (completion) {
                              completion();
                          }
                      }
                  }failure:^(NSError *err) {
                      BLog(@"验证  sessionID    error:   %@",err.description);
                  }];
}


+ (void)setJPushAlias:(NSString *)alias{
    // 设置激光别名
    if ([GFUserDefault boolForKey:alias]) {
        return;
    }
    [JPUSHService setTags:nil alias:[alias stringByReplacingOccurrencesOfString:@"-" withString:@""] fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        BLog(@"ia: %@",iAlias);
        BLog(@"iRescode: %d",iResCode);
        if (iResCode!=0) {
            [GFAlertView showAlertWithTitle:@"提示" message:@"推送消息未设置成功" completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
                [self setJPushAlias:alias];
            } cancelButtonTitle:@"重试" otherButtonTitles:nil];
        }else{
            [GFUserDefault setBool:YES forKey:alias];
        }
    }];
}
#pragma mark - 设置cookie
+ (void)loadWebViewCookie:(NSString *)sessionID{
    NSURL * cookieHost = [NSURL URLWithString:POWERM3URL];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
            NSHTTPCookieDomain:[cookieHost host],
            NSHTTPCookiePath:[cookieHost path],
            NSHTTPCookieName:@"PowerWebCertificate",
            NSHTTPCookieValue:sessionID,
            }];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}


+ (BOOL)lookupWebViewCookieDeleteOrNot:(BOOL)del{
    

    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        

        if ([cookie.name isEqualToString:@"PowerWebCertificate"]) {
            NSComparisonResult result = [[NSDate date] compare:cookie.expiresDate];

            
            
            if (result == NSOrderedAscending) {
                
                
                
                return YES;
            }
            
        }
        if (del) {
            [storage deleteCookie:cookie];
        }
        
    }
    return NO;
}


+ (NSString *)HloveyRC4:(NSString *)input key:(NSString *)key{
    JSContext *context = [[JSContext alloc]init];
    context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        BLog(@"%@", exception);
    };
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Rc4" ofType:@"js"];
    NSString *javaScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [context evaluateScript:javaScript];
    JSValue *rc4 = context[@"base64swhere"];
    JSValue *result = [rc4 callWithArguments:@[input]];
    
    return [result toString];
}

// core data 保存用户信息
+ (void)addWebsiteWithModel:(LoginSuccessedDataSource *)model user:(NSString *)admin code:(NSString *)password{
    GFWebsiteCoreDataModel *info = [GFCommonHelper currentWebSite];
    info.headImage = POWERSERVERFILEPATH(model.app_smallheadid);
    info.phone = model.app_mobile;
    info.email = model.app_email;
    info.date = [NSDate date];
    info.admin = admin;
    info.url = POWERM3URL;
    info.password = password;
    info.sessionID = model.sessionid;
    info.humanID = model.humanid;
    info.name = model.name;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}





@end
