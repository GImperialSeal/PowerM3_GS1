//
//  GFDownloadManager.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/4/26.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^completionBlock)(NSURL *filePath);
/**定义请求失败的block*/
typedef void(^requestFailure)(NSError *error);
/**定义下载进度block*/
typedef void(^downloadProgress)(float progress);

@interface GFDownloadManager : NSObject

+ (instancetype)manager;

- (void)downLoad:(NSString *)urlString progress:(downloadProgress)progress complete:(completionBlock)successBlock failure:(requestFailure)failureBlock;

- (NSURL *)filePathWithUrl:(NSString *)url;



@end
