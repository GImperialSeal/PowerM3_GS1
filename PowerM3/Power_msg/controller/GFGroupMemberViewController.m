//
//  GFGroupMemberViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/4/6.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFGroupMemberViewController.h"
#import "GFRCloudHelper.h"
#import "UIImageView+PowerCache.h"
#import "GFCreateDiscussGroupController.h"
#import "GFItemModel.h"
#import "GFActionSheet.h"
#import "GFGroupMemberCollectionCell.h"
#import "PureLayout.h"
#import "GFUserInfoCoreDataModel+CoreDataProperties.h"
#import "GFConversationViewController.h"

@interface GFGroupMemberViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *sourceArray;
@end

@implementation GFGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setUI];
    [self setData];
}


- (void)reloadConversationView:(void(^)(GFConversationViewController *vc))op{
    GFConversationViewController *vc = self.navigationController.viewControllers[1];
    UICollectionView *collection = vc.conversationMessageCollectionView;
    op(vc);
    [collection reloadData];
}

- (void)setData{
    
    NSString *nicknameKey = [NSString stringWithFormat:@"%@_SHOW_DISCUSSION_NICKNAME_KEY",self.discussion.discussionId];
    
     NSString *notroubleKey = [NSString stringWithFormat:@"%@_DISCUSSION_MESSAGE_NOTROUBLE_MODEL_KEY",self.discussion.discussionId];

    
    //  修改讨论组名称
    NSString *discussionName = [self.discussion.discussionName containsString:@"、 "]?@"未命名":self.discussion.discussionName;
     ZFSettingItem *groupname = [ZFSettingItem itemWithTitle:@"群聊名称" subtitle:discussionName];
    __weak typeof(self)weakself = self;
    groupname.operation = ^(ZFSettingItem *item){
        ZFTextFieldController *textFieldVC = [[ZFTextFieldController alloc]init];
        textFieldVC.content = item.subtitle;
        [self.navigationController pushViewController:textFieldVC animated:YES];
        textFieldVC.completeBlock = ^(NSString *text){
            [[RCIM sharedRCIM] setDiscussionName:weakself.discussion.discussionId name:text success:^{
                item.subtitle = text;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.tableView reloadData];
                    weakself.navigationController.viewControllers[1].title = [NSString stringWithFormat:@"%@(%zd)",text,weakself.discussion.memberIdList.count];
                    [weakself.navigationController popViewControllerAnimated:YES];
                });
            } error:^(RCErrorCode status) {
                
            }];
        };
    };
    
    // 显示群成员昵称
    ZFSettingItem *showname = [ZFSettingItem itemWithSwichTitle:@"显示群成员昵称"];
    showname.switchDefaultState = [GFUserDefault boolForKey:nicknameKey];
    showname.switchBlock = ^(BOOL on){
        
        [weakself reloadConversationView:^(GFConversationViewController *vc) {
            vc.displayUserNameInCell = on;
        }];
        [GFUserDefault setBool:on forKey:nicknameKey];
    };
    
    ZFSettingItem *noDisturbing  = [ZFSettingItem itemWithTitle:@"消息免打扰" type:ZFSettingItemTypeSwitch];
    noDisturbing.switchDefaultState = [GFUserDefault boolForKey:notroubleKey];
    noDisturbing.switchBlock = ^(BOOL on) {
        [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_DISCUSSION targetId:weakself.discussion.discussionId isBlocked:on success:^(RCConversationNotificationStatus nStatus) {
            [GFUserDefault setBool:on forKey:notroubleKey];
        } error:^(RCErrorCode status) {
            
        }];
    };
    
    
    // 清空聊天记录
    ZFSettingItem *delete  = [ZFSettingItem itemWithTitle:@"清空聊天记录" type:ZFSettingItemTypeNone];
    delete.operation = ^(ZFSettingItem *item) {
        [GFActionSheet ActionSheetWithTitle:@"" buttonTitles:@[@"清空聊天记录"] cancelButtonTitle:@"取消" completionBlock:^(NSUInteger buttonIndex) {
            if(buttonIndex == 1){
                BOOL success = [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_DISCUSSION targetId:_discussion.discussionId];
                if (success) {
                    
                    [weakself reloadConversationView:^(GFConversationViewController *vc) {
                        [vc.conversationDataRepository removeAllObjects];
                    }];
                }
            }
        }];
    };
    
    // 删除讨论组
    ZFSettingItem *signout  = [ZFSettingItem itemWithTitle:@"删除并退出" type:ZFSettingItemTypeSignout];
    signout.operation = ^(ZFSettingItem *item){
        [GFActionSheet ActionSheetWithTitle:@"退出后不会通知群聊中其他成员, 且不会再接收次群聊消息" buttonTitles:@[@"确定"] cancelButtonTitle:@"取消" completionBlock:^(NSUInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[RCIM sharedRCIM] quitDiscussion:self.discussion.discussionId success:^(RCDiscussion *discussion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[RCIMClient sharedRCIMClient] deleteMessages:@[weakself.discussion.discussionId]];
                        [weakself.navigationController popToRootViewControllerAnimated:YES];
                    });
                } error:^(RCErrorCode status) {
                    
                }];
            }
        }];
    };
    
    
    [_allGroups addObject:[ZFSettingGroup groupWithItem:@[groupname,noDisturbing,showname,delete]]];
    [_allGroups addObject:[ZFSettingGroup groupWithItem:@[signout]]];
}



- (void)setUI{
    
    self.sourceArray = [NSMutableArray arrayWithArray:self.discussion.memberIdList];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.sectionInset = UIEdgeInsetsMake(8, 20, 8, 20);
    flow.itemSize = CGSizeMake(50, 50+8+4+17);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KW, 300) collectionViewLayout:flow];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.scrollEnabled = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:@"GFGroupMemberCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    collectionView.frame = CGRectMake(0, 0, KW, flow.collectionViewContentSize.height);
    [self.tableView setTableHeaderView:collectionView];

}
 

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([self.discussion.creatorId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        return self.sourceArray.count+2;
    }else{
        return self.sourceArray.count+1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    GFGroupMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row == _sourceArray.count) {
        cell.headImageView.image = [UIImage imageNamed:@"add"];
        cell.titleLabel.text = @"";
    }else if (indexPath.row == _sourceArray.count+1){
        cell.headImageView.image = [UIImage imageNamed:@"icon_jian"];
        cell.titleLabel.text = @"";
    }else{
        NSString *userId = self.sourceArray[indexPath.row];
        GFUserInfoCoreDataModel *info = [GFUserInfoCoreDataModel findUserByUserId:userId];
        [cell.headImageView gf_loadImagesWithURL:info.portraitUri];
        cell.titleLabel.text = info.name;
    }
    
    
    return cell;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // add
    if (indexPath.row == _sourceArray.count) {
        [GFRCloudHelper sortCHWithArray:[GFUserInfoCoreDataModel findAll] sortedByKey:@"name" completion:^(NSMutableDictionary *dict, NSArray *keys) {
            GFCreateDiscussGroupController *discussVC =  MAINSTORYBOARD(@"GFCreateDiscussGroupController");
            discussVC.sectionTitlesArray = keys;
            discussVC.sourceDictionary = dict;
            discussVC.showSectionIndex = YES;
            discussVC.title = @"添加联系人";
            discussVC.memberListArray = _discussion.memberIdList;
            discussVC.completeBlock = ^(NSArray *listArray){
                // 讨论组加人
                [[RCIM sharedRCIM] addMemberToDiscussion:self.discussion.discussionId userIdList:listArray success:^(RCDiscussion *discussion) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSInteger count = _sourceArray.count-1;
//                        [_sourceArray addObjectsFromArray:listArray];
//                        NSMutableArray *indexArray = [NSMutableArray array];
//                        for (int i = 0;i<listArray.count;i++) {
//                            NSIndexPath *index = [NSIndexPath indexPathForItem:count+i inSection:0];
//                            [indexArray addObject:index];
//                        }
//                        [collectionView insertItemsAtIndexPaths:indexArray];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } error:^(RCErrorCode status) {
                    
                }];
            };
            [self presentViewController:discussVC animated:YES completion:nil];
        }];

    }else if (indexPath.row == _sourceArray.count+1){
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *userId in self.discussion.memberIdList) {
            GFUserInfoCoreDataModel *info = [GFUserInfoCoreDataModel findUserByUserId:userId];
            [array addObject:info];
        }
        
        // 讨论组 删除人
        GFCreateDiscussGroupController *discussVC =  MAINSTORYBOARD(@"GFCreateDiscussGroupController");
        discussVC.sectionTitlesArray = @[@"联系人"];
        discussVC.sourceDictionary = @{@"联系人":array};
        discussVC.showSectionIndex = NO;
        discussVC.title = @"删除成员";
        
        discussVC.completeBlock = ^(NSArray *listArray){
            for (NSString *userId in listArray) {
                [[RCIM sharedRCIM] removeMemberFromDiscussion:self.discussion.discussionId userId:userId success:^(RCDiscussion *discussion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } error:^(RCErrorCode status) {
                    NSLog(@"error,%ld",(long)status);
                }];
            }
        };
        [self presentViewController:discussVC animated:YES completion:nil];
    }else{
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
