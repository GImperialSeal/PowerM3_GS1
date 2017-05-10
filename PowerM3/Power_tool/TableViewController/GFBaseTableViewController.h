//
//  GFBaseTableViewController.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/12.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFBaseTableViewCell.h"
#import "GFBaseTableViewSectionModel.h"
#import "GFBaseTableViewCellModel.h"



@interface GFBaseTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *allSectionModelArray;
@property (nonatomic, strong) UITableView *tableView;
@end
