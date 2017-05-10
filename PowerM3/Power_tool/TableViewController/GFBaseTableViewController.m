//
//  GFBaseTableViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFBaseTableViewController.h"
#import "GFContactDetailCell.h"
#import "GFBaseTableViewCell.h"
#import "GFRightImageCell.h"
@interface GFBaseTableViewController ()

@end

@implementation GFBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allSectionModelArray = [NSMutableArray arrayWithCapacity:256];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GFBaseTableViewCell" bundle:nil] forCellReuseIdentifier:@"GFBaseTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GFContactDetailCell" bundle:nil] forCellReuseIdentifier:@"GFContactDetailCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GFRightImageCell" bundle:nil] forCellReuseIdentifier:@"GFRightImageCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allSectionModelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[indexPath.section];
    GFBaseTableViewCellModel *cellModel = sectionModel.cellModelArray[indexPath.row];
    
    if (cellModel.cellType == GFBaseTableViewCellTypeDefault) {
        return 78;
    }
    if (cellModel.cellType == GFBaseTableViewCellTypeRightImage) {
        return 60;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[section];

    return sectionModel.cellModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[indexPath.section];
    
    GFBaseTableViewCellModel *cellModel = sectionModel.cellModelArray[indexPath.row];
    
    if (cellModel.cellType == GFBaseTableViewCellTypeDefault) {
        GFBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFBaseTableViewCell" forIndexPath:indexPath];
        cell.switchChangeBlock = cellModel.switchBlock;
        [cell configCellWithModel:cellModel];
        [self tableViewCell:cell model:cellModel];
        // Configure the cell...
        return cell;
    }else if(cellModel.cellType == GFBaseTableViewCellTypeLeftTitle){
        GFContactDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFContactDetailCell" forIndexPath:indexPath];
        cell.leftLabel.text = cellModel.leftTitle;
        cell.titleLabel.text = cellModel.centerTitle;
        [self tableViewCell:cell model:cellModel];
        return cell;
    }else if(cellModel.cellType == GFBaseTableViewCellTypeRightImage){
        GFRightImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFRightImageCell" forIndexPath:indexPath];
        cell.title.text = cellModel.leftTitle;
        [self tableViewCell:cell model:cellModel];

        
        return cell;
    }else if(cellModel.cellType == GFBaseTableViewCellTypeValue1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"value1"];
            [self tableViewCell:cell model:cellModel];
        }
        cell.textLabel.text = cellModel.leftTitle;
        cell.detailTextLabel.text = cellModel.rightTitle;
        return cell;
    }else{
        return nil;
    }
}

- (void)tableViewCell:(UITableViewCell *)cell model:(GFBaseTableViewCellModel *)model{
    if (model.accessoryType == GFBaseTableViewCellTypeNone) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if(model.accessoryType == GFBaseTableViewCellTypeArrow){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[section];

    return sectionModel.gf_heightForFooder;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[section];

    return sectionModel.gf_heightForHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[section];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [button setBackgroundColor:sectionModel.gf_backgroundColor];
    
    button.layer.masksToBounds = YES;
    
    button.layer.cornerRadius = 5;
    
    [button setTitleColor:sectionModel.gf_titleColor forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(didSelectFooter:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:sectionModel.gf_header forState:UIControlStateNormal];
    
    button.tag = section;
    
    button.frame = CGRectMake(20, 8, KW-40, 30);
    
    [view addSubview:button];
    
    return view;
}

- (void)didSelectFooter:(UIButton *)button{
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[button.tag];
    if (sectionModel.didClick_header) {
        sectionModel.didClick_header();
    }
}

#pragma mark 点击了cell后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 0.取出这行对应的模型
    GFBaseTableViewSectionModel *sectionModel = self.allSectionModelArray[indexPath.section];
    
    GFBaseTableViewCellModel *cellModel = sectionModel.cellModelArray[indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cellModel.block)cellModel.block(cellModel,cell);
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
