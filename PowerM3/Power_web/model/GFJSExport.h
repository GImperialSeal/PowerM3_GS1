//
//  GFJSExport.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

@protocol GFJSPowerM3AppCallBack <JSExport>

@property (nonatomic, strong) JSValue *jsValue;

//self.context[@"AppCall"]=^(NSString *order,NSString *parameter,NSString *function,NSString *more){

- (void)AppCall:(NSString *)order parameter:(NSString *)parameter function:(NSString *)function more:(NSString *)more;

@end


@interface GFJSExport : NSObject<GFJSPowerM3AppCallBack>
@property (nonatomic, strong) JSManagedValue *managedValue;

@end
