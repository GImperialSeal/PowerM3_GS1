//
//  Mp3Recorder.m
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "ImperialAudioUntil.h"
#import "lame.h"
@import AVFoundation;
@import UIKit;


@interface ImperialAudioUntil()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ImperialAudioUntil


#pragma mark - Public Methods

- (void)startRecord{
    [self.timer setFireDate:[NSDate distantPast]];
    [self.recorder record];
}

- (void)pauseRecord{
    [self.timer setFireDate:[NSDate distantFuture]];
    [_recorder pause];
}

- (void)resumeRecord{
    [self.timer setFireDate:[NSDate distantPast]];
    [_recorder record];
}

- (void)stopRecord{
    [self.timer setFireDate:[NSDate distantFuture]];
    double cTime = _recorder.currentTime;
    [_recorder stop];
    
    if (cTime > 1) {
        [self audio_PCMtoMP3];
    }else {
        
        [_recorder deleteRecording];
        
        if (self.failRecord) self.failRecord();
    }
}

- (void)cancelRecord{
    [self.timer invalidate];
    self.timer = nil;
    [_recorder stop];
    [_recorder deleteRecording];
}

-(void)updateAudioVolumeMeter{
    double ret = 0.0;
    
    if ([self.recorder isRecording]) {
        [self.recorder updateMeters];
        double lowpassResults = pow(10, (0.05 * [self.recorder  peakPowerForChannel:0]));
        ret = lowpassResults;
    }
    if (self.durationTravel) self.durationTravel(_recorder.currentTime);
    if (self.updateVolumeMeter) self.updateVolumeMeter(ret);
}




- (void)deleteMp3Cache{
    [self deleteFileWithPath:[self mp3Path]];
}

- (void)deleteCafCache{
    [self deleteFileWithPath:[self cafPath]];
}

- (void)deleteFileWithPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:path error:nil]){
        NSLog(@"删除以前的mp3文件");
    }
}

#pragma mark - Convert Utils
- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [self cafPath];
    NSString *mp3FilePath = [self mp3Path];
    
    // remove the old mp3 file
    [self deleteMp3Cache];

    NSLog(@"MP3转换开始");
    
    if (self.beginConvert)self.beginConvert();
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    }
    
    [self deleteCafCache];
    NSLog(@"MP3转换结束");
    
    if (self.endConvertWithData) self.endConvertWithData([NSData dataWithContentsOfFile:[self mp3Path]]);
}

#pragma mark - Path Utils
- (NSString *)cafPath{
    NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
    return cafPath;
}

- (NSString *)mp3Path{
    NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mp3.caf"];
    return mp3Path;
}


#pragma mark - get Methods

- (AVAudioRecorder *)recorder{
    if (_recorder) return _recorder;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    
    NSError *recorderSetupError = nil;
    NSURL *url = [NSURL fileURLWithPath:[self cafPath]];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url
                                            settings:settings
                                               error:&recorderSetupError];
    if (recorderSetupError) {
        NSLog(@"%@",recorderSetupError);
    }
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    [_recorder prepareToRecord];
    return _recorder;
};

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioVolumeMeter) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end

#pragma mark -
#pragma mark - 音频播放
@interface ImperialAudioPlayerUntil ()<AVAudioPlayerDelegate>

@property (nonatomic ,strong)  AVAudioPlayer *player;

@end

@implementation ImperialAudioPlayerUntil


+ (ImperialAudioPlayerUntil *)sharePlayer{
    
    static ImperialAudioPlayerUntil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(void)playSongWithUrl:(NSString *)songUrl{
    dispatch_async(dispatch_queue_create("playSoundFromUrl", NULL), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:songUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playSoundWithData:data];
        });
    });
}

-(void)playSongWithData:(NSData *)songData{
    [self setupPlaySound];
    [self playSoundWithData:songData];
}

-(void)playSoundWithData:(NSData *)soundData{
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:soundData error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    _player.delegate = self;
    [_player play];
}

-(void)setupPlaySound{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

- (void)stopSound
{
    if (_player && _player.isPlaying) {
        [_player stop];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
}


@end





