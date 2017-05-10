//
//  GFChatViewController.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/7.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GFContactInformation;
@interface GFChatViewController : UIViewController
{
    NSFetchedResultsController *_fetchedResultsController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) GFContactInformation *gf_Contact;

@end
