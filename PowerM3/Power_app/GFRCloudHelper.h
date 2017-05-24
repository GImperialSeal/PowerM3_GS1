//
//  GFRCloudHelper.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/14.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@class GFContactModel;
@interface GFRCloudHelper : NSObject <RCIMUserInfoDataSource,RCIMReceiveMessageDelegate>


+ (instancetype)shareInstace;



/**
 1. 初始化融云 设置代理  在接口处调用
 2. appkey 在.m文件设置
 */
- (void)initRCIMWithOptions:(NSDictionary *)launchOptions;

/**
 *  登录融云服务器（connect，用token去连接）
 *
 *  @param userInfo 用户信息
 *  @param token    token令牌
 */
- (void)loginRongCloudWithUserInfo:(RCUserInfo *)userInfo withToken:(NSString *)token;

/**
 *  从服务器同步好友列表
 */
- (void)syncFriendList:(void (^)(NSArray * friends,BOOL isSuccess))completion;


/**
 *  刷新tabbar的角标
 */
- (void)refreshBadgeValue;


/**
 A~Z排序
 */
+ (void)sortCHWithArray:(NSArray<id> *)arr sortedByKey:(NSString *)key completion:(void(^)(NSMutableDictionary *dict,NSArray *keys))complete;

@end
