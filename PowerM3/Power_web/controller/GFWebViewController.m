//
//  PowerM3Controller.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/5/28.
//  Copyright © 2016年 shPower. All rights reserved.

#import "GFWebViewController.h"
#import "GFWebViewSubViewController.h"
#import "GFJSExport.h"
#import "MJRefresh.h"
#import "GFLocationHelper.h"
#import "GFProgressView.h"
#import "HandleJSCommand.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "AppDelegate.h"
#import "GFWebViewController+Picker.h"
#import "GFPDFWebViewController.h"
#import "UIDevice+Extension.h"
#import "QRCodeViewController.h"
#import "GFDownloadManager.h"
@import AVFoundation;
@import AVKit;
#import "NSDictionary+Extension.h"
#import "NSString+Extension.h"
#import "GFCommonHelper.h"
@interface GFWebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) AVPlayerViewController *avPlayer;
@property (nonatomic,strong) NSMutableArray *videosArr;
@property (nonatomic,strong) NSString *webFunction;
@property (nonatomic,strong) GFProgressView *downloadVideos;
@property (nonatomic,strong) UIImageView *leftBarIcon;
@property (nonatomic,strong) GFLocationHelper *locationHelper;
@property (nonatomic,strong) QRCodeViewController *qrcode;
@property (nonatomic,strong) NSString *executeJSFunctionWhenClosedWebView;

@end



@implementation GFWebViewController{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotiFromMenuViewController:) name:@"reloadWebView" object:nil];
    
    if (self.executeJSFunctionWhenClosedWebView&&![self.executeJSFunctionWhenClosedWebView isEqualToString:@"undefined"]&&self.executeJSFunctionWhenClosedWebView.length) {
        NSInteger index = self.navigationController.viewControllers.count-1;
         GFWebViewSubViewController *subWeb = self.navigationController.viewControllers[index];
        
         BLog(@"妈呀😱: %@  index: %ld",subWeb,(long)index);
        
        
        [subWeb.context[_executeJSFunctionWhenClosedWebView] callWithArguments:@[@""]];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
   
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    [self showWebViewLoadPorgress];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];    
    [self webViewRefeshFooderOrHeader];
    
    [self setNavBarButtonItem];
    
}

- (void)setNavBarButtonItem{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - show webview  进度条
- (void)showWebViewLoadPorgress{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    self.webView.delegate = _progressProxy;
    
    CGFloat progressBarHeight = 2.f;
    CGRect barFrame = CGRectMake(0, 42, KW, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}



#pragma mark - 上啦 / 下拉 刷新
- (void)webViewRefeshFooderOrHeader{
    _webView.scrollView.mj_header.ignoredScrollViewContentInsetTop = 100;
    _webView.scrollView.mj_footer.ignoredScrollViewContentInsetBottom = 100;
    __weak typeof (self) weakself = self;
    _webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [GFCommonHelper validateCookieSessionidCompletion:^{
            [weakself.webView reload];
        }];
    }];
    _webView.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakself.webView stringByEvaluatingJavaScriptFromString:@"PowerM3AppCallBack.pagepullup()"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself.webView.scrollView.mj_footer endRefreshing];
        });
    }];
}

#pragma mark -- 刷新网页
- (void)receivedNotiFromMenuViewController:(NSNotification *)noti{
    self.navigationItem.title = noti.object;
    [self.webView reload];
}





#pragma mark - webview  delegate
//开始请求
- (void)webViewDidStartLoad:(UIWebView *)webView{
    BLog(@"开始加载网页");
}
//请求完成
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView.scrollView.mj_header endRefreshing];
    [_progressView setProgress:1 animated:YES];
    [self configJSContext:webView];
    
    if ([self isKindOfClass:[GFWebViewSubViewController class]]) {
        GFWebViewSubViewController *subWebView = (GFWebViewSubViewController *)self;
        if (subWebView.wizardDictionary) {
            [self.context[@"FirstLoad"] callWithArguments:@[subWebView.wizardDictionary[@"where"],subWebView.wizardDictionary[@"btnid"]]];
            
            BLog(@"btind--------->>");
        }
    }
       BLog(@"main web view  did  load ");

}
//请求失败
- (void)webView:(UIWebView*)webView  DidFailLoadWithError:(NSError*)error{
    
    BLog(@"-------------fail---------%@",error);

    
}

//将要发起请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    return YES;
}

#pragma mark - 执行js方法
- (void)configJSContext:(UIWebView *)webView{
    
    __weak typeof (self)weakSelf = self;
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exception){
        [JSContext currentContext].exception = exception;
        BLog(@"exception:%@",exception);
    };
    
    self.context[@"PowerM3AppCall"]=^(NSString *order,NSString *parameter,NSString *function,NSString *more){
        BLog(@"----------------------order: %@ \nparameter: %@ \nfunction:%@ \nmore: %@",order,parameter,function,more);
        JSValue *this = [JSContext currentThis];
        BLog(@"----------------------this: %@",this);
        NSError *err;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&err];
        weakSelf.handleJS = [[HandleJSCommand alloc]initWithJsonDict:jsonDic];
        weakSelf.handleJS.function = function;
        weakSelf.handleJS.context = [JSContext currentContext];
        weakSelf.executeJSFunctionWhenClosedWebView = more;

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf JS_OC:order parameter:jsonDic function:function parameterOfString:parameter];
        });
    };
}


#pragma mark - JS_OC
- (void)JS_OC:(NSString *)order parameter:(NSDictionary *)dic function:(NSString *)function parameterOfString:(NSString *)parameter_string{
    
    if ([order isEqualToString:@"appTakePhotos"]) {
        [self pickerWithEnum:GFImagePickerOperationCamera];// 拍照
    }else if ([order isEqualToString:@"appOpenVideosLibrary"]){
        // back : {'success':true, 'message':'', value:['url','url2']}
        [self pickerWithEnum:GFImagePickerOperationVideosLibrary];// 视频列表
        
        

    }else if ([order isEqualToString:@"appOpenImagesLibrary"]){
        //back: {result:''}
        [self pickerWithEnum:GFImagePickerOperationImagesLibrary];// 图片

    }else if ([order isEqualToString:@"appRecordVideos"]){
        [self pickerWithEnum:GFImagePickerOperationVideo];// 录像

    }else if ([order isEqualToString:@"appPlayVideos"]){
        [self downloadVideosWithDictionary:dic function:function];// 播放

    }else if ([order isEqualToString:@"appRecordAudio"]){
        // 录音
        [self openRecordWithDictionary:dic andJS:function];
    }else if ([order isEqualToString:@"appGPSLocation"]){// 定位
        // 定位
        __weak typeof (self) weakSelf = self;
        self.locationHelper.positionInformation = ^(CGFloat logintude,CGFloat latitude){
            [weakSelf.context[function] callWithArguments:@[@{@"success":@"",@"message":@"",@"value":@{@"logintude":@(logintude),@"latitude":@(latitude)}}]];
        };
        // back : {'success':true, message:'', value:{x:12,y:6}}
    }else if ([order isEqualToString:@"appFixNavBarTitle"]){// 修改导航title
        // 修改title
        //
        self.navigationItem.title = dic[@"title"];
        [_context[function] callWithArguments:@[@{@"success":@"",@"message":@"",@"value":@""}]];

    }else if ([order isEqualToString:@"appShowTabbar"]){// 显示 tabbar
        // 显示tabbar
        // back : {'success':true, message:'', value:''}

        self.tabBarController.tabBar.hidden = ![dic[@"enable"] boolValue];
        self.webView.scalesPageToFit = YES;
        [_context[function] callWithArguments:@[@{@"success":@"",@"message":@"",@"value":@""}]];

    }else if ([order isEqualToString:@"appEnablePulldown"]){// 下拉
        // 下拉
        // back : {'success':true, message:'', value:''}

        self.webView.scrollView.mj_footer.hidden = ![dic[@"enable"] boolValue];
        [_context[function] callWithArguments:@[@{@"success":@"",@"message":@"",@"value":@""}]];


    }else if ([order isEqualToString:@"appEnablePullup"]){// 上啦
        // 上啦
        // back : {'success':true, message:'', value:''}

        self.webView.scrollView.mj_header.hidden = ![dic[@"enable"] boolValue];
        [_context[function] callWithArguments:@[@{@"success":@"",@"message":@"",@"value":@""}]];


    }else if ([order isEqualToString:@"appOpenNewWebView"]){// 打卡new web
        
        // new web
        // back : {'success':true, message:'', value:''}
        
        //

        [self openNewWebViewWithOrder:order Parameter:dic function:function];

    }else if ([order isEqualToString:@"appCloseNewWebView"]){// 关闭 new web
        BLog(@"close  new   web   view");

        [self.navigationController popViewControllerAnimated:YES];
        
        NSInteger index = self.navigationController.viewControllers.count-1;
        GFWebViewSubViewController *subWeb = self.navigationController.viewControllers[index];
        
        if([dic[@"reload"] boolValue]){
            [subWeb.webView reload];
            BLog(@"刷新     web   view     ");
        }
        [subWeb.context[function] callWithArguments:@[parameter_string]];
    }else if ([order isEqualToString:@"appOpenWizard"]){
        [self openNewWebViewWithOrder:order Parameter:dic function:function];
    }else if ([order isEqualToString:@"appOpenQRCode"]){
        BLog(@"扫一扫");
        _qrcode = [[QRCodeViewController alloc]init];
        _qrcode.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:_qrcode animated:YES];
        __weak typeof(self)weakself = self;
        [_qrcode setDidFinishedScanedQRCode:^(NSString *resultstring) {
            [weakself.context[function] callWithArguments:@[resultstring]];
            [weakself.navigationController popViewControllerAnimated:YES];
        }];

    }else if ([order isEqualToString:@""]){
        
    }
}

// 打开新的网页
- (void)openNewWebViewWithOrder:(NSString *)order Parameter:(NSDictionary *)dic function:(NSString *)function{
    BOOL pullUp     =   ![dic[@"pullUp"] boolValue];
    BOOL pullDown   =   ![dic[@"pullDown"] boolValue];
    BOOL showTabbar =   ![dic[@"showTabbar"] boolValue];
    NSString *title =     dic[@"title"];
    NSString *url =   [NSString stringWithFormat:@"%@%@",POWERM3URL, dic[@"url"]];
    GFWebViewSubViewController *subWebView = [[GFWebViewSubViewController alloc]init];
    subWebView.title = title;
    [subWebView setValue:url forKey:@"url"];
    subWebView.webView.scrollView.mj_header.hidden = pullUp;
    subWebView.webView.scrollView.mj_footer.hidden = pullDown;
    subWebView.hidesBottomBarWhenPushed = showTabbar;
    if ([order isEqualToString:@"appOpenWizard"]) {
        subWebView.wizardDictionary = dic;
    }
    [self.navigationController pushViewController:subWebView animated:YES];
    
    //[_context evaluateScript:function];
   // [self.webView stringByEvaluatingJavaScriptFromString:function];
    
   
    [_context[function] callWithArguments:@[@{@"success":@"",@"message":@"",@"value":@""}]];

}

- (void)downloadPDFWithUrl:(NSString *)url{
    NSString *fileID = [[url componentsSeparatedByString:@"&"] lastObject];
    NSString *str = [NSString stringWithFormat:@"%@/PowerPlat/Control/File.ashx?action=topdf&_%@",POWERM3URL,fileID];
    BLog(@"str: %@",str);
    
    [[HSDownloadManager sharedInstance] downloadTaskWithUrl:str progress:nil downloadState:^(DownloadState state, NSError *error, NSURL *filePath) {
        if (filePath) {
            GFPDFWebViewController *pdf = [[GFPDFWebViewController alloc]init];
            [pdf setValue:filePath forKey:@"url"];
            BLog(@"%@",filePath);
            [self.navigationController pushViewController:pdf animated:YES];
        }
        
    }];
}

// 打开录音
- (void)openRecordWithDictionary:(NSDictionary *)dic andJS:(NSString *)function{
    UIStoryboard *stroyboard = (UIStoryboard *)[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[stroyboard instantiateViewControllerWithIdentifier:@"AudioRecord"] animated:YES];
}

// 下载视频
- (void)downloadVideosWithDictionary:(NSDictionary *)dic function:(NSString *)function{
    
    [GFAlertView showAlertWithTitle:@"提示" message:@"视频暂时不支持在线播放,您需要缓存到本地吗?" completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
        if(buttonIndex == 0){
            return ;
        }else{
            [self downloadMovieWithUrl:POWERSERVERFILEPATH(dic[@"fileid"])];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
}

- (void)downloadMovieWithUrl:(NSString *)url{
    __weak typeof(self) weakSelf = self;
    
    [[GFDownloadManager manager] downLoad:url progress:^(float progress) {
        weakSelf.navigationItem.titleView = weakSelf.downloadVideos;
        weakSelf.downloadVideos.progress = progress;

    } complete:^(NSURL *filePath) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
        playerVC.player = [AVPlayer playerWithURL:filePath];
        [playerVC.player play];
        [weakSelf presentViewController:playerVC animated:YES completion:^{}];
        weakSelf.navigationItem.titleView = nil;
        weakSelf.title = weakSelf.tabBarItem.title;
        weakSelf.downloadVideos.progress = 0;

    } failure:^(NSError *error) {
        NSLog(@"error: %@",error);
        weakSelf.downloadVideos.progress = 0;

    }];
}

- (void)commitJSFunction:(NSArray *)arguments{
    
    [_context evaluateScript:_webFunction];
    
    [_context[@"XXX"] callWithArguments:arguments];
    
}


#pragma Mark - getter

-(NSMutableArray *)videosArr{
    if (!_videosArr) return _videosArr = [NSMutableArray array];
    return _videosArr;
}

- (AVPlayerViewController *)avPlayer{
    if (!_avPlayer) {
    }
    return _avPlayer;
}

- (GFLocationHelper *)locationHelper{
    if (!_locationHelper) {
        _locationHelper = [[GFLocationHelper alloc]init];
    }
    return _locationHelper;
}


- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc]init];
        _webView.frame = self.view.bounds;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scalesPageToFit = YES;
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (GFProgressView *)downloadVideos{
    if (!_downloadVideos) {
        _downloadVideos = [[GFProgressView alloc]initWithFrame:CGRectMake(0, 0, 100, 10)];
    }
    return _downloadVideos;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    BLog(@":    %f",progress);
    [_progressView setProgress:progress animated:YES];
}



@end
