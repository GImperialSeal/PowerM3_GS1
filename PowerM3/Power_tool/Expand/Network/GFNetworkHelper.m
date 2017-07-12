//
//  NetWorkManager.h
//  BasicFramework
//
//  Created by Rainy on 16/10/26.
//  Copyright © 2016年 Rainy. All rights reserved.
//



#import "GFNetworkHelper.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>
#import "UIImage+Extension.h"
#define kTimeoutInterval  15
#define kNetworkHelper [GFNetworkHelper sharedInstance]


@interface GFNetworkHelper ()


@end


@implementation GFNetworkHelper
static GFNetworkHelper *network = nil;

+ (instancetype)sharedInstance{
    return [[self alloc]initWithBaseURL:[NSURL URLWithString:POWERM3URL]];
}
- (instancetype)initWithBaseURL:(NSURL *)url{
    if (self = [super initWithBaseURL:url]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy = securityPolicy;
        [self.responseSerializer willChangeValueForKey:@"timeoutInterval"];
        [self.requestSerializer setTimeoutInterval:kTimeoutInterval];
        [self.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",@"application/atom+xml",@"application/xml",@"text/xml", @"image/*"]];
        self.securityPolicy=[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        self.operationQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

+ (void)POST:(NSString *)url parameters:(NSDictionary *)parameters success:(requestSuccess)completion failure:(requestFailure)failure{
    //if (![self isNetwork]) return;
    [kNetworkHelper POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)GET:(NSString *)url parameters:(NSDictionary *)parameters success:(requestSuccess)completion failure:(requestFailure)failure{
    //if (![self isNetwork]) return;
    [kNetworkHelper GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion) {
            completion(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
    }];
}



/**
 同步请求
 */
+ (void)SynchronizationForRequestType:(NSString *)RequestType
                                 URL:(NSString *)URL
                          parameters:(NSString *)parametersStr
                             success:(void(^)(id response,id data,NSError *error))success{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"",URL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:RequestType];
    
    [request setValue:kVersion forHTTPHeaderField:@"version"];
    
    if (parametersStr) {
        
        NSData *data = [parametersStr dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPBody:data];
    }
    
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);
    
    NSURLSessionDataTask *dataTask =  [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        success (response,data,error);
        dispatch_semaphore_signal(disp);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
}

/**
 *  取消所有的网络请求
 */
+(void)cancelAllRequest
{
    [kNetworkHelper.operationQueue cancelAllOperations];
}
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的url
 */
+(void)cancelHttpRequestWithRequestType:(NSString *)requestType
                       requestUrlString:(NSString *)string{
    NSError * error;
    
    /**根据请求的类型 以及 请求的url创建一个NSMutableURLRequest---通过该url去匹配请求队列中是否有该url,如果有的话 那么就取消该请求*/
    
    NSString * urlToPeCanced = [[[kNetworkHelper.requestSerializer requestWithMethod:requestType URLString:string parameters:nil error:&error] URL] path];
    
    
    for (NSOperation * operation in kNetworkHelper.operationQueue.operations) {
        
        //如果是请求队列
        if ([operation isKindOfClass:[NSURLSessionTask class]]) {
            
            //请求的类型匹配
            BOOL hasMatchRequestType = [requestType isEqualToString:[[(NSURLSessionTask *)operation currentRequest] HTTPMethod]];
            
            //请求的url匹配
            
            BOOL hasMatchRequestUrlString = [urlToPeCanced isEqualToString:[[[(NSURLSessionTask *)operation currentRequest] URL] path]];
            
            //两项都匹配的话  取消该请求
            if (hasMatchRequestType&&hasMatchRequestUrlString) {
                [operation cancel];
            }
        }
        
    }
}

/**
 *  创建日期字符串防止重复命名
 */
+ (NSString *)randomString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    return [formatter stringFromDate:[NSDate date]];
}

+ (BOOL)isNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (BOOL)isWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

#pragma mark - 开始监听网络
+ (void)networkStatusWithBlock:(networkStatus)networkStatus {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus ? networkStatus(NetworkStatusUnknown) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                //[GFAlertView alertWithTitle:@"当前网络不可用, 请检查网络(权限)设置"];
                networkStatus ? networkStatus(NetworkStatusNotReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus ? networkStatus(NetworkStatusReachableViaWWAN) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus ? networkStatus(NetworkStatusReachableViaWiFi) : nil;
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName {
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [kNetworkHelper setSecurityPolicy:securityPolicy];
}


@end
