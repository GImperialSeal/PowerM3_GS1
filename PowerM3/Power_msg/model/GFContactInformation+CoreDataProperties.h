//
//  GFContactInformation+CoreDataProperties.h
//  
//
//  Created by 顾玉玺 on 2017/2/28.
//
//

#import "GFContactInformation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GFContactInformation (CoreDataProperties)

+ (NSFetchRequest<GFContactInformation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) BOOL latelyMessage;
@property (nullable, nonatomic, copy) NSString *userAccount;
@property (nullable, nonatomic, copy) NSString *userHeadImage;
@property (nullable, nonatomic, copy) NSString *userID;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, retain) NSSet<GFContactMessageRecord *> *contactMessageRecord;
@property (nullable, nonatomic, retain) GFWebsiteInfo *website;

@end

@interface GFContactInformation (CoreDataGeneratedAccessors)

- (void)addContactMessageRecordObject:(GFContactMessageRecord *)value;
- (void)removeContactMessageRecordObject:(GFContactMessageRecord *)value;
- (void)addContactMessageRecord:(NSSet<GFContactMessageRecord *> *)values;
- (void)removeContactMessageRecord:(NSSet<GFContactMessageRecord *> *)values;

@end

NS_ASSUME_NONNULL_END
