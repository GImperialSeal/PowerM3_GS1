//
//  GFConversationViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/21.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFConversationViewController.h"
#import "GFRCloudHelper.h"
#import "GFContactModel.h"
#import "GFGroupMemberViewController.h"
#import "GFConversationDetailController.h"
@interface GFConversationViewController ()

@end

@implementation GFConversationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // 刷新角标
    [[GFRCloudHelper shareInstace] refreshBadgeValue];
    
    // 设置UI
    if (self.conversationType == ConversationType_DISCUSSION) {
        NSString *nicknameKey = [NSString stringWithFormat:@"%@_SHOW_DISCUSSION_NICKNAME_KEY",self.targetId];
        
        self.displayUserNameInCell = [GFUserDefault boolForKey:nicknameKey];

        // 添加right item
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_chengyuan"] style:UIBarButtonItemStylePlain target:self action:@selector(lookoutGroupMember)];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
        
        
        // 修改vc title
        [[RCIM sharedRCIM] getDiscussion:self.targetId success:^(RCDiscussion *discussion) {
            if ([self.title containsString:@"、 "]) {
                self.title = [NSString stringWithFormat:@"讨论组(%zd)",discussion.memberIdList.count];
            }else{
                self.title = [NSString stringWithFormat:@"%@(%zd)",discussion.discussionName,discussion.memberIdList.count];
            }
        } error:^(RCErrorCode status) {
            
        }];
    }
    
}

#pragma mark - click func

- (void)didTapCellPortrait:(NSString *)userId{
    BLog(@"点击头像");

    GFConversationDetailController *VC = [[GFConversationDetailController alloc]init];
    VC.userId = userId;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)lookoutGroupMember{
    BLog(@"look out");
    [[RCIM sharedRCIM] getDiscussion:self.targetId success:^(RCDiscussion *discussion) {
        GFGroupMemberViewController *mvc = [[GFGroupMemberViewController alloc]init];
        mvc.discussion = discussion;
        [self.navigationController pushViewController:mvc animated:YES];
    } error:^(RCErrorCode status) {
        
    }];
}


#pragma mark - noti func

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
