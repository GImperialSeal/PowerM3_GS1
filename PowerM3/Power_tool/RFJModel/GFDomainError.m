//
//  GFDomainError.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/13.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFDomainError.h"
#define GFErrorDomain @"com.p3china.dev"

@implementation GFDomainError


+ (NSError *)errorCode:(ErrorDomainCode)code localizedDescript:(NSString *)descript{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:descript forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:GFErrorDomain code:GFErrorLoginFail userInfo:dic];
}

+ (NSString *)localizedDescription:(NSError *)error{
    return error.userInfo[NSLocalizedDescriptionKey];
}
@end
