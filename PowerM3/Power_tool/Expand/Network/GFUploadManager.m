//
//  GFUploadManager.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/5/8.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFUploadManager.h"
#import "GFAlertView.h"
@import AFNetworking;

@interface GFUploadManager ()

@property (nonatomic, strong) NSMutableArray *failures;

@end
@implementation GFUploadManager


static AFHTTPSessionManager *manager = nil;
+ (instancetype)manager{
    static dispatch_once_t onceToken;
    static GFUploadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}





static NSInteger _length; // 文件长度
static NSInteger _offset; // 每次上传的大小 默认为1M
static NSInteger _retry;  // 上传失败重试次数
static NSInteger _chunks; // 分片 数量
static NSString *_url;    // 地址
static NSString *_path;   // 文件路径
static NSDictionary *_parameters;

#pragma mark - 视频上传 (单线程)
-(void)uploadVideoWithParameters:(NSDictionary *)parameters
                       VideoPath:(NSString *)videoPath
                       UrlString:(NSString *)urlString
                        complete:(dispatch_block_t)complete
                         failure:(dispatch_block_t)fail{
    manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:POWERM3URL]];
    _length = [[[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil][NSFileSize]integerValue];
    _url = urlString;
    _path = videoPath;
    _parameters = parameters;
    _offset = 1024*1024;
    _chunks = _length%_offset == 0 ?_length/_offset  : _length/_offset +1;
    _retry = 0;
    [self uploadVideoWithChunk:0 completion:complete failure:fail];
}

// 分段读取文件
- (NSData *)dataWithChunk:(NSInteger)chunk{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:_path];
    [handle seekToFileOffset:_offset*chunk];
    NSData *data = [handle readDataOfLength:_offset];
    return data;
}

// 拼接参数
- (NSDictionary *)parametersWithChunk:(NSInteger )chunk{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_parameters];
    if (chunk != _chunks - 1) {
        [dic setObject:@(_offset*chunk+_offset) forKey:@"_end"];
    }else{
        [dic setObject:@(_length) forKey:@"_end"];
    }
    [dic setObject:@(_offset * chunk) forKey:@"_start"];
    [dic setObject:@(_length) forKey:@"_total"];
    [dic setObject:@"upload" forKey:@"action"];
    return dic;
}

// 上传
- (void)uploadVideoWithChunk:(NSInteger)chunk completion:(dispatch_block_t)complete failure:(dispatch_block_t)fail{
    NSDictionary *dic = [self parametersWithChunk:chunk];
    NSData *data = [self dataWithChunk:chunk];
    [manager POST:_url parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //获得沙盒中的视频内容
        [formData appendPartWithFileData:data name:@"fileData" fileName:[NSString stringWithFormat:@"%@.mp4",[self randomString]] mimeType:@"application/octet-stream"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        if([responseObject[@"success"] boolValue]){
            if (chunk+1<_chunks) {
                [self uploadVideoWithChunk:chunk+1 completion:complete failure:fail];
            }else{
                // 上传成功 删除沙盒文件
                [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
                if(complete)complete();
            }
        }else{
            if (_retry <= 3) {
                [self uploadVideoWithChunk:chunk completion:complete failure:fail];
            }else{
                // 默认重试 3次 超过3次 上传失败
                if (fail)fail();
            }
            _retry ++;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail)fail();
    }];
}


#pragma mark - 图片上传 --- 支持多选
- (void)UploadPicturesWithURL:(NSString *)URL
                   parameters:(id)parameters
                       images:(NSArray *)images
                        scale:(CGFloat )scale
               UploadProgress:(uploadProgress)progress
                      success:(requestSuccess)success
                      failure:(requestFailure)failure{
    
    manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:POWERM3URL]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dic setObject:@"upload" forKey:@"action"];

    [manager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSUInteger i = 0 ;
        /**出于性能考虑,将上传图片进行压缩*/
        for (UIImage * image in images) {
            //image设置指定宽度
           // UIImage *  resizedImage =  [UIImage IMGCompressed:image targetWidth:width];
            NSData * imgData = UIImageJPEGRepresentation(image, .5);
            [formData appendPartWithFileData:imgData name:@"FileData" fileName:[NSString stringWithFormat:@"%@.png",[self randomString]] mimeType:@"image/jpeg"];
            i++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}




- (NSString *)randomString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy_MM_dd_hh_mm_ss"];
    return [formatter stringFromDate:[NSDate date]];
}


#pragma mark - get func
- (NSMutableArray *)failures{
    if (!_failures) {
        _failures = [NSMutableArray arrayWithCapacity:50];
    }
    return _failures;
}



#pragma mark - 多线程 上传  (__deprecated)
- (void)startTaskComplete:(dispatch_block_t)complete{
    __weak typeof(self) weakself = self;
    // GCD group 队列控制上传任务
    dispatch_group_t group = dispatch_group_create();
    for (int chunk = 0 ; chunk<_chunks ; chunk++) {
        dispatch_group_enter(group);
        NSDictionary *dic = [self parametersWithChunk:chunk];
        [weakself uploadWithParameters:dic data:[weakself dataWithChunk:chunk] group:group failure:^(NSURLSessionDataTask *task, NSError *error) {
            BLog(@"上传失败 chunk: %d",chunk);
            // 处理上传失败的回调
            [weakself.failures addObject:@(chunk)];
        }];
    }
    //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (weakself.failures.count) {
            [weakself retry];
        }else{
            
        }
        complete();
    });
    
}

- (void)uploadWithParameters:(NSDictionary *)dic data:(NSData *)data group:(dispatch_group_t)group failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    [manager POST:_url parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //获得沙盒中的视频内容
        [formData appendPartWithFileData:data name:@"fileData" fileName:[NSString stringWithFormat:@"%@.mp4",[self randomString]] mimeType:@"application/octet-stream"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        // model.progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        if([responseObject[@"success"] boolValue]){
            NSLog(@" 888888888888 -------- success");
            
        }else{
            NSLog(@" error -------- msg : %@",responseObject[@"message"]);
            if (failure) {
                failure(task,nil);
            }
        }
        dispatch_group_leave(group);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,nil);
        }
        NSLog(@" error -------- fairlure: %@",error.description);
        
        dispatch_group_leave(group);
        
    }];
    
}


- (void)retry{
    __weak typeof(self) weakself = self;
    [GFAlertView showAlertWithTitle:@"" message:@"视频上传失败" completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
        if (buttonIndex == 1) {
            NSArray *chunks = weakself.failures.copy;
            [weakself.failures removeAllObjects];
            dispatch_group_t group = dispatch_group_create();
            NSLog(@"chunks: %lu",(unsigned long)chunks.count);
            for (NSNumber *chunk in chunks) {
                
                dispatch_group_enter(group);
                NSDictionary *dic = [self parametersWithChunk:chunk.integerValue];
                [weakself uploadWithParameters:dic data:[weakself dataWithChunk:chunk.integerValue] group:group failure:^(NSURLSessionDataTask *task, NSError *error) {
                    // 处理上传失败的回调
                    [weakself.failures addObject:@(chunk.integerValue)];
                }];
            }
            //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (weakself.failures.count) {
                    BLog(@"上传失败");
                    [weakself retry];
                }else{
                    BLog(@"上传成功");
                }
            });
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"重试",nil];
}


#pragma mark - 合并文件
- (void)aaaaaaaaaa{
    NSLog(@"%@",NSHomeDirectory());
    
    // 合并文件路径
    NSString *outputFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/combine.mp4"];
    
    // 创建合并文件
    [[NSFileManager defaultManager] createFileAtPath:outputFilePath contents:nil attributes:nil];
    
    // 创建filehandle
    NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:outputFilePath];
    
    // 循环写入数据
    
    for (int i = 0 ;i <_chunks; i++) {
        
        NSString *name = [NSString stringWithFormat:@"Documents/%ld.mp4",(long)i];
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:name];
        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path]; // 创建读取handle
        NSData *readData = [readHandle readDataToEndOfFile]; // 读出数据
        [writeHandle writeData:readData]; // 写到新文件中
        [readHandle closeFile]; // 关闭读取文件
    }
    
    // 关闭文件
    [writeHandle closeFile];
    
    BLog(@"合并完成: *********");
}



@end
