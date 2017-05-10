//
//  GFMessageManager.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/15.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GFContactInformation;
@class GFContactMessageRecord;
@interface GFMessageManager : NSObject

+ (void)receivedMessageNotificationUserInfo:(NSDictionary *)userInfo;
+ (void)sendingAMessageToContact:(GFContactInformation *)toContact messageModel:(GFContactMessageRecord *)record data:(NSData *)data completion:(dispatch_block_t)complete failure:(dispatch_block_t)fail;

@end
