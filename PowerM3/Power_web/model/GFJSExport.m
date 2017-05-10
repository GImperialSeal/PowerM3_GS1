//
//  GFJSExport.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFJSExport.h"

@implementation GFJSExport
@synthesize jsValue = _jsValue;
//重写setter方法
- (void)setJsValue:(JSValue *)jsValue
{
    _managedValue = [JSManagedValue managedValueWithValue:jsValue];
    
    [[[JSContext currentContext] virtualMachine] addManagedReference:_managedValue
                                                           withOwner:self];
}

- (void)AppCall:(NSString *)order parameter:(NSString *)parameter function:(NSString *)function more:(NSString *)more{
    BLog(@"app------call ------调用啦");
}


@end
