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
#import "GFActionSheet.h"
@import MessageUI;
@interface GFConversationDetailController ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

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
    __weak typeof(self)weakself = self;

   
    ZFSettingItem *head  = [ZFSettingItem itemWithHeadImage:rcInfo.portraitUri title:nickName subtitle:job];
    
    ZFSettingItem *phone = [ZFSettingItem itemWithTitle:@"手机" subtitle:rcInfo.phone];
    phone.type = ZFSettingItemTypeNone;
    phone.operation = ^(ZFSettingItem *item) {
        
        [GFActionSheet ActionSheetWithTitle:@"" buttonTitles:@[@"拨号",@"短信"] cancelButtonTitle:@"取消" completionBlock:^(NSUInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",item.subtitle]];
                [[UIApplication sharedApplication] openURL:url];
            }
            
            if (buttonIndex == 2) {
               
                [self sendMssageToPhone:item.subtitle ];
            }
            
        }];
    };
    
    ZFSettingItem *user  = [ZFSettingItem itemWithTitle:@"公司" subtitle:company];
    user.type = ZFSettingItemTypeNone;
    
    ZFSettingItem *email = [ZFSettingItem itemWithTitle:@"邮箱" subtitle:rcInfo.email];
    email.type = ZFSettingItemTypeNone;
    email.operation = ^(ZFSettingItem *item) {
        
        [GFActionSheet ActionSheetWithTitle:@"" buttonTitles:@[] cancelButtonTitle:@"取消" completionBlock:^(NSUInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weakself sendEmailToEmail:item.subtitle];
            }
        }];
    };
    
    ZFSettingItem *msg   = [ZFSettingItem itemWithTitle:@"发送消息" type:ZFSettingItemTypeSignout];
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

#pragma mark - send msg

- (void)sendMssageToPhone:(NSString *)phone{
    if( [MFMessageComposeViewController canSendText] ){
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc]init];
        //设置短信内容
        //vc.body = @"吃饭了没";
        //设置收件人列表
        vc.recipients = @[phone];
        //设置代理
        vc.messageComposeDelegate = self;
        //显示控制器
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    

}

#pragma mark - send Eamil

- (void)sendEmailToEmail:(NSString *)email{
    if(![MFMailComposeViewController canSendMail]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持邮箱功能,或者邮箱没有绑定用户"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }else{
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        //设置邮件主题
        [vc setSubject:@"邮件"];
        //设置邮件内容
        //[vc setMessageBody:@"开会" isHTML:NO];
        //设置收件人列表
        [vc setToRecipients:@[email]];
        //设置抄送人列表
        //[vc setCcRecipients:@[@"test1@qq.com"]];
        //设置代理
        vc.mailComposeDelegate = self;
        //显示控制器
        [self presentViewController:vc animated:YES completion:nil];
    }

}

#pragma mark - delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultSent:
            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];

            break;
        case MessageComposeResultFailed:
            [MBProgressHUD showError:@"发送失败" toView:self.view];

            break;
            
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result) {
        case MFMailComposeResultFailed:
            [MBProgressHUD showError:@"发送失败" toView:self.view];
            break;
        case MFMailComposeResultSent:
            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
            break;
            
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}



@end
