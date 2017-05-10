//
//  ZFBaseSettingViewController.m
//  ZFSetting
//
//  Created by 任子丰 on 15/9/19.
//  Copyright (c) 2013年 任子丰. All rights reserved.
//

#import "ZFBaseSettingViewController.h"
#import <objc/runtime.h>
#import "ZFTableViewCell.h"
#import "GFDetailCell_HeadStyle.h"
@interface ZFBaseSettingViewController ()
{
    UISwitch *_s;
}
@property (copy, nonatomic) void(^switchChangeBlock)(BOOL on);

@end

@implementation ZFBaseSettingViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.sectionFooterHeight = 0;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [self setTableView:tableView];
    
    _allGroups = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GFDetailCell_HeadStyle" bundle:nil] forCellReuseIdentifier:@"headStyle"];

    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _allGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ZFSettingGroup *group = _allGroups[section];
    return group.items.count;
}



#pragma mark 每当有一个cell进入视野范围内就会调用，返回当前这行显示的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZFSettingGroup *group = _allGroups[indexPath.section];
    ZFSettingItem *item = group.items[indexPath.row];

    if (item.type == ZFSettingItemTypeSignout) {
        
        ZFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signout"];
        if (!cell) {
            cell = [[ZFTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"signout"];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 1)];

            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, CGRectGetWidth(self.view.frame)-40, 44)];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor redColor];
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = 4;
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 100;
            [cell.contentView addSubview:label];
        }
        UILabel *label = [cell.contentView viewWithTag:100];
        label.text = item.title;
                
        
        return cell;
    }else if(item.type == ZFSettingItemTypeCustom){
        
        if ([self.delegate respondsToSelector:@selector(gf_SettingCustomCellWithTableView:cellForRowAtIndexPath:)]) {
            return [self.delegate gf_SettingCustomCellWithTableView:tableView cellForRowAtIndexPath:indexPath];
        }
        return nil;
    }else if(item.type == ZFSettingItemTypeHeadImage){
        GFDetailCell_HeadStyle *cell = [tableView dequeueReusableCellWithIdentifier:@"headStyle" forIndexPath:indexPath];
        [cell.headImageView gf_loadImagesWithURL:item.icon];
        cell.titleLabel.text = item.title;
        cell.subtitleLabel.text = item.subtitle;
        return cell;

    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        }
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.subtitle;
        [self tableViewCell:cell setCellStyleWithItem:item];
        return cell;
    }
}


- (void)tableViewCell:(UITableViewCell *)cell setCellStyleWithItem:(ZFSettingItem *)item{

    if (item.type == ZFSettingItemTypeArrow) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // 用默认的选中样式
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    } else if (item.type == ZFSettingItemTypeSwitch) {
        
        _s = [[UISwitch alloc] init];
        [_s addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
        _s.on = item.switchDefaultState;
        objc_setAssociatedObject(cell, @"switchBlock", item.switchBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // 右边显示开关
        cell.accessoryView = _s;
        // 禁止选中
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell.accessoryView = nil;
        // 用默认的选中样式
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

}
- (void)switchStatusChanged:(UISwitch *)s{
   
    UITableViewCell *cell = (UITableViewCell *)s.superview;
    
    void(^switchChangeBlock)(BOOL on) = objc_getAssociatedObject(cell, @"switchBlock");
    if (switchChangeBlock) {
        switchChangeBlock(s.on);
    }
}

#pragma mark 点击了cell后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 0.取出这行对应的模型
    ZFSettingGroup *group = _allGroups[indexPath.section];
    ZFSettingItem *item = group.items[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 1.取出这行对应模型中的block代码
    if (item.operation) {
        // 执行block
        item.operation(item);
    }
}

#pragma mark 返回每一组的header标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    ZFSettingGroup *group = _allGroups[section];
    
    return group.header;
}
#pragma mark 返回每一组的footer标题
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    ZFSettingGroup *group = _allGroups[section];
    
    return group.footer;
}

#pragma mark - cell 高度

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFSettingGroup *group = _allGroups[indexPath.section];
    ZFSettingItem *item = group.items[indexPath.row];
    return item.rowHeight;
}
@end
