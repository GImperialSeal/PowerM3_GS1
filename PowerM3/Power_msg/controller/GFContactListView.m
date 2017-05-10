//
//  GFContactListView.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/15.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFContactListView.h"
#import "PureLayout.h"
#import "GFContactListCoreDataModel+CoreDataProperties.h"
#import "GFSearchResultController.h"
#import "UISearchBar+Extension.h"
#import "GFContactModel.h"
@interface GFContactListView ()<UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchResultsUpdating>
@property (nonatomic, strong) GFSearchResultController *resultContrller;
@property (nonatomic, strong) UISearchController *searchController;
@end
@implementation GFContactListView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:frame];
        [self addSubview:tableView];
        tableView.rowHeight = 56;
        tableView.delegate = self;
        tableView.dataSource = self;
        //改变索引的颜色
        tableView.sectionIndexColor = GFThemeColor;
        //改变索引选中的背景颜色
        tableView.sectionIndexTrackingBackgroundColor = [UIColor blackColor];
        
        
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        // 背景色
        _searchController.searchBar.barTintColor = [UIColor groupTableViewBackgroundColor];
        [_searchController.searchBar settingSearchBar];
        // 模糊
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
        effectView.frame = _searchController.view.bounds;
        [_searchController.view insertSubview:effectView atIndex:0];

        [tableView setTableHeaderView:_searchController.searchBar];

    }
    return self;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        UIImageView *imageView = [UIImageView newAutoLayoutView];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [UILabel newAutoLayoutView];
        label.tag = 101;
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
    GFContactListCoreDataModel *info = _friendsDict[_keys[indexPath.section]][indexPath.row];
    [head gf_loadImagesWithURL:info.headImage];
    label.text = info.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _keys[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 20;
}
#pragma mark - 字母索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return _keys;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RCUserInfo *info = _friendsDict[_keys[indexPath.section]][indexPath.row];

    RCConversationViewController *conversationVC = [[RCConversationViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = info.userId;
    conversationVC.title = info.name;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.newsNavigationController pushViewController:conversationVC animated:YES];

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    NSInteger count = 0;
    
    NSLog(@"%@-%ld",title,(long)index);
    
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}
#pragma mark - uisearch bar  delegate
- (void)willPresentSearchController:(UISearchController *)searchController{
    self.newsTabbarController.tabBar.hidden = YES;
    self.resultContrller = [[GFSearchResultController alloc]initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:_resultContrller];
    nav.view.frame = searchController.view.bounds;
    [searchController.view addSubview:nav.view];
    [searchController addChildViewController:nav];
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    self.newsTabbarController.tabBar.hidden = NO;
    [self.resultContrller.view removeFromSuperview];
    [self.resultContrller removeFromParentViewController];
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    if (searchController.searchBar.text.length==0) {
        [self tableViewHeadViewWithContent:@"搜索指定内容" headHeight:60];
        return;
    }
    // 输入搜索内容时 不显示headview
    [self tableViewHeadViewWithContent:nil headHeight:0.001];

    NSMutableArray *contactArr = [NSMutableArray array];
    [GFNetworkHelper POST:PowerURL_ContactList parameters:@{@"name":searchController.searchBar.text} success:^(id responseObject) {
        
        NSLog(@"responese:  %@",responseObject);
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]){
            for (NSDictionary *dict in responseObject) {
                GFContactModel *model = [[GFContactModel alloc]initWithJsonDict:dict];
                [contactArr addObject:model];
            }
        }else{
            [self tableViewHeadViewWithContent:@"没有搜索到您要的结果" headHeight:60];
        }
        self.resultContrller.sourceArray = contactArr.copy;
        [self.resultContrller.tableView reloadData];
    } failure:^(NSError *err) {

        [self tableViewHeadViewWithContent:@"没有搜索到您要的结果" headHeight:60];
   }];
}

- (void)tableViewHeadViewWithContent:(NSString *)content headHeight:(CGFloat)height{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KW, height)];
    label.text = content;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:13];
    [self.resultContrller.tableView setTableHeaderView:label];
    
    self.resultContrller.sourceArray = nil;
    [self.resultContrller.tableView reloadData];
}

@end
