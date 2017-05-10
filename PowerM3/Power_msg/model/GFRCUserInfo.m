//
//  GFRCUserInfo.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/5/4.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFRCUserInfo.h"
#define FileName [NSString stringWithFormat:@"%@-CONTACTS-FILENAME",POWERM3URL]
@implementation GFRCUserInfo

//@synthesize  email;
//
//@synthesize phone;

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait phone:(NSString *)phone email:(NSString *)email{
    if (self = [super initWithUserId:userId name:username portrait:portrait]) {
        
        self.email = email;
        self.phone = phone;
    }
    return self;
}

+ (void)cacheUserInfoWithUsers:(NSArray *)users{
    [GFDomainManager saveObject:users byFileName:FileName];
}


+ (NSArray *)findAll{
    return [GFDomainManager getObjectByFileName:FileName];
}

+ (GFRCUserInfo *)findUserById:(NSString *)userId{
    NSArray *arr = [self findAll];
    
    return [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId = %@",userId]].firstObject;
}

+ (BOOL)existUser{
    NSArray *array = [GFDomainManager getObjectByFileName:FileName];
    return array.count;
}


@end
