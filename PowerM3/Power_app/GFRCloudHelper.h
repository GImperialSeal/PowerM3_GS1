//
//  GFRCloudHelper.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/14.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

#import "GFRCUserInfo.h"
@class GFContactModel;
@interface GFRCloudHelper : NSObject <RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMReceiveMessageDelegate>


+ (instancetype)shareInstace;


@property (nonatomic, strong) NSMutableArray *groupsArray;
@property (nonatomic, strong) NSMutableArray *friendsArray;
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
- (void)syncFriendList:(void (^)(NSMutableArray * friends,BOOL isSuccess))completion;

/**
 *  从服务器同步群组列表
 */
- (void)syncGroupList:(void (^)(NSMutableArray * groups,BOOL isSuccess))completion;

/**
 *  刷新tabbar的角标
 */
- (void)refreshBadgeValue;

- (RCUserInfo *)currentUserInfoWithUserId:(NSString *)userId;


/**
 A~Z排序
 */
+ (void)sortCHWithArray:(NSArray<id> *)arr sortedByKey:(NSString *)key completion:(void(^)(NSMutableDictionary *dict,NSArray *keys))complete;

@end
