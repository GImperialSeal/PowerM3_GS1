/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <Foundation/Foundation.h>
@import AVFoundation;


/**
 录音完成的回调
 @param path 录音路径
 @param duration 录音时长
 */
typedef void (^recordCompletion)(NSString *path,CGFloat duration);

/**
 录音 音量
 @param progress 音量
 @param duration 转换为秒 (1.0 * duration/10)
 */
typedef void (^audioPowerChange)(CGFloat progress,NSInteger duration);

@interface EMAudioRecorderUtil : NSObject

// 音量值变化
@property (nonatomic, copy) audioPowerChange audioPower;


// 单利
+ (instancetype)record;

// 当前是否正在录音
- (BOOL)isRecording;

// 开始录音
- (void)start;

// 停止录音
- (void)stop:(recordCompletion)complete;

// 暂停
- (void)pause;

// 继续
-(void)resume;

// 取消录音
- (void)cancle;

// 可以在录音暂停的时候, 播放/暂停 录制的声音
- (void)audioPlayOrPause;

@end
