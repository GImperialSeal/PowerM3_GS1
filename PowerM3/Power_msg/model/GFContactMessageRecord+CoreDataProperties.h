//
//  GFContactMessageRecord+CoreDataProperties.h
//  
//
//  Created by 顾玉玺 on 2017/3/7.
//
//

#import "GFContactMessageRecord+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GFContactMessageRecord (CoreDataProperties)

+ (NSFetchRequest<GFContactMessageRecord *> *)fetchRequest;

@property (nonatomic) int16_t chatMessageType;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) BOOL isSender;
@property (nullable, nonatomic, copy) NSString *fileID;
@property (nullable, nonatomic, copy) NSString *textChatContent;
@property (nullable, nonatomic, copy) NSString *imageSize;
@property (nullable, nonatomic, copy) NSString *voiceChatContent;
@property (nullable, nonatomic, retain) GFContactInformation *contactInfomation;

@end

NS_ASSUME_NONNULL_END
