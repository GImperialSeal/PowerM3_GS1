//
//  GFUserInfoCoreDataModel+CoreDataProperties.h
//  
//
//  Created by 顾玉玺 on 2017/5/23.
//
//

#import "GFUserInfoCoreDataModel+CoreDataClass.h"

@class GFContactModel;

NS_ASSUME_NONNULL_BEGIN

@interface GFUserInfoCoreDataModel (CoreDataProperties)

+ (NSFetchRequest<GFUserInfoCoreDataModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *portraitUri;
@property (nullable, nonatomic, copy) NSString *userId;
@property (nullable, nonatomic, retain) GFWebsiteCoreDataModel *website;


+ (void)insertEntityWithDataSource:(GFContactModel *)info;

+ (void)deleteAllEntity;

+ (NSArray<GFUserInfoCoreDataModel *> *)findAll;

+ (GFUserInfoCoreDataModel *)findUserByUserId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
