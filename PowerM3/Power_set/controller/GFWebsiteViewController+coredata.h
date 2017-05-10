//
//  GFWebsiteViewController+coredata.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/2/27.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFWebsiteViewController.h"

@interface GFWebsiteViewController (coredata)<NSFetchedResultsControllerDelegate>
@property(nonatomic,strong,readonly)NSFetchedResultsController *fetchedResultsController;

@end
