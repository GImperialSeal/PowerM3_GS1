//
//  GFWebsiteViewController.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/18.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GFWebsiteViewController : UIViewController
{
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, strong) UITableView *tableView;
@end
