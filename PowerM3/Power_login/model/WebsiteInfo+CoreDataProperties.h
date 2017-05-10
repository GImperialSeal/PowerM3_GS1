//
//  WebsiteInfo+CoreDataProperties.h
//  
//
//  Created by ImperialSeal on 16/12/26.
//
//

#import "WebsiteInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WebsiteInfo (CoreDataProperties)

+ (NSFetchRequest<WebsiteInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *admin;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *headImage;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *subtitle;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
