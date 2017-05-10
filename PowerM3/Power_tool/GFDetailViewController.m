//
//  GFDetailViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/5/2.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFDetailViewController.h"
#import "GFDetailCell_HeadStyle.h"
#import "UIImageView+PowerCache.h"
@interface GFDetailViewController ()<ZFBaseSettingViewControllerDelegate>


@end

@implementation GFDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GFDetailCell_HeadStyle" bundle:nil] forCellReuseIdentifier:@"headStyle"];
    self.delegate = self;
    

    ZFSettingItem *head  = [[ZFSettingItem alloc]init];
    head.icon = @"timg.jpg";
    head.title = @"张三";
    head.subtitle = @"subtitle";
    head.rowHeight = 80;
    head.type = ZFSettingItemTypeCustom;
    
    ZFSettingItem *phone = [ZFSettingItem itemWithTitle:@"手机" subtitle:@""];
    
    
    ZFSettingItem *user  = [ZFSettingItem itemWithTitle:@"用户" subtitle:@""];
    
    
    ZFSettingItem *email = [ZFSettingItem itemWithTitle:@"邮箱" subtitle:@""];
    
    
    ZFSettingItem *msg   = [ZFSettingItem itemWithTitle:@"发送消息" type:ZFSettingItemTypeSignout];
    
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


- (UITableViewCell *)gf_SettingCustomCellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFDetailCell_HeadStyle *cell = [tableView dequeueReusableCellWithIdentifier:@"headStyle" forIndexPath:indexPath];
    ZFSettingGroup *group = _allGroups[indexPath.section];
    ZFSettingItem *item = group.items[indexPath.row];

    [cell.headImageView gf_loadImagesWithURL:item.icon];
    cell.titleLabel.text = item.title;
    cell.subtitleLabel.text = item.subtitle;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
