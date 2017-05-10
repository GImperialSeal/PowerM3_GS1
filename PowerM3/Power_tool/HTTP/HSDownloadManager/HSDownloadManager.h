//
//  HSDownloadManager.h
//  HSDownloadManagerExample
//
//  Created by hans on 15/8/4.
//  Copyright © 2015年 hans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSSessionModel.h"

@interface HSDownloadManager : NSObject

/**
 *  单例
 *
 *  @return 返回单例对象
 */
+ (instancetype)sharedInstance;


/**
 下载
 @param url ip
 @param downloadProgressBlock byte 速度默认kb progress 百分比
 @param downloadStateBlock done
 */
- (void)downloadTaskWithUrl:(NSString *)url
                   progress:(downloadProgressBlock)downloadProgressBlock
              downloadState:(downloadStateBlock)downloadStateBlock;
/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;


/**
 文件地址

 @param url 下载地址
 @return 路径
 */
- (NSString *)filePath:(NSString *)url;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;

@end
