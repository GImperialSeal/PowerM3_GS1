//
//  GFVoiceRecordViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/21.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFVoiceRecordViewController.h"
#import "GFAudioRecordCoreDataModel+CoreDataProperties.h"
#import "GFVoiceRecordViewController+coredata.h"
#import "GFAudioRecordCell.h"
#import "EMAudioRecorderUtil.h"
#import "GFDomainManager.h"
#import "EMCDDeviceManager+Media.h"
#import "GFActionSheet.h"

@interface GFVoiceRecordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *volumeImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UILabel *recordNameLabel;

@end

@implementation GFVoiceRecordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd";
    self.dateLabel.text = [formatter stringFromDate:[NSDate date]];    
    [self updateVoicPeakpower];
    [self renameOfRecordNameLabel];
}

#pragma mark - set UI
- (void)renameOfRecordNameLabel{
    NSInteger count = [GFAudioRecordCoreDataModel MR_findAll].count + 1;
    self.recordNameLabel.text = [NSString stringWithFormat:@"新录音%ld",count];
}



#pragma mark - click func
- (IBAction)playRecorder {
    [[EMAudioRecorderUtil record] audioPlayOrPause];
    _playerButton.selected = !_playerButton.selected;
}
- (IBAction)startRecordOrPauseRecord:(UIButton *)sender {
    self.finishedButton.highlighted = !self.finishedButton.highlighted;
    self.finishedButton.enabled = !self.finishedButton.enabled;
    self.playerButton.highlighted = !self.playerButton.highlighted;
    self.playerButton.enabled = !self.playerButton.enabled;

    if (sender.selected)[[EMAudioRecorderUtil record] start];
    else [[EMAudioRecorderUtil record] pause];
    
    sender.selected = !sender.selected;
}

- (IBAction)stopRecorder {
    __weak typeof(self)weakself = self;
    [[EMAudioRecorderUtil record] stop:^(NSString *path, CGFloat duration) {
        [weakself saveRecordingFile:path duration:duration];
    }];
}

#pragma mark - 保存录音信息到数据库
- (void)saveRecordingFile:(NSString *)recordPath  duration:(CGFloat)aDuration{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"存储语音备忘录" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _recordNameLabel.text;
    }];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"存储" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *toPath = [GFDomainManager cacheFilesWithName:alert.textFields.firstObject.text];
        [[NSFileManager defaultManager] moveItemAtPath:recordPath toPath:toPath error:nil];
        GFAudioRecordCoreDataModel *audio = [GFAudioRecordCoreDataModel MR_createEntity];
        audio.date = [NSDate date];
        audio.fileName = alert.textFields.firstObject.text;
        audio.filePath = toPath;
        audio.duration = [NSString stringWithFormat:@"%ld",(long)aDuration];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self renameOfRecordNameLabel];

    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSFileManager defaultManager] removeItemAtPath:recordPath error:nil];
        [self renameOfRecordNameLabel];

    }];
    [alert addAction:delete];
    [alert addAction:save];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 更新声音测量值
- (void)updateVoicPeakpower{
    [EMAudioRecorderUtil record].audioPower = ^(CGFloat peakPower,NSInteger duration) {
        NSString *imageName = @"RecordingSignal00";

        if (peakPower >= 0 && peakPower <= 0.1) {
            imageName = [imageName stringByAppendingString:@"1"];
        } else if (peakPower > 0.1 && peakPower <= 0.2) {
            imageName = [imageName stringByAppendingString:@"2"];
        } else if (peakPower > 0.3 && peakPower <= 0.4) {
            imageName = [imageName stringByAppendingString:@"3"];
        } else if (peakPower > 0.4 && peakPower <= 0.5) {
            imageName = [imageName stringByAppendingString:@"4"];
        } else if (peakPower > 0.5 && peakPower <= 0.6) {
            imageName = [imageName stringByAppendingString:@"5"];
        } else if (peakPower > 0.7 && peakPower <= 0.8) {
            imageName = [imageName stringByAppendingString:@"6"];
        } else if (peakPower > 0.8 && peakPower <= 0.9) {
            imageName = [imageName stringByAppendingString:@"7"];
        } else if (peakPower > 0.9 && peakPower <= 1.0) {
            imageName = [imageName stringByAppendingString:@"8"];
        }
        _volumeImageView.image = [UIImage imageNamed:imageName];
        NSInteger seconds = duration/10;
        _durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld.%ld",seconds/60,seconds%60,duration%10];
    };
}

#pragma mark -   table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFAudioRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    
    GFAudioRecordCoreDataModel * model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = model.fileName;
    cell.durationLabel.text = model.duration;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd";
    cell.dateLable.text = [formatter stringFromDate:model.date];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GFAudioRecordCoreDataModel * model = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [GFActionSheet ActionSheetWithTitle:@"" buttonTitles:@[@"播放录音",@"上传",@"删除"] cancelButtonTitle:@"取消" completionBlock:^(NSUInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
                [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.filePath completion:^(NSError *error) {
                    [GFAlertView alertWithTitle:@"录音文件不存在"];
                }];
                
                break;
            case 2:
                
                break;
                
            case 3:
                [[NSManagedObjectContext MR_defaultContext] deleteObject:model];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                [[NSFileManager defaultManager] removeItemAtPath:model.filePath error:nil];
                [self renameOfRecordNameLabel];
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
