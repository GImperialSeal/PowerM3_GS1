//
//  GFAudioRecordCell.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/10.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GFAudioRecordCoreDataModel;
@interface GFAudioRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLable;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *share;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *palyButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;



@property (nonatomic, strong) GFAudioRecordCoreDataModel *model;
@property (nonatomic) NSInteger selectedRow;
@end
