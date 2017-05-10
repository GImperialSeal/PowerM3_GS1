//
//  Mp3Recorder.h
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;
@interface ImperialAudioUntil : NSObject

// 录音格式转换
@property (nonatomic, copy) dispatch_block_t beginConvert;
@property (nonatomic, copy) dispatch_block_t failRecord;
@property (nonatomic, copy) void(^endConvertWithData)(NSData *voiceData);
//更新音量值
@property (nonatomic, copy) void(^updateVolumeMeter)(float ret);
@property (nonatomic, copy) void(^durationTravel)(float duration);

- (void)startRecord;
- (void)pauseRecord;
- (void)resumeRecord;
- (void)stopRecord;
- (void)cancelRecord;

@end

@interface ImperialAudioPlayerUntil : NSObject

+ (ImperialAudioPlayerUntil *)sharePlayer;
-(void)playSongWithUrl:(NSString *)songUrl;
-(void)playSoundWithData:(NSData *)soundData;

@end



