//
//  GFContactViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/5.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFContactViewController.h"
#import "GFContactInfoController.h"
#import "GFContactTableViewCell.h"
#import "GFChatViewController.h"
#import "GFBaseTableViewCell.h"
#import "GFContactCell.h"
#import "GFContactModel.h"
#import "GFContactMessageRecord+CoreDataProperties.h"
#import "GFContactInformation+CoreDataProperties.h"
#import "GFSearchResultController.h"

@interface GFContactViewController ()<UISearchResultsUpdating,UISearchControllerDelegate>

@property (nonatomic, strong) UISearchController *gfSearchController;
@property (nonatomic, strong) UISegmentedControl *gfSegmentedControl;
@property (nonatomic, strong) GFSearchResultController *gf_searchResultContrller;
@end

@implementation GFContactViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self delete];
    self.title = @"消息";
    [self.navigationItem setTitleView:self.gfSegmentedControl];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GFContactTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell1"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GFBaseTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell2"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GFContactCell class]) bundle:nil] forCellReuseIdentifier:@"cell3"];
    [self.tableView setTableHeaderView:self.gfSearchController.searchBar];
    [self.tableView setRowHeight:60];
    
    [self fetchContactMessageRecord];
}

#pragma mark - coredata

- (void)delete{
    for (GFContactInformation *contact in [GFContactInformation MR_findAll]) {
        [contact MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)fetchContactInformation{
    NSFetchRequest *request = [GFContactInformation MR_requestAllSortedBy:@"userID" ascending:YES];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
}

- (void)fetchContactMessageRecord{
    NSFetchRequest *request = [GFContactInformation MR_requestAllSortedBy:@"date" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"latelyMessage = %d",YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - SegmentedControl
- (UISegmentedControl *)gfSegmentedControl{
    if(!_gfSegmentedControl){
        _gfSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"消息",@"联系人"]];
        _gfSegmentedControl.selectedSegmentIndex = 0;
        _gfSegmentedControl.tintColor = UIColorFromRGB(0x05a499);
        [_gfSegmentedControl addTarget:self action:@selector(segmengtedContorlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _gfSegmentedControl;
}
- (void)segmengtedContorlValueChanged:(UISegmentedControl *)segment{
    segment.selectedSegmentIndex==0?[self fetchContactMessageRecord]:[self fetchContactInformation];
}

#pragma mark -  tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 消息
    if (_gfSegmentedControl.selectedSegmentIndex==0) {
        GFContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        GFContactInformation *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        GFContactMessageRecord *record = [GFContactMessageRecord
                            MR_findByAttribute:@"contactInfomation" withValue:contact].lastObject;
        
        [cell configGFContactTableViewCellWithContactInfo:contact messageRecord:record];
        return cell;
    }else{
        GFContactInformation *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
        GFContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
        [cell configCellWithContactModel:contact];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GFContactInformation *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // chat
    if (_gfSegmentedControl.selectedSegmentIndex==0) {
        GFChatViewController *chat = MAINSTORYBOARD(@"GFChatViewController");
        chat.hidesBottomBarWhenPushed = YES;
        chat.gf_Contact = contact;
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        GFContactInfoController *info = [[GFContactInfoController alloc]init];
        GFContactModel *model = [[GFContactModel alloc]init];
        model.userID = contact.userID;
        model.userName = contact.userName;
        model.userAccount = contact.userAccount;
        model.userHeadImage = contact.userHeadImage;
        info.contactModel = model;
        info.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:info animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - searchBarController

- (UISearchController *)gfSearchController{
    if (!_gfSearchController) {
        self.gf_searchResultContrller = [[GFSearchResultController alloc]initWithStyle:UITableViewStylePlain];
        self.gf_searchResultContrller.gf_Navigation = self.navigationController;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.gf_searchResultContrller];
        
        _gfSearchController = [[UISearchController alloc]initWithSearchResultsController:nav];
        _gfSearchController.searchResultsUpdater = self;
        _gfSearchController.delegate = self;
        self.definesPresentationContext = YES;
    }
    return _gfSearchController;
}
#pragma mark - searchBarController  delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    __weak typeof(self) weakself = self;
    
    NSMutableArray *contactArr = [NSMutableArray array];
    [GFNetworkHelper POST:PowerURL_ContactList parameters:@{@"name":searchController.searchBar.text} success:^(id responseObject) {
        
        BLog(@"搜索到的联系人: %@",responseObject);

        if (responseObject && [responseObject isKindOfClass:[NSArray class]]){
            for (NSDictionary *dict in responseObject) {
                GFContactModel *model = [[GFContactModel alloc]initWithJsonDict:dict];
                [contactArr addObject:model];
            }
        }else{
            [contactArr removeAllObjects];
        }
        weakself.gf_searchResultContrller.resultArray = contactArr.copy;
        
        BLog(@" count   %lu",(unsigned long)_gf_searchResultContrller.resultArray.count);
        
        [weakself.gf_searchResultContrller.tableView reloadData];
    } failure:^(NSError *err) {
        
    }];
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
