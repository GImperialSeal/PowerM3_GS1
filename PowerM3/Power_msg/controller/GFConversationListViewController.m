//
//  GFConversationListViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/9.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFConversationListViewController.h"
#import "GFRCloudHelper.h"
#import "GFConversationViewController.h"
#import "GFCreateDiscussGroupController.h"
#import "GFPopView.h"
#import "GFSearchViewController.h"
#import "MJRefresh.h"
#import "GFContactListDelegate.h"
#import "GFUserInfoCoreDataModel+CoreDataProperties.h"
#import "GFPickerHelper.h"
#import "GFUploadManager.h"

#import "GFBaseViewController.h"
@interface GFConversationListViewController ()
@property (strong, nonatomic)  UISegmentedControl *segmentedControl;
@property (strong, nonatomic)  GFSearchViewController *searchController;
@property (strong, nonatomic)  GFContactListDelegate  *contactDelegate;
@end

@implementation GFConversationListViewController
- (instancetype)init{
    if (self = [super init]) {
        //设置需要显示哪些类型的会话
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                            @(ConversationType_DISCUSSION),
                                            @(ConversationType_CHATROOM),
                                            @(ConversationType_GROUP),
                                            @(ConversationType_APPSERVICE),
                                            @(ConversationType_SYSTEM)]];
        //设置需要将哪些类型的会话在会话列表中聚合显示
        //[self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
                                             // @(ConversationType_GROUP)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self)weakself = self;
    [[GFRCloudHelper shareInstace] syncFriendList:^(NSArray *friends, BOOL isSuccess) {
        if (isSuccess) [weakself sortArr:friends];
        else BLog(@"刷新失败");
    }];
    
    [self setUI];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setUI{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];

    self.showConnectingStatusOnNavigatorBar = YES;
    
    [self.conversationListTableView registerNib:[UINib nibWithNibName:@"GFContactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    if (self.emptyConversationView) {
        [self.emptyConversationView removeFromSuperview];
    }
    
    // 默认数据
    _contactDelegate = [[GFContactListDelegate alloc]init];
    _contactDelegate.newsNavigationController = self.navigationController;

    __weak typeof(self)weakself = self;
    // 下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [[GFRCloudHelper shareInstace] syncFriendList:^(NSArray *friends, BOOL isSuccess) {
            [self.conversationListTableView.mj_header endRefreshing];
            if (isSuccess) [weakself sortArr:friends];
            else BLog(@"刷新失败");
        }];
    }];
    header.backgroundColor =[UIColor groupTableViewBackgroundColor];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.conversationListTableView.mj_header = header;
    
    // title
    _segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"消息",@"联系人"]];
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.tintColor = GFThemeColor;
    [_segmentedControl addTarget:self action:@selector(clickSegmentToPushContactListView:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:_segmentedControl];
    
    // 导航
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickAddBtn)];
    
    // 搜索
    GFSearchResultController *resultVC = [[GFSearchResultController alloc]init];
    resultVC.nav = self.navigationController;
    _searchController = [[GFSearchViewController alloc]initWithSearchResultsController:resultVC];
    [self.conversationListTableView setTableHeaderView:_searchController.searchBar];
    self.definesPresentationContext = YES;

    //改变索引的颜色
    self.conversationListTableView.sectionIndexColor = GFThemeColor;
    self.conversationListTableView.sectionIndexBackgroundColor = [UIColor clearColor];

    //
}

#pragma mark -  click func
- (void)clickSegmentToPushContactListView:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        self.conversationListTableView.delegate   = self.contactDelegate;
        self.conversationListTableView.dataSource = self.contactDelegate;
    }else{
        self.conversationListTableView.delegate   = self;
        self.conversationListTableView.dataSource = self;
    }
    [self.conversationListTableView reloadData];
}
- (void)clickAddBtn{
    
    [GFPopView popTableViewAtPoint:CGPointMake(KW-40, 64) inView:self.tabBarController completion:^(NSInteger index) {
        
        if (index == 0) {
            GFCreateDiscussGroupController *discussVC =  MAINSTORYBOARD(@"GFCreateDiscussGroupController");
            discussVC.sectionTitlesArray = self.contactDelegate.keys;
            discussVC.sourceDictionary = self.contactDelegate.friendsDict;
            discussVC.showSectionIndex = YES;
            discussVC.title = @"选取联系人";
            discussVC.completeBlock = ^(NSArray *listArray){
                // 创建讨论组
                static NSString *lastName = @"";
                for (NSString *userId in listArray) {
                    GFUserInfoCoreDataModel *info = [GFUserInfoCoreDataModel findUserByUserId:userId];
                    if (info.name.length) {
                        NSArray *name = [info.name componentsSeparatedByString:@"/"];
                        if (name.count) {
                            lastName = [lastName stringByAppendingString:[NSString stringWithFormat:@"、 %@",name.firstObject]];
                        }
                    }
                }
                lastName = [lastName stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
                NSLog(@"lastName: %@",lastName);
                
                
                [[RCIM sharedRCIM] createDiscussion:lastName userIdList:listArray success:^(RCDiscussion *discussion) {
                    BLog(@"red: %@",discussion);
                    
                } error:^(RCErrorCode status) {
                    BLog(@"red: %ld",(long)status);
                }];
            };
            [self presentViewController:discussVC animated:YES completion:nil];

        }else if(index == 1){
            self.searchController.active = YES;
        }
        } titles:@"发起群聊",@"查找",nil];
 }

#pragma mark - Selected Table Row
//重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    GFConversationViewController *conversationVC = [[GFConversationViewController alloc]init];
    conversationVC.conversationType = model.conversationType;
    conversationVC.targetId = model.targetId;
    conversationVC.title = model.conversationTitle;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

#pragma mark - lazy load
- (void)sortArr:(NSArray *)friends{
    [GFRCloudHelper sortCHWithArray:friends sortedByKey:@"name" completion:^(NSMutableDictionary *dict, NSArray *keys) {
        _contactDelegate.keys = keys;
        _contactDelegate.friendsDict = dict;
        [self.conversationListTableView reloadData];
    }];
}


- (void)notifyUpdateUnreadMessageCount{
    [super notifyUpdateUnreadMessageCount];
    
    [[GFRCloudHelper shareInstace] refreshBadgeValue];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
