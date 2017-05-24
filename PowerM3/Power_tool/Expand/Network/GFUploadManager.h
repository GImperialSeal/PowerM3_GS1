//
//  GFUploadManager.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/5/8.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFUploadManager : NSObject

+ (instancetype)manager;

// 上传视频 分片上传,每次上传1M
-(void)uploadVideoWithParameters:(NSDictionary *)parameters
                       VideoPath:(NSString *)videoPath
                       UrlString:(NSString *)urlString
                        complete:(dispatch_block_t)complete
                         failure:(dispatch_block_t)fail;
// 上传音频
-(void)uploadAudioWithParameters:(NSDictionary *)parameters
                       VideoPath:(NSString *)videoPath
                       UrlString:(NSString *)urlString
                        complete:(dispatch_block_t)complete
                         failure:(dispatch_block_t)fail;

// 上传图片  图片大小压缩过后不能超过2M,超过2M 图片也要分片上传
- (void)UploadPicturesWithURL:(NSString *)URL
                   parameters:(id)parameters
                       images:(NSArray *)images
                        scale:(CGFloat )scale
               UploadProgress:(uploadProgress)progress
                      success:(requestSuccess)success
                      failure:(requestFailure)failure;
@end
