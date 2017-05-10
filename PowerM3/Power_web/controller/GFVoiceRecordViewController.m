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
#import "EMCDDeviceManager.h"
#import "GFDomainManager.h"
@interface GFVoiceRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    EMCDDeviceManager *manager;
     int persent;
     int seconds;
     int minutes;

}
@property (weak, nonatomic) IBOutlet UIImageView *volumeImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GFVoiceRecordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    manager = [EMCDDeviceManager sharedInstance];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd";
    self.dateLabel.text = [formatter stringFromDate:[NSDate date]];
    [self renamedRecordName];
}

- (void)renamedRecordName{
    NSUInteger a = [GFAudioRecordCoreDataModel MR_findAll].count+1;
    _recordNameLabel.text = [NSString stringWithFormat:@"新录音%lu",(unsigned long)a];
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

- (IBAction)playRecorder {
    
}
#pragma mark -----  录音
- (IBAction)startRecordOrPauseRecord:(UIButton *)sender {
    
    if (![manager isRecording]) {
        [self initTimer];
        [manager asyncStartRecordingWithFileName:_recordNameLabel.text completion:^(NSError *error) {
            [self timer];
        }];
    }
}

- (IBAction)stopRecorder {
    __weak typeof(self)weakself = self;
    [manager asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        [weakself initTimer];
        [weakself saveRecordingFile:recordPath duration:aDuration];
    }];
}

- (void)saveRecordingFile:(NSString *)recordPath  duration:(NSInteger)aDuration{
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
        [self renamedRecordName];
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSFileManager defaultManager] removeItemAtPath:recordPath error:nil];
        [self renamedRecordName];

    }];
    [alert addAction:delete];
    [alert addAction:save];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateVoicPeakpower) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}
- (void)initTimer{
    [_timer invalidate];
    persent = 0;
    seconds = 0;
    minutes = 0;
    _timer = nil;
}

- (void)updateVoicPeakpower{
    CGFloat peakPower = [manager emPeekRecorderVoiceMeter];
    BLog(@"peak:   %f, timtinterval:  %f",peakPower,_timer.timeInterval);
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
    self.volumeImageView.image = [UIImage imageNamed:imageName];
    
    persent++;
    //没过１００毫秒，就让秒＋１，然后让毫秒在归零
    if(persent==100){
        seconds++;
        persent = 0;
    }
    if (seconds == 60) {
        minutes++;
        seconds = 0;
    }
    //让不断变量的时间数据进行显示到label上面。
    _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",minutes,seconds, persent];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
