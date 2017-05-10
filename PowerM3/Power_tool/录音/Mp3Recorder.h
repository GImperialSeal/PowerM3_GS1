//
//  Mp3Recorder.h
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@protocol Mp3RecorderDelegate <NSObject>
@optional
- (void)failRecord;
- (void)beginConvert;
@required
- (void)endConvertWithData:(NSData *)voiceData;
@end

@interface Mp3Recorder : NSObject
@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, weak) id<Mp3RecorderDelegate> delegate;

- (id)initWithDelegate:(id<Mp3RecorderDelegate>)delegate;
- (void)startRecord;
- (void)stopRecord;
- (void)cancelRecord;

@end
