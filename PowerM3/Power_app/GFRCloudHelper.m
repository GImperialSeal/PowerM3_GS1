//
//  GFRCloudHelper.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/14.
//  Copyright © 2017年 qymgc. All rights reserved.
//

/**
 *  ********************************* 测试环境 ************************************
 */
#if DEBUG
#define RCIM_APPKEY     @"pkfcgjstprms8"
/**
 *  ********************************* 正式环境 ************************************
 */
#else
#define RCIM_APPKEY     @"c9kqb3rdce7rj"
#endif


#import "GFRCloudHelper.h"
#import "NSString+Extension.h"
#import "GFContactModel.h"
#import "GFDrawViewController.h"
#import "AppDelegate.h"
#import "GFTabBarController.h"
#import "NSString+Extension.h"
#import "GFUserInfoCoreDataModel+CoreDataProperties.h"
#import <RongCallKit/RongCallKit.h>
@interface GFRCloudHelper ()
@end
@implementation GFRCloudHelper



+ (instancetype)shareInstace{
    static GFRCloudHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc]init];
    });
    return helper;
}

/**
 1. 初始化融云 设置代理  在接口处调用
 2. appkey 在.m文件设置
 */
- (void)initRCIMWithOptions:(NSDictionary *)launchOptions{
    assert(RCIM_APPKEY.length);
    [[RCIM sharedRCIM] initWithAppKey:RCIM_APPKEY];
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    [[RCIM sharedRCIM] setEnablePersistentUserInfoCache:YES];// 好友缓存
    [[RCIM sharedRCIM] setEnableSyncReadStatus:YES];
    [[RCIM sharedRCIM] setEnableMessageMentioned:YES];//@功能
    [[RCIM sharedRCIM] setEnableMessageRecall:YES];// 消息撤回
    [[RCIM sharedRCIM] setEnableTypingStatus:YES];  //开启输入状态监听
    [[RCIM sharedRCIM] setEnableSyncReadStatus:YES];   //开启多端未读状态同步
    //开启发送已读回执
    [[RCIM sharedRCIM] setEnabledReadReceiptConversationTypeList:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION)]];
    
    //   设置优先使用WebView打开URL
    [RCIM sharedRCIM].embeddedWebViewPreferred = YES;
    
    //  设置通话视频分辨率
    [[RCCallClient sharedRCCallClient] setVideoProfile:RC_VIDEO_PROFILE_480P];

    
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
//    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Info];
//    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
//        [self redirectNSlogToDocumentFolder];
//    }
}



// 登录
- (void)loginRongCloudWithUserInfo:(RCUserInfo *)userInfo withToken:(NSString *)token{
    __weak typeof (self)weakself = self;
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        [RCIM sharedRCIM].currentUserInfo = userInfo;
        
        
        [weakself refreshBadgeValue];
        
//        [weakself syncFriendList:^(NSArray *friends, BOOL isSuccess) {
//            
//        }];
        BLog(@"userId:  %@",userId);
    } error:^(RCConnectErrorCode status) {
        BLog(@"登陆的错误码为:%ld", (long)status);
    } tokenIncorrect:^{
        BLog(@"token错误");
    }];
}

// 好友
- (void)syncFriendList:(void (^)(NSArray * friends,BOOL isSuccess))completion{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:100];
    [GFNetworkHelper GET:ContactList parameters:@{@"name":@""} success:^(id responseObject) {
        // 请求成功
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]){
            // 清除缓存
            [GFUserInfoCoreDataModel deleteAllEntity];
            for (NSDictionary *dict in responseObject) {
                GFContactModel *model = [[GFContactModel alloc]initWithJsonDict:dict];
                
                RCUserInfo *info = [[RCUserInfo alloc]initWithUserId:model.userId name:model.name portrait:POWERSERVERFILEPATH(model.portraitUri)];
                
                [tempArray addObject:info];
                
                // 保存到数据库
                [GFUserInfoCoreDataModel insertEntityWithDataSource:model];
            }
            if(completion)completion(tempArray,YES);
        }else{
            if(completion)completion([GFUserInfoCoreDataModel findAll],NO);
        }
    } failure:^(NSError *err) {
        if(completion)completion([GFUserInfoCoreDataModel findAll],NO);
    }];
}


#pragma mark - RCIMUserInfoDataSource  delegate
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    GFUserInfoCoreDataModel *model = [GFUserInfoCoreDataModel findUserByUserId:userId];
    RCUserInfo *info = [RCUserInfo new];
    info.userId = userId;
    info.portraitUri = model.portraitUri;
    info.name = model.name;
    completion(info);
}




-(void)refreshBadgeValue{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger unreadMsgCount = (NSInteger)[[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION),@(ConversationType_GROUP),@(ConversationType_CHATROOM)]];
        AppDelegate *app =  (AppDelegate *)[UIApplication sharedApplication].delegate;
        GFTabBarController *tabbar = (GFTabBarController *)app.drawViewController.rootViewController;
        UINavigationController *chatNav = tabbar.viewControllers[tabbar.viewControllers.count-2];
        if (unreadMsgCount == 0) {
            chatNav.tabBarItem.badgeValue = nil;
        }else{
            chatNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%li",(long)unreadMsgCount];
        }
    });
}



- (void)onRCIMReceiveMessage:(RCMessage *)message
                        left:(int)left{
    if (left == 0 ) {
        [self refreshBadgeValue];
    }
    
}


#pragma mark - 获取按A~Z顺序排列的所有联系人
+ (void)sortCHWithArray:(NSArray<id> *)arr sortedByKey:(NSString *)key completion:(void(^)(NSMutableDictionary *dict,NSArray *keys))complete{
    
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("addressBook.infoDict", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        
        NSMutableDictionary *addressBookDict = [NSMutableDictionary dictionary];
        
        for (id model in arr) {
            //获取到姓名的大写首字母
            NSString *name = [model valueForKey:key];
            NSString *firstLetterString = [name getFirstLetter];
            //如果该字母对应的联系人模型不为空,则将此联系人模型添加到此数组中
            if (addressBookDict[firstLetterString]){
                [addressBookDict[firstLetterString] addObject:model];
            }else{
                //创建新发可变数组存储该首字母对应的联系人模型
                NSMutableArray *arrGroupNames = [NSMutableArray arrayWithObject:model];
                //将首字母-姓名数组作为key-value加入到字典中
                [addressBookDict setObject:arrGroupNames forKey:firstLetterString];
            }
        }
        
        // 将addressBookDict字典中的所有Key值进行排序: A~Z
        NSArray *nameKeys = [[addressBookDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        // 将 "#" 排列在 A~Z 的后面
        if ([nameKeys.firstObject isEqualToString:@"#"])
        {
            NSMutableArray *mutableNamekeys = [NSMutableArray arrayWithArray:nameKeys];
            [mutableNamekeys insertObject:nameKeys.firstObject atIndex:nameKeys.count];
            [mutableNamekeys removeObjectAtIndex:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                complete ? complete(addressBookDict,mutableNamekeys) : nil;
            });
            return;
        }
        
        // 将排序好的通讯录数据回调到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            complete ? complete(addressBookDict,nameKeys) : nil;
        });
        
    });
    
}


- (void)redirectNSlogToDocumentFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];
    
    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
    NSString *logFilePath =
    [documentDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
            stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
            stderr);
}


@end
