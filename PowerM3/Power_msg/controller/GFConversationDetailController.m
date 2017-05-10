//
//  GFConversationDetailController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/5/2.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFConversationDetailController.h"
#import "GFRCloudHelper.h"
#import "GFConversationViewController.h"
@interface GFConversationDetailController ()

@end

@implementation GFConversationDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    GFRCUserInfo  *rcInfo = (GFRCUserInfo *)[[GFRCloudHelper shareInstace] currentUserInfoWithUserId:self.userId];

    NSArray *strArr = [rcInfo.name componentsSeparatedByString:@"/"];
    
    NSString *nickName = nil;
    NSString *job  = nil;
    NSString *company = nil;
    if (!strArr || strArr.count<3) {
        nickName = rcInfo.name;
        job  = @"未知";
        company = @"未知";
    }else{
        nickName = strArr.firstObject;
        job  = strArr[1];
        company = strArr.lastObject;
    }
   
    ZFSettingItem *head  = [ZFSettingItem itemWithHeadImage:rcInfo.portraitUri title:nickName subtitle:job];
    
    ZFSettingItem *phone = [ZFSettingItem itemWithTitle:@"手机" subtitle:rcInfo.phone];
    phone.type = ZFSettingItemTypeNone;
    
    ZFSettingItem *user  = [ZFSettingItem itemWithTitle:@"公司" subtitle:company];
    user.type = ZFSettingItemTypeNone;
    
    ZFSettingItem *email = [ZFSettingItem itemWithTitle:@"邮箱" subtitle:rcInfo.email];
    email.type = ZFSettingItemTypeNone;
    
    ZFSettingItem *msg   = [ZFSettingItem itemWithTitle:@"发送消息" type:ZFSettingItemTypeSignout];
    __weak typeof(self)weakself = self;
    msg.operation = ^(ZFSettingItem *item) {
        
        UIViewController *rootVC = weakself.navigationController.viewControllers[0];

        [self.navigationController popToRootViewControllerAnimated:NO];

        GFConversationViewController *conversationVC = [[GFConversationViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = weakself.userId;
        conversationVC.title = rcInfo.name;
        conversationVC.hidesBottomBarWhenPushed = YES;
        [rootVC.navigationController pushViewController:conversationVC animated:YES];
    };
    
    ZFSettingGroup *h    = [ZFSettingGroup groupWithItem:@[head]];
    
    ZFSettingGroup *info = [ZFSettingGroup groupWithItem:@[user,phone,email]];
    
    ZFSettingGroup *send = [ZFSettingGroup groupWithItem:@[msg]];
    
    [_allGroups addObject:h];
    [_allGroups addObject:info];
    [_allGroups addObject:send];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
