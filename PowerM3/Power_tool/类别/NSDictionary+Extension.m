//
//  NSDictionary+Extension.m
//  GFTOOLS
//
//  Created by 顾玉玺 on 2017/2/16.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)
- (NSString*)DictionaryConversionStringOfJson{
    if (!self) {
        return nil;
    }
    
    NSError *parseError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    
    if (parseError) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

@end
