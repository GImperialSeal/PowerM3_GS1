//
//  GFDomainManager.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/2/23.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFDomainManager.h"
#import "NSString+Extension.h"
#import "UIImage+Alisa.h"

#define kCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#define kCahcesDirectory [kCachesPath stringByAppendingPathComponent:@"缓存文件"]
#define UserDefaults [NSUserDefaults standardUserDefaults]

@implementation GFDomainManager

+ (NSString *)cacheDirectory{
    return kCahcesDirectory;
}

+ (NSString *)cacheFilesWithName:(NSString *)fileName{
    if(![[NSFileManager defaultManager]fileExistsAtPath:kCahcesDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:kCahcesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [kCahcesDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}


+ (NSString *)cacheImagesWithUrl:(NSString *)url{
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:kCahcesDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:kCahcesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [kCahcesDirectory stringByAppendingPathComponent:[url MD5string]];
    return filePath;
}

+ (BOOL)existFileWithUrl:(NSString *)url{
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[self cacheImagesWithUrl:url]];
    return exist;

}

+ (void)deleteFileWithUrl:(NSString *)url{
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheImagesWithUrl:url] error:nil];
}

+ (NSInteger)fileSizeOfAllCachesFile{
    return [self fileSizeOfPath:kCahcesDirectory];
}

+ (NSInteger)fileSizeOfPath:(NSString *)filePath
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    // 判断是否为文件
    BOOL dir = NO;
    BOOL exists = [mgr fileExistsAtPath:filePath isDirectory:&dir];
    // 文件\文件夹不存在
    if (exists == NO) return 0;
    
    if (dir) { // self是一个文件夹
        // 遍历caches里面的所有内容 --- 直接和间接内容
        NSArray *subpaths = [mgr subpathsAtPath:filePath];
        NSInteger totalByteSize = 0;
        for (NSString *subpath in subpaths) {
            // 获得全路径
            NSString *fullSubpath = [filePath stringByAppendingPathComponent:subpath];
            // 判断是否为文件
            BOOL dir = NO;
            [mgr fileExistsAtPath:fullSubpath isDirectory:&dir];
            if (dir == NO) { // 文件
                totalByteSize += [[mgr attributesOfItemAtPath:fullSubpath error:nil][NSFileSize] integerValue];
            }
        }
        return totalByteSize;
    } else { // self是一个文件
        return [[mgr attributesOfItemAtPath:filePath error:nil][NSFileSize] integerValue];
    }
}


+ (BOOL)deleteAllCaches{
    NSError *error;
    BOOL finished = [[NSFileManager defaultManager] removeItemAtPath:kCahcesDirectory error:&error];
    BLog(@"error:  %@",error.description);
    return finished;
}

#pragma mark - * * * * * * * * * * * * * * File Manager * * * * * * * * * * * * * *

// 把对象归档存到沙盒里
+ (BOOL)saveObject:(id)object byFileName:(NSString *)fileName {
    NSString *path  = [self appendFilePath:fileName.MD5string];
    path = [path stringByAppendingString:@".archive"];
    BOOL success = [NSKeyedArchiver archiveRootObject:object toFile:path];
    return success;
    
}

// 通过文件名从沙盒中找到归档的对象
+ (id)getObjectByFileName:(NSString*)fileName {
    NSString *path  = [self appendFilePath:fileName.MD5string];
    path = [path stringByAppendingString:@".archive"];
    id obj =  [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return obj;
}

// 根据文件名删除沙盒中的文件
+ (void)removeObjectByFileName:(NSString *)fileName {
    NSString *path  = [self appendFilePath:fileName.MD5string];
    path = [path stringByAppendingString:@".archive"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (NSString *)appendFilename:(NSString *)fileName {
    
    // 1. 沙盒缓存路径
    NSString *cachesPath = kCachesPath;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachesPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachesPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return cachesPath;
}

// 拼接文件路径
+ (NSString *)appendFilePath:(NSString *)fileName {
    
    // 1. 沙盒缓存路径
    NSString *cachesPath = kCachesPath;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",cachesPath,fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return filePath;
}

#pragma mark - * * * * * * * * * * * * NSUserDefaults Manager * * * * * * * * * * * *

+(void)saveInMyLocalStoreForValue:(id)value atKey:(NSString *)key
{
    [UserDefaults setValue:value forKey:key];
    [UserDefaults synchronize];
}
+(id)getValueInMyLocalStoreForKey:(NSString *)key
{
    return [UserDefaults objectForKey:key];
}
+(void)DeleteValueInMyLocalStoreForKey:(NSString *)key
{
    [UserDefaults removeObjectForKey:key];
    [UserDefaults synchronize];
}


@end
