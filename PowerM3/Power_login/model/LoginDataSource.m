//
//  LoginDataSource.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/3.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "LoginDataSource.h"

@implementation LoginDataSource
@end

@implementation LoginSuccessedDataSource
@end

@implementation LoginWebViewURL

- (void)replaceEpsProjIdOrHumainId{
    NSString *humainID = [[NSUserDefaults standardUserDefaults] valueForKey:@"humainID"];
    if (self.titleid) {
        self.url = [self.url stringByReplacingOccurrencesOfString:@"[@EpsProjId]" withString:self.titleid];
    }
    if (humainID) {
        self.url = [self.url stringByReplacingOccurrencesOfString:@"[@HumanId]" withString:humainID];
    }
    
    if (![self.icon hasPrefix:@"http"]) {
        self.icon = [NSString stringWithFormat:@"%@%@",POWERM3URL,self.icon];
        self.iconselected = [NSString stringWithFormat:@"%@%@",POWERM3URL,self.iconselected];
    }
}


@end

@implementation PowerProjectListModel
@end
