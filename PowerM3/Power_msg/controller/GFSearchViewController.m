//
//  GFSearchViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/31.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFSearchViewController.h"
#import "UISearchBar+Extension.h"
#import "GFContactModel.h"



@interface GFSearchViewController ()<UISearchControllerDelegate,UISearchResultsUpdating>

@end

@implementation GFSearchViewController


- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController{
    if (self = [super initWithSearchResultsController:searchResultsController]) {
        // 搜索
        //self.dimsBackgroundDuringPresentation = NO;
        self.delegate = self;
        self.searchResultsUpdater = self;
        
        // 背景色
        self.searchBar.barTintColor = [UIColor groupTableViewBackgroundColor];
        [self.searchBar settingSearchBar];

    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 模糊
//    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
//    effectView.frame = self.view.bounds;
//    [self.view insertSubview:effectView atIndex:0];
    
    
}




- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    GFSearchResultController *resultVC = (GFSearchResultController *)self.searchResultsController;
    
    if (searchController.searchBar.text.length==0) {
       
        if (resultVC.sourceArray.count) {
            [resultVC.sourceArray removeAllObjects];
            
            [resultVC.tableView reloadData];
        }
        return;
    }

    NSMutableArray *contactArr = [NSMutableArray array];
    [GFNetworkHelper POST:ContactList parameters:@{@"name":searchController.searchBar.text} success:^(id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]){
            for (NSDictionary *dict in responseObject) {
                GFContactModel *model = [[GFContactModel alloc]initWithJsonDict:dict];
                [contactArr addObject:model];
            }
        }
        if (contactArr.count>0) {
            resultVC.sourceArray = contactArr.mutableCopy;
            [resultVC.tableView reloadData];

        }
    } failure:^(NSError *err) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
