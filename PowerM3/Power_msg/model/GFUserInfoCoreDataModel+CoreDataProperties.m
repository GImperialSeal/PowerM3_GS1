//
//  GFUserInfoCoreDataModel+CoreDataProperties.m
//  
//
//  Created by 顾玉玺 on 2017/5/23.
//
//

#import "GFUserInfoCoreDataModel+CoreDataProperties.h"
#import "GFContactModel.h"
@implementation GFUserInfoCoreDataModel (CoreDataProperties)

+ (NSFetchRequest<GFUserInfoCoreDataModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GFUserInfoCoreDataModel"];
}

@dynamic date;
@dynamic email;
@dynamic name;
@dynamic phone;
@dynamic portraitUri;
@dynamic userId;
@dynamic website;




+ (void)insertEntityWithDataSource:(GFContactModel *)info{
    GFUserInfoCoreDataModel *model = [GFUserInfoCoreDataModel MR_createEntity];
    
    model.date = [NSDate date];
    model.email = info.email;
    model.name = info.name.length?info.name:@"无名";
    model.phone = info.phone;
    model.portraitUri = POWERSERVERFILEPATH(info.portraitUri);
    model.userId = info.userId;
    model.website = [GFCommonHelper currentWebSite];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (void)deleteAllEntity{
    [GFUserInfoCoreDataModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"website = %@",[GFCommonHelper currentWebSite]]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (NSArray<GFUserInfoCoreDataModel *> *)findAll{
    
    
    NSArray *array = [GFUserInfoCoreDataModel MR_findByAttribute:@"website" withValue:[GFCommonHelper currentWebSite]];
    
    
    
    return array;
}

+ (GFUserInfoCoreDataModel *)findUserByUserId:(NSString *)userId{
    GFUserInfoCoreDataModel *model = [GFUserInfoCoreDataModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"website = %@ && userId = %@",[GFCommonHelper currentWebSite],userId]];
    return model;
}
@end
