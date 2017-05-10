//
//  GFChatTableViewCell.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/7.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFContactMessageRecord;

@interface GFChatTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *headButton;

@property (nonatomic, strong) UIButton *bodyButton;

@property (nonatomic, strong) GFContactMessageRecord *messageRecordModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
