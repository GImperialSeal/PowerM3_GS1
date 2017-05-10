//
//  GFRCloudHelper.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/14.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFRCloudHelper.h"
#import "NSString+Extension.h"
#import "GFContactModel.h"
#import "GFDrawViewController.h"
#import "AppDelegate.h"
#import "GFTabBarController.h"
#import "NSString+Extension.h"
#import "GFUserInfo+CoreDataProperties.h"
#import "GFRCUserInfo.h"
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

- (NSMutableArray *)friendsArray{
    if (_friendsArray) {
        return _friendsArray;
    }else{
        _friendsArray = [NSMutableArray arrayWithArray:[GFRCUserInfo findAll]];
        
        return _friendsArray;
    }
}

// 登录
- (void)loginRongCloudWithUserInfo:(RCUserInfo *)userInfo withToken:(NSString *)token{
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        [RCIM sharedRCIM].currentUserInfo = userInfo;
        [self refreshBadgeValue];
        BLog(@"userId:  %@",userId);
    } error:^(RCConnectErrorCode status) {
        BLog(@"登陆的错误码为:%ld", (long)status);
    } tokenIncorrect:^{
        BLog(@"token错误");
    }];
}


// 好友
- (void)syncFriendList:(void (^)(NSMutableArray * friends,BOOL isSuccess))completion{
    __weak  typeof(self)weakself = self;
    [GFNetworkHelper GET:ContactList parameters:@{@"name":@""} success:^(id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]){
            [weakself.friendsArray removeAllObjects];
            for (NSDictionary *dict in responseObject) {
                GFContactModel *model = [[GFContactModel alloc]initWithJsonDict:dict];
                GFRCUserInfo *info = [[GFRCUserInfo alloc]initWithUserId:model.userId name:model.name portrait:POWERSERVERFILEPATH(model.portraitUri) phone:model.phone email:model.email] ;
                [weakself.friendsArray addObject:info];
            }
            if(completion)completion(weakself.friendsArray,YES);
            
            [GFRCUserInfo cacheUserInfoWithUsers:weakself.friendsArray];
        }
    } failure:^(NSError *err) {
        if(completion)completion(nil,NO);
    }];
}

- (void)syncGroupList:(void (^)(NSMutableArray * groups,BOOL isSuccess))completion{
    _groupsArray = [NSMutableArray array];
    [GFNetworkHelper GET:SearchMyGroup parameters:@{@"groupname":@"",@"humanid":[GFCommonHelper currentWebSite].humanID} success:^(id responseObject) {
        BLog(@"responseObj: %@",responseObject);
        for (NSDictionary *dic in responseObject[@"list"]) {
            RCGroup *group = [[RCGroup alloc]initWithGroupId:dic[@"Code"] groupName:dic[@"Title"] portraitUri:@"http://img04.tooopen.com/images/20130712/tooopen_17270713.jpg"];
            [_groupsArray addObject:group];
        };
        if (completion) {
            completion(_groupsArray,[responseObject[@"success"] boolValue]);
        }
        
    } failure:^(NSError *error) {
        BLog(@"error: %@",error);
        if (completion) {
            completion(_groupsArray,NO);
        }
    }];
}

- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    
    for (NSInteger i = 0; i<self.friendsArray.count; i++) {
        RCUserInfo *aUser = self.friendsArray[i];
        if ([userId isEqualToString:aUser.userId]) {
            completion(aUser);
            break;
        }
    }
}

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion{
    BLog(@"groups: %@",self.groupsArray);
    for (NSInteger i = 0; i<self.groupsArray.count; i++) {
        RCGroup *aUser = self.groupsArray[i];
        if ([groupId isEqualToString:aUser.groupId]) {
            completion(aUser);
            break;
        }
    }
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


#pragma mark -
#pragma mark - 根据userId获取RCUserInfo
- (RCUserInfo *)currentUserInfoWithUserId:(NSString *)userId{
    
    
    for (RCUserInfo *aUser in _friendsArray) {
        
        NSLog(@"firend: %@",aUser.userId);
        NSLog(@"firend: %@",userId);

        if ([userId isEqualToString:aUser.userId]) {
            NSLog(@"current ＝ %@",aUser.name);
            return aUser;
        }
    }
    return nil;
}
#pragma mark -
#pragma mark - 根据userId获取RCGroup
- (RCGroup *)currentGroupInfoWithGroupId:(NSString *)groupId{
    for (RCGroup *aGroup in _groupsArray) {
        if ([groupId isEqualToString:aGroup.groupId]) {
            return aGroup;
        }
    }
    return nil;
}

- (NSString *)currentNameWithUserId:(NSString *)userId{
    for (RCUserInfo *aUser in _friendsArray) {
        if ([userId isEqualToString:aUser.userId]) {
            NSLog(@"current ＝ %@",aUser.name);
            return aUser.name;
        }
    }
    return nil;
}

- (BOOL)hasTheFriendWithUserId:(NSString *)userId{
    if (_friendsArray.count) {
        if ([_friendsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId = %@",userId]].count) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
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


@end
