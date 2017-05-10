//
//  GFDomainError.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/13.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    GFErrorLoginFail = -10008,
    GFErrorNONetwork
    
}ErrorDomainCode;
@interface GFDomainError : NSObject
+ (NSString *)localizedDescription:(NSError *)error;
+ (NSError *)errorCode:(ErrorDomainCode)code localizedDescript:(NSString *)descript;
@end
