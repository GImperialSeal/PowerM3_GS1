//
//  GFWebsiteInfo+CoreDataProperties.m
//  
//
//  Created by 顾玉玺 on 2017/3/15.
//
//

#import "GFWebsiteInfo+CoreDataProperties.h"

@implementation GFWebsiteInfo (CoreDataProperties)

+ (NSFetchRequest<GFWebsiteInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GFWebsiteInfo"];
}

@dynamic admin;
@dynamic date;
@dynamic email;
@dynamic epsprojectID;
@dynamic headImage;
@dynamic humanID;
@dynamic loginImage;
@dynamic password;
@dynamic phone;
@dynamic sessionID;
@dynamic subtitle;
@dynamic title;
@dynamic url;
@dynamic name;
@dynamic contactList;

@end
