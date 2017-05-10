//
//  GFVoiceRecordViewController.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/21.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFVoiceRecordViewController : UIViewController
{
    NSFetchedResultsController *_fetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
