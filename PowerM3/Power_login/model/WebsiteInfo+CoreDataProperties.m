//
//  WebsiteInfo+CoreDataProperties.m
//  
//
//  Created by ImperialSeal on 16/12/26.
//
//

#import "WebsiteInfo+CoreDataProperties.h"

@implementation WebsiteInfo (CoreDataProperties)

+ (NSFetchRequest<WebsiteInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WebsiteInfo"];
}

@dynamic admin;
@dynamic date;
@dynamic email;
@dynamic headImage;
@dynamic phone;
@dynamic subtitle;
@dynamic title;
@dynamic url;

@end
