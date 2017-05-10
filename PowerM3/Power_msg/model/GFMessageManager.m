//
//  GFMessageManager.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/15.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFMessageManager.h"
#import "GFContactInformation+CoreDataProperties.h"
#import "GFContactMessageRecord+CoreDataProperties.h"
#import "AFNetWorking.h"
#import "NSString+Extension.h"
@implementation GFMessageManager

+ (void)receivedMessageNotificationUserInfo:(NSDictionary *)userInfo{
    NSString *userID = userInfo[@"userID"];
    NSString *fileID = userInfo[@"fileID"];
    NSString *alert  = userInfo[@"aps"][@"alert"];
    NSInteger type   = [userInfo[@"type"] integerValue];
    
    GFContactInformation *contact = [[GFContactInformation MR_findByAttribute:@"userID" withValue:userID] firstObject];
    contact.latelyMessage = YES;
    GFContactMessageRecord *record = [GFContactMessageRecord MR_createEntity];
    if (type == GFChatCellType_Text) {
        record.textChatContent = alert;

    }else if(type == GFChatCellType_Image){
        record.fileID = POWERSERVERFILEPATH(fileID);
    }else if(type == GFChatCellType_Video){
        
    }else if(type == GFChatCellType_Audio){
        
    }else{
        
    }
    record.chatMessageType = type;
    record.date = [NSDate date];
    record.isSender = NO;
    record.contactInfomation = contact;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollToBottom" object:@(YES)];
}


+ (void)sendingAMessageToContact:(GFContactInformation *)toContact messageModel:(GFContactMessageRecord *)record completion:(dispatch_block_t)complete failure:(dispatch_block_t)fail{
    NSString *userID = toContact.userID;
    NSString *extraString = [self gf_JPushExtraParametersWithContact:userID MessageType:record.chatMessageType fileID:record.fileID];
    NSString *alisa = [userID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"alisa:      %@",alisa);
    [GFNetworkHelper GET:PowerURL_JGIOSAlias
              parameters:@{@"alias":alisa,@"content":record.textChatContent,@"extra":extraString}
                 success:^(id  _Nonnull responseObject) {
                     if ([responseObject[@"success"] boolValue]) {
                         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                         if (complete) complete();
                     }else{
                         if (fail)fail();
                     }
                 }
                 failure:^(NSError * _Nonnull err) {
                     if (fail)fail();
                 }];
}
// 推送
+ (void)sendingAMessageToContact:(GFContactInformation *)toContact messageModel:(GFContactMessageRecord *)record data:(NSData *)data completion:(dispatch_block_t)complete failure:(dispatch_block_t)fail{
    
    if (record.chatMessageType == GFChatCellType_Audio||record.chatMessageType == GFChatCellType_Image) {
        [self upload:data fileId:record.fileID success:^{
            [self sendingAMessageToContact:toContact messageModel:record completion:complete failure:fail];
        } failure:^{
            if(fail)fail();
        }];
    }else{
        [self sendingAMessageToContact:toContact messageModel:record completion:complete failure:fail];
    }
}

#pragma mark -  发送消息部分


+ (NSString *)gf_JPushExtraParametersWithContact:(NSString *)contactID MessageType:(GFChatCellType)messageType fileID:(NSString *)uuid{
    if (!uuid) uuid = @"";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"fileID":uuid,@"type":@(messageType),@"userID":contactID} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

// 发送  tupian消息
+ (void)upload:(NSData *)data fileId:(NSString *)fileId success:(dispatch_block_t)complete failure:(dispatch_block_t)failure{
    
    //PS_IncomeContract
    //"631c48e9-5ac6-41cc-8c2c-5404a79fa600"
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *keyValue = [GFCommonHelper currentWebSite].humanID;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",str];
    NSDictionary *dic = @{@"KeyWord":@"Human",
                          @"KeyValue":keyValue,
                          @"_filename":fileName,
                          @"_fileid":fileId,
                          @"_start":@(0),
                          @"_end":@(data.length),
                          @"_total":@(data.length),
                          @"action":@"upload"};
    [manager POST:PowerURL_Upload parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"FileData" fileName:fileName mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            if ([dic[@"success"]boolValue]) {
                if(complete)complete();
            }else{
                if (failure) {
                    failure();
                }
            }
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];
}




@end
