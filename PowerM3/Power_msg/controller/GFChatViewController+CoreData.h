//
//  GFChatViewController+CoreData.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/16.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFChatViewController.h"

@interface GFChatViewController (CoreData)<NSFetchedResultsControllerDelegate>

@property(nonatomic,strong,readonly)NSFetchedResultsController *fetchedResultsController;

-(void)scrollToBottom:(BOOL)animated;

-(void)loadMoreMsg;

@end
