//
//  GFDomainManager.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/2/23.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFDomainManager : NSObject

+ (NSString *)cacheImagesWithUrl:(NSString *)url;
+ (NSString *)cacheFilesWithName:(NSString *)fileName;


+ (NSString *)cacheDirectory;

+ (BOOL)existFileWithUrl:(NSString *)url;


+ (void)deleteFileWithUrl:(NSString *)url;


+ (BOOL)deleteAllCaches;

+ (NSInteger)fileSizeOfAllCachesFile;

//   获取本地文件内容的大小
+ (NSInteger)fileSizeOfPath:(NSString *)filePath;

+ (NSString *)appendFilePath:(NSString *)fileName ;

#pragma mark - * * * * * * * * * * * * * * File Manager * * * * * * * * * * * * * *

/**
 *  把对象归档存到沙盒里Cache路径下  filename 默认用md5加密 防止名字不合法
 */
+ (BOOL)saveObject:(id)object byFileName:(NSString*)fileName;

/**
 *  通过文件名从沙盒中找到归档的对象
 */
+ (id)getObjectByFileName:(NSString*)fileName;

/**
 *  根据文件名删除沙盒中的归档对象
 */
+ (void)removeObjectByFileName:(NSString*)fileName;

#pragma mark - * * * * * * * * * * * * NSUserDefaults Manager * * * * * * * * * * * *

/**
 *  存储value
 */
+(void)saveInMyLocalStoreForValue:(id)value atKey:(NSString *)key;
/**
 *  获取value
 */
+(id)getValueInMyLocalStoreForKey:(NSString *)key;
/**
 *  删除value
 */
+(void)DeleteValueInMyLocalStoreForKey:(NSString *)key;

@end
