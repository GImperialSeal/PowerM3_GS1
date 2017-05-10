//
//  GFContactMessageRecord+CoreDataProperties.m
//  
//
//  Created by 顾玉玺 on 2017/3/7.
//
//

#import "GFContactMessageRecord+CoreDataProperties.h"

@implementation GFContactMessageRecord (CoreDataProperties)

+ (NSFetchRequest<GFContactMessageRecord *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GFContactMessageRecord"];
}

@dynamic chatMessageType;
@dynamic date;
@dynamic isSender;
@dynamic fileID;
@dynamic textChatContent;
@dynamic imageSize;
@dynamic voiceChatContent;
@dynamic contactInfomation;

@end
