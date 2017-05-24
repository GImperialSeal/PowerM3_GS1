//
//  GFMenuViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/8.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFMenuViewController.h"
#import "LoginDataSource.h"
@interface GFMenuViewController ()<UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *searchSourceArray;
@property (nonatomic, strong) NSArray *fetchResultArray;

@end

@implementation GFMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     BLog(@"********** menu  load ***************");
    
    self.sourceArray = [NSMutableArray array];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;

    self.view.backgroundColor = [UIColor whiteColor];
    _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.tintColor = [UIColor blackColor];
    self.definesPresentationContext = YES;
    [self.tableView setTableHeaderView:_searchController.searchBar];

    __weak typeof (self)weakself = self;

   [GFNetworkHelper GET:ProjectList parameters:nil success:^(id responseObject) {
       for (NSDictionary *dict in responseObject[@"epsactived"]) {
           PowerProjectListModel *model = [[PowerProjectListModel alloc]initWithJsonDict:dict];
           [weakself.sourceArray addObject:model];
       }
       [weakself.tableView reloadData];
       
   } failure:^(NSError *err) {
       [MBProgressHUD showError:@"项目列表加载失败" toView:weakself.view];
        BLog(@"项目列表加载失败: error: %@",err);
   }];
}
#pragma mark - SearchController delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    if (self.sourceArray.count==0) {
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"project_name CONTAINS %@",searchController.searchBar.text];
    self.fetchResultArray = [self.sourceArray filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.isActive) {
        return self.fetchResultArray.count;
    }
    return self.sourceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchController.isActive) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
            cell.textLabel.font = PingFangSCRegular(15);
        }
        PowerProjectListModel *model = self.fetchResultArray[indexPath.row];
        cell.textLabel.text = model.project_name;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.textLabel.font = PingFangSCRegular(15);

        }
        
        PowerProjectListModel *model = self.sourceArray[indexPath.row];
        cell.textLabel.text = model.project_name;
        if (model.projectType) {
            cell.imageView.image = [UIImage imageNamed:@"icon_project"];
        }else{
            cell.imageView.image = [UIImage imageNamed:@"icon_wheel"];
        }
        // Configure the cell...
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_searchController.isActive) {
        [self.navigationController pushViewController:[UIViewController new] animated:YES];
    }
    PowerProjectListModel *model = self.sourceArray[indexPath.row];
    [GFNetworkHelper GET:[NSString stringWithFormat:@"%@%@",ProjectGuid,model.project_guid] parameters:nil success:^(id responseObject) {
        if ([responseObject[@"success"] boolValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWebView" object:model.project_name];
            [[NSUserDefaults standardUserDefaults] setValue:model.project_guid forKey:@"epsprojid"];
        }else{
            [GFAlertView alertWithTitle:@"加载失败"];
        }
    } failure:^(NSError *err) {
        [GFAlertView alertWithTitle:@"加载失败"];
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
