//
//  GFContactInformation+CoreDataProperties.m
//  
//
//  Created by 顾玉玺 on 2017/2/28.
//
//

#import "GFContactInformation+CoreDataProperties.h"

@implementation GFContactInformation (CoreDataProperties)

+ (NSFetchRequest<GFContactInformation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GFContactInformation"];
}

@dynamic date;
@dynamic latelyMessage;
@dynamic userAccount;
@dynamic userHeadImage;
@dynamic userID;
@dynamic userName;
@dynamic contactMessageRecord;
@dynamic website;

@end
