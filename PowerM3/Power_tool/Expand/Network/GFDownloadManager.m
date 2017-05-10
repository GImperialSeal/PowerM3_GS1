//
//  GFDownloadManager.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/4/26.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFDownloadManager.h"
#import "AFNetworking.h"



#define USERDEFAULT_DOWNLOAD_FILENAME_KEY(url) [NSString stringWithFormat:@"%@_Userdefault_FileName_Key",url]
@interface GFDownloadManager ()

@property (nonatomic, strong) NSMutableDictionary *tasks;

@end
@implementation GFDownloadManager

static AFHTTPSessionManager *manager = nil;
+ (instancetype)manager{
    static dispatch_once_t onceToken;
    static GFDownloadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        
        manager = [AFHTTPSessionManager manager];
    });
    return instance;
}

- (void)network{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                //WKNSLog(@"未知网络状态");
                break;
            case AFNetworkReachabilityStatusNotReachable:
               // WKNSLog(@"无网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //WKNSLog(@"蜂窝数据网");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
               // WKNSLog(@"WiFi网络");
                
                break;
                
            default:
                break;
        }
        
    }] ;
}

- (NSMutableDictionary *)tasks{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (void)pauseTask{
    [self.tasks performSelector:@selector(suspend)];
}

- (void)cancleAllTask{
    [self.tasks performSelector:@selector(cancel)];
}


- (void)downLoad:(NSString *)urlString progress:(downloadProgress)progress complete:(completionBlock)successBlock failure:(requestFailure)failureBlock{
    
    if (!urlString.length) {
        failureBlock(nil);
        return;
    }

    if (_tasks[urlString]) {
        return;
    }
    if ([self fileExist:urlString]) {
        if (successBlock)successBlock([self filePathWithUrl:urlString]);
        return;
    }
    
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] progress:^(NSProgress * _Nonnull downloadProgress) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            }
            
            // BLog(@"totalUnilldount: %lld",downloadProgress.totalUnitCount);
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:[self filePath:response.suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            
            if (failureBlock)failureBlock(error);
        }else{

            // 回调
            if (successBlock)successBlock(filePath);
            
            // 保存文件名
            [[NSUserDefaults standardUserDefaults] setObject:response.suggestedFilename forKey:USERDEFAULT_DOWNLOAD_FILENAME_KEY(urlString)];
        }
        
        [_tasks removeObjectForKey:urlString];
        
    }];
    
    [task resume];
    
    [self.tasks setObject:task forKey:urlString];
    
    NSLog(@"taskS: %lu",(unsigned long)manager.downloadTasks.count);
}



- (NSString *)filePath:(NSString *)name{
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *path = [cache stringByAppendingPathComponent:@"缓存文件"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:path]) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return [path stringByAppendingPathComponent:name];
}


- (NSURL *)filePathWithUrl:(NSString *)url{
    
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_DOWNLOAD_FILENAME_KEY(url)];
    
    return [NSURL fileURLWithPath:[self filePath:name]];

}
- (BOOL)fileExist:(NSString *)url{
    
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_DOWNLOAD_FILENAME_KEY(url)];
    
    if (name) {
        
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[self filePath:name]];
        
        if (!exist) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_DOWNLOAD_FILENAME_KEY(url)];
        }
        
        return exist;

    }else{
        return NO;
    }
}

@end
