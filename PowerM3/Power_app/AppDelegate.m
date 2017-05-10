//
//  AppDelegate.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/3.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "AppDelegate.h"
#import "GFTabBarController.h"
#import "GFDrawViewController.h"
#import "GFMenuViewController.h"
#import "GFWebViewController.h"
#import "JPUSHService.h"
#import <RongIMKit/RongIMKit.h>
#import <AdSupport/AdSupport.h>
#import "GFCommonHelper.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "GFRCloudHelper.h"
typedef NS_ENUM(NSInteger, ReceivedNoticationMode) {
    ReceivedNotication_killed,
    ReceivedNotication_background,
    ReceivedNotication_foreground
};

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"CoreData.splite"];
    //[self registerJPushWithOptions:launchOptions];
    [[RCIM sharedRCIM] initWithAppKey:@"pkfcgjstprms8"];
    [[RCIM sharedRCIM] setUserInfoDataSource:[GFRCloudHelper shareInstace]];
    [[RCIM sharedRCIM] setGroupInfoDataSource:[GFRCloudHelper shareInstace]];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:[GFRCloudHelper shareInstace]];
    [[RCIM sharedRCIM] setEnablePersistentUserInfoCache:YES];
    [[RCIM sharedRCIM] setEnableSyncReadStatus:YES];
    [[RCIM sharedRCIM] setEnableMessageMentioned:YES];//@
    [[RCIM sharedRCIM] setEnableMessageRecall:YES];// 撤回
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];

     [self autoLogin];

    // 收到通知跳转到指定界面
    [self ReceivedNotified:ReceivedNotication_killed dictionary:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    
    return YES;
    
}


- (void)showAlert{
    [GFAlertView showAlertWithTitle:@"提示" message:@"网络请求失败..." completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
        if (buttonIndex == 0) {
            [GFNotification postNotificationName:@"LoginOrNot" object:@(NO)];
        }else{
            
        }
    } cancelButtonTitle:@"重新登录" otherButtonTitles:@"重试",nil];
}



#pragma mark -  自动登录
- (void)autoLogin{
    
    if ([GFUserDefault boolForKey:POWERM3AUTOLOGINKEY]) {
         self.window.rootViewController = [self drawViewController:[[GFTabBarController alloc]init] showMenuViewController:[[UINavigationController alloc]initWithRootViewController:[[GFMenuViewController alloc]init]]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessLogin:) name:@"LoginOrNot" object:nil];
}
- (void)didSuccessLogin:(NSNotification *)noti{
    BOOL login = [noti.object boolValue];
    if (login) {
        self.window.rootViewController = [self drawViewController:[[GFTabBarController alloc]init] showMenuViewController:[[UINavigationController alloc]initWithRootViewController:[[GFMenuViewController alloc]init]]];
    }else{
        BLog(@"登-录-login vc");

        self.window.rootViewController = MAINSTORYBOARD(@"GFLoginNavigationController");
    }
}
- (GFDrawViewController *)drawViewController:(UIViewController *)rootViewController showMenuViewController:(UIViewController *)menuViewController{
    BLog(@"load draw vc");

    self.drawViewController = [[GFDrawViewController alloc]initWithRootViewController:rootViewController];
    self.drawViewController.menuViewController = menuViewController;
    return self.drawViewController;
}

- (void)ReceivedNotified:(ReceivedNoticationMode)mode dictionary:(NSDictionary *)dic{
    BLog(@"received noti");

    NSInteger type = [dic[@"type"] integerValue];
    if (type == 5)[self presentPushMessageControllerWithDictionary:dic];

    switch (mode) {
        case ReceivedNotication_killed:
            break;
        case ReceivedNotication_background:
            break;
        case ReceivedNotication_foreground:
            break;
        default:
            break;
    }
 
   
}
#pragma mark - register  JPush
static NSString *appKey = @"28f4de198ee36e01155adc1c";
static NSString *channel = @"Publish channel";
static BOOL isProduction = YES;

- (void)registerJPushWithOptions:(NSDictionary *)launchOptions {
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // 3.0.0以前版本旧的注册方式
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            BLog(@"registrationID获取成功：%@",registrationID);
        }
        else{
            BLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    BLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    BLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
    
    BLog(@"handle  push   action: %@   ",userInfo);
    
}
#endif

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    BLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
    
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    BLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    [self ReceivedNotified:ReceivedNotication_background dictionary:userInfo];
    
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];

    completionHandler(UIBackgroundFetchResultNewData);
}


#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        BLog(@"willPresentNotification iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        [self ReceivedNotified:ReceivedNotication_foreground dictionary:userInfo];
    }
    else {
        // 判断为本地通知
        BLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    //completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self ReceivedNotified:ReceivedNotication_background dictionary:userInfo];

        BLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        
    }
    else {
        // 判断为本地通知
        BLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    
   }


- (void)applicationDidEnterBackground:(UIApplication *)application {
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                 @(ConversationType_PRIVATE),
                 @(ConversationType_DISCUSSION),
                 @(ConversationType_APPSERVICE),
                 @(ConversationType_PUBLICSERVICE),
                 @(ConversationType_GROUP)]];
    application.applicationIconBadgeNumber = unreadMsgCount;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
     [application cancelAllLocalNotifications];
    // 程序只在tabbar页面进入前台是,验证 sessionID.
    BLog(@" app  进人前台");
    if([self.window.rootViewController isKindOfClass:[GFDrawViewController class]]){
        BLog(@"验证  sesssionid");
        [GFCommonHelper validateCookieSessionidCompletion:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

#pragma mark - 推送消息类型 type = 5 处理
- (void)presentPushMessageControllerWithDictionary:(NSDictionary *)dic{
    UIViewController *vc = self.window.rootViewController;
    GFWebViewController *webView = [[GFWebViewController alloc]init];
    [webView setValue:[NSString stringWithFormat:@"%@/%@",POWERM3URL,dic[@"url"]] forKey:@"url"];
    webView.title = dic[@"aps"][@"alert"];
    
    [webView setValue:@([dic[@"pulldown"] boolValue]) forKeyPath:@"webView.scrollView.mj_footer.hidden"];
    [webView setValue:@([dic[@"pullup"] boolValue]) forKeyPath:@"webView.scrollView.mj_header.hidden"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:webView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectZero];
    [button setTitleColor:GFThemeColor forState:UIControlStateNormal];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissPushMessageController) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    webView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    webView.navigationController.navigationBar.tintColor= GFThemeColor;
    [vc presentViewController:nav animated:YES completion:nil];
}

- (void)dismissPushMessageController{
    UIViewController *vc = self.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
