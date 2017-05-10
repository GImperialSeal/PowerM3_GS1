//
//  GFVoiceRecordViewController+coredata.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/10.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFVoiceRecordViewController.h"

@interface GFVoiceRecordViewController (coredata)<NSFetchedResultsControllerDelegate>
@property(nonatomic,strong,readonly)NSFetchedResultsController *fetchedResultsController;

@end
