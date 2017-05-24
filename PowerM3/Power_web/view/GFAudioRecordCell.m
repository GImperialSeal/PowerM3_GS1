//
//  GFAudioRecordCell.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/10.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFAudioRecordCell.h"
#import "GFAudioRecordCoreDataModel+CoreDataProperties.h"
#import "GFUploadManager.h"
#import "EMCDDeviceManager+Media.h"
@implementation GFAudioRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 上传
- (IBAction)share:(id)sender {
    [[GFUploadManager manager]uploadAudioWithParameters:@{} VideoPath:@"" UrlString:@"" complete:^{
        
    } failure:^{
        
    }];
    
}

// 编辑
- (IBAction)edit:(id)sender {
    
}

// 删除
- (IBAction)delete:(id)sender {
    [[NSManagedObjectContext MR_defaultContext] deleteObject:_model];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSFileManager defaultManager] removeItemAtPath:[GFDomainManager appendFilePath:_model.fileName] error:nil];
}

// 播放
- (IBAction)play:(UIButton *)sender {
    
    if (sender) {
        [[EMCDDeviceManager sharedInstance] stopPlaying];
  
    }else{
        [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:[GFDomainManager appendFilePath:_model.fileName] completion:^(NSError *error) {
            
        }];
    }
    sender.selected = !sender.selected;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
