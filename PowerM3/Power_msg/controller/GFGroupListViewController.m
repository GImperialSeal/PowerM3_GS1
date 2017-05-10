//
//  GFGroupListViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/30.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFGroupListViewController.h"
#import "GFRCloudHelper.h"
#import "PureLayout.h"
#import "GFConversationViewController.h"
@interface GFGroupListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *sourceArr;
@end

@implementation GFGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self.view addSubview:tableView];
    
    [[GFRCloudHelper shareInstace] syncGroupList:^(NSMutableArray *groups, BOOL isSuccess) {
        if (isSuccess) {
            self.sourceArr = groups;
            [tableView reloadData];
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
        UIImageView *imageView = [UIImageView newAutoLayoutView];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [UILabel newAutoLayoutView];
        label.tag = 101;
        label.font = PingFangSCRegular(15);
        [cell.contentView addSubview:label];
        
        [imageView autoAlignAxisToSuperviewMarginAxis:ALAxisHorizontal];
        [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12];
        [imageView autoSetDimensionsToSize:CGSizeMake(40, 40)];
        
        [label autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:imageView withOffset:10];
        [label autoAlignAxisToSuperviewMarginAxis:ALAxisHorizontal];
        [label autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20 relation:NSLayoutRelationGreaterThanOrEqual];
        
    }
    UIImageView *head = [cell.contentView viewWithTag:100];
    UILabel *label = [cell.contentView viewWithTag:101];
    RCGroup *group = _sourceArr[indexPath.row];

    head.image = [UIImage imageNamed:@"icon_qunzu"];
    label.text = group.groupName;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RCGroup *group = [GFRCloudHelper shareInstace].groupsArray[indexPath.row];

    GFConversationViewController *conversationVC = [[GFConversationViewController alloc]init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = group.groupId;
    conversationVC.title = group.groupName;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
