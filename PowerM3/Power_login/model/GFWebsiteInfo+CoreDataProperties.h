//
//  GFWebsiteInfo+CoreDataProperties.h
//  
//
//  Created by 顾玉玺 on 2017/3/15.
//
//

#import "GFWebsiteInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GFWebsiteInfo (CoreDataProperties)

+ (NSFetchRequest<GFWebsiteInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *admin;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *epsprojectID;
@property (nullable, nonatomic, copy) NSString *headImage;
@property (nullable, nonatomic, copy) NSString *humanID;
@property (nullable, nonatomic, copy) NSString *loginImage;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *sessionID;
@property (nullable, nonatomic, copy) NSString *subtitle;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<GFContactInformation *> *contactList;

@end

@interface GFWebsiteInfo (CoreDataGeneratedAccessors)

- (void)addContactListObject:(GFContactInformation *)value;
- (void)removeContactListObject:(GFContactInformation *)value;
- (void)addContactList:(NSSet<GFContactInformation *> *)values;
- (void)removeContactList:(NSSet<GFContactInformation *> *)values;

@end

NS_ASSUME_NONNULL_END
