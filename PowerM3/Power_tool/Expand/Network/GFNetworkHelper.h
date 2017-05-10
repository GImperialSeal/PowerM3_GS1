//
//  NetWorkManager.h
//  BasicFramework
//
//  Created by Rainy on 16/10/26.
//  Copyright © 2016年 Rainy. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
typedef NS_ENUM(NSUInteger, NetworkStatusType) {
    /** 未知网络*/
    NetworkStatusUnknown,
    /** 无网络*/
    NetworkStatusNotReachable,
    /** 手机网络*/
    NetworkStatusReachableViaWWAN,
    /** WIFI网络*/
    NetworkStatusReachableViaWiFi
};


/**定义请求成功的block*/
typedef void(^requestSuccess)(id responseObject);
/**定义请求失败的block*/
typedef void(^requestFailure)( NSError *error);
/**定义上传进度block*/
typedef void(^uploadProgress)(float progress);
/**定义下载进度block*/
typedef void(^downloadProgress)(float progress);

typedef void(^networkStatus)(NetworkStatusType status);

@interface GFNetworkHelper : AFHTTPSessionManager


+ (instancetype)sharedInstance;


+ (void)POST:(NSString *)url parameters:(NSDictionary *)parameters success:(requestSuccess)completion failure:(requestFailure)failure;

+ (void)GET:(NSString *)url parameters:(NSDictionary *)parameters success:(requestSuccess)completion failure:(requestFailure)failure;

+ (void)SynchronizationForRequestType:(NSString *)RequestType
                                  URL:(NSString *)URL
                           parameters:(NSString *)parametersStr
                              success:(void(^)(id response,id data,NSError *error))success;
/**
 *  上传图片
 *
 *  @param parameters  上传图片预留参数---视具体情况而定 可移除
 *  @param images      上传的图片数组
 *  @param width       图片要被压缩到的宽度
 *  @param URL   上传的url
 *  @param success     上传成功的回调
 *  @param failure     上传失败的回调
 *  @param progress    上传进度
 */
+(void)UploadPicturesWithURL:(NSString *)URL
                  parameters:(id)parameters
                      images:(NSArray *)images
                 targetWidth:(CGFloat )width
              UploadProgress:(uploadProgress)progress
                     success:(requestSuccess)success
                     failure:(requestFailure)failure;
/**
 *  视频上传
 *
 *  @param parameters   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString    上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 */
+(void)uploadVideoWithParameters:(NSDictionary *)parameters
                       VideoPath:(NSString *)videoPath
                       UrlString:(NSString *)urlString
                  UploadProgress:(uploadProgress)progress
                    SuccessBlock:(requestSuccess)successBlock
                    FailureBlock:(requestFailure)failureBlock;





/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的url
 */
+(void)cancelHttpRequestWithRequestType:(NSString *)requestType
                       requestUrlString:(NSString *)string;
/**
 *  取消所有的网络请求
 */
+(void)cancelAllRequest;



/**
 有网YES, 无网:NO
 */
+ (BOOL)isNetwork;

/**
 手机网络:YES, 反之:NO
 */
+ (BOOL)isWWANNetwork;

/**
 WiFi网络:YES, 反之:NO
 */
+ (BOOL)isWiFiNetwork;


/**
 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
 */
+ (void)networkStatusWithBlock:(networkStatus)networkStatus;



/**
 配置自建证书的Https请求, 参考链接: http://blog.csdn.net/syg90178aw/article/details/52839103
 
 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO; 即服务器使用其他可信任机构颁发
 的证书，也可以建立连接，这个非常危险, 建议打开.validatesDomainName=NO, 主要用于这种情况:客户端请求的是子域名, 而证书上的是另外
 一个域名。因为SSL证书上的域名是独立的,假如证书上注册的域名是www.google.com, 那么mail.google.com是无法验证通过的.
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;

@end
