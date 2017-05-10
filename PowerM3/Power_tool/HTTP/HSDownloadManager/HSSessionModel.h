//
//  HSNSURLSession.h
//  HSDownloadManagerExample
//
//  Created by hans on 15/8/4.
//  Copyright © 2015年 hans. All rights reserved.
//





#import <UIKit/UIKit.h>
typedef enum {
    DownloadStateStart = 0,     /** 下载中 */
    DownloadStateSuspended,     /** 下载暂停 */
    DownloadStateCompleted,     /** 下载完成 */
    DownloadStateFailed         /** 下载失败 */
}DownloadState;

typedef void(^downloadStateBlock)(DownloadState state,NSError *error,NSURL *filePath);
typedef void(^downloadProgressBlock)(NSInteger byte,CGFloat progress);

@interface HSSessionModel : NSObject

/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;


@property (nonatomic, strong) NSDate *taskStartDate;
@property (nonatomic) NSInteger taskWillStartLength;

/** 下载地址 */
@property (nonatomic, copy) NSString *url;

/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;

/** 下载进度 */
@property (nonatomic, copy) downloadProgressBlock progressBlock;

/** 下载状态 */
@property (nonatomic, copy) downloadStateBlock stateBlock;


@end
