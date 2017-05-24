//
//  GFWebsiteViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/18.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFWebsiteViewController.h"
#import "GFWebsiteCoreDataModel+CoreDataProperties.h"
#import "UIImageView+PowerCache.h"
#import "PureLayout.h"
#import "GFWebsiteViewController+coredata.h"

@interface GFWebsiteViewController ()<UITableViewDelegate,UITableViewDataSource>
@end

@implementation GFWebsiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.rowHeight = 56;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [GFWebsiteCoreDataModel MR_findAll].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
        UIImageView *logoImageView = [UIImageView newAutoLayoutView];
//        logoImageView.layer.masksToBounds = YES;
//        logoImageView.layer.cornerRadius = 20;
        logoImageView.tag = 101;
        [cell.contentView addSubview:logoImageView];
        
        [logoImageView autoSetDimensionsToSize:CGSizeMake(40, 40)];
        [logoImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12];
        [logoImageView autoAlignAxisToSuperviewMarginAxis:ALAxisHorizontal];
        
        UILabel *titleLabel = [UILabel newAutoLayoutView];
        titleLabel.tag = 102;
        titleLabel.font = PingFangSCRegular(15);
        [cell.contentView addSubview:titleLabel];
        
        [titleLabel autoAlignAxisToSuperviewMarginAxis:ALAxisHorizontal];
        [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:logoImageView withOffset:20];
    }
    GFWebsiteCoreDataModel *info = [GFWebsiteCoreDataModel MR_findAll][indexPath.row];

    if ([info.url isEqualToString:POWERM3URL]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    UIImageView *logo  = [cell viewWithTag:101];
    UILabel     *title = [cell viewWithTag:102];
    [logo gf_loadImagesWithURL:info.loginImage];
    title.text = info.title;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GFWebsiteCoreDataModel *info = [GFWebsiteCoreDataModel MR_findAll][indexPath.row];
    if (![info.url isEqualToString:POWERM3URL]) {
        [GFAlertView showAlertWithTitle:@"" message:[NSString stringWithFormat:@"是否要切换到站点: %@ ",info.url] completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
            if (buttonIndex == 1) {
                [GFUserDefault setValue:info.url forKey:PowerOnWebsiteUserDefaultKey];
                [GFCommonHelper replaceRootWindowWithOptions:NO];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    }
}

@end
