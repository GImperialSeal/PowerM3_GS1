//
//  GFSearchResultModel.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/6.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFJModel.h"


@interface GFContactModel : RFJModel

JProperty(NSString *userId, ID);

JProperty(NSString *name, NAME);

JProperty(NSString *phone, ACCOUNT);

JProperty(NSString *portraitUri, HEADSMALL);

JProperty(NSString *email, EMAIL);

@end
