//
//  GFRCUserInfo.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/5/4.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface GFRCUserInfo : RCUserInfo


@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *email;

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait phone:(NSString *)phone email:(NSString *)email;


+ (void)cacheUserInfoWithUsers:(NSArray *)users;
+ (NSArray *)findAll;
+ (GFRCUserInfo *)findUserById:(NSString *)userId;


@end
