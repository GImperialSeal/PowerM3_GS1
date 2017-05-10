//
//  GFContactListDelegate.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/31.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFContactListDelegate.h"
#import "GFConversationViewController.h"
#import "GFRCloudHelper.h"
#import "MJRefresh.h"
#import "GFGroupListViewController.h"
#import "GFContactModel.h"
#import <RongIMKit/RongIMKit.h>
#import "GFContactsTableViewCell.h"

@interface GFContactListDelegate ()

@end

@implementation GFContactListDelegate

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friendsDict[_keys[section]] count];
}
// 设置分区头部文字
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 90, 20)];
    lab.font = [UIFont systemFontOfSize:15];
    lab.text = _keys[section];
    lab.textColor = [UIColor grayColor];
    [view addSubview:lab];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    RCUserInfo *info = _friendsDict[_keys[indexPath.section]][indexPath.row];
    
     BLog(@"headimage: %@",info.portraitUri);
    [cell.headImageView gf_loadImagesWithURL:info.portraitUri];
    
    cell.titleLabel.text = info.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _keys[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
#pragma mark - 字母索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _keys;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RCUserInfo *info = _friendsDict[_keys[indexPath.section]][indexPath.row];
    GFConversationViewController *conversationVC = [[GFConversationViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = info.userId;
    conversationVC.title = info.name;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.newsNavigationController pushViewController:conversationVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    NSInteger count = 0;
    
    BLog(@"%@-%ld",title,(long)index);
    
    for(NSString *character in _keys)
    {
        if([character isEqualToString:title])
        {
            return count;
        }
        count ++;
    }
    return 0;
}


@end
