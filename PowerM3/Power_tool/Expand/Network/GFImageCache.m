//
//  GFImageCache.m
//  09-多图片多线程下载
//
//  Created by 顾玉玺 on 2017/4/26.
//  Copyright © 2017年 tengfei. All rights reserved.
//

#import "GFImageCache.h"
#import "GFDownloadManager.h"

@interface GFImageCache ()

@property (nonatomic, strong) NSMutableDictionary *caches;

@end
@implementation GFImageCache

+ (instancetype)shareCache{
    static dispatch_once_t onceToken;
    static GFImageCache *shareCache;
    dispatch_once(&onceToken, ^{
        shareCache = [[self alloc]init];
        
    });
    return shareCache;
}


- (NSMutableDictionary *)caches{
    if (!_caches) {
        _caches = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    return _caches;
}

+ (void)downLoad:(NSString *)url complete:(void(^)(UIImage *image))block{
    [[GFImageCache shareCache] downLoad:url complete:block];
}

- (void)downLoad:(NSString *)url complete:(void(^)(UIImage *image))block{
    __weak typeof(self)weakself = self;
    if (_caches[url]) {
        block(_caches[url]);
    }else{
        [[GFDownloadManager manager] downLoad:url progress:nil complete:^(NSURL *filePath) {
            NSData *data = [NSData dataWithContentsOfURL:filePath];
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [weakself.caches setObject:image forKey:url];
                block(image);
            }
        } failure:^(NSError *error) {
            
        }];
    }
}
@end
