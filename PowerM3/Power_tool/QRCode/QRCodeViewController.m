//
//  QRCodeController.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/5/26.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "QRCodeViewController.h"
#import "NextStepController.h"
@import AVFoundation;
@import Photos;
#import "PureLayout.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic,strong) UIView *checkbox;//扫描框
@property (nonatomic,strong) CALayer *checkline;//扫描线
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//预览图层
@property (nonatomic, strong) AVCaptureSession *session;
@end

#define KH       [[UIScreen mainScreen] bounds].size.height
#define KW       [[UIScreen mainScreen] bounds].size.width

#define checkboxCornerWidth  10 // 角线宽
#define cornerLineLength  20 // 角线长度

#define PingFangSCRegular(fontSize) [UIFont fontWithName:@"PingFang-SC-Regular" size:fontSize]

@implementation QRCodeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupAuthorization];// 授权
    [self setupUI];
    [self setupNavBar];
}

- (void)setupAuthorization{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setupQRCodeScanning];
                    });
                    
                } else {
                    
                    // 用户第一次拒绝了访问相机权限
                    BLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            [self setupQRCodeScanning];

        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"⚠️ 警告" message:@"请去-> [设置 - 隐私 - 相机] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            
        } else if (status == AVAuthorizationStatusRestricted) {
            BLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    } 

}
- (void)setupNavBar{

    self.fd_prefersNavigationBarHidden = YES;
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
    
    
    UIView *barView = [UIView newAutoLayoutView];
    barView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.view addSubview:barView];
    
    [barView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [barView autoSetDimension:ALDimensionHeight toSize:64];
    
    UILabel *title = [UILabel newAutoLayoutView];
    title.text = @"扫一扫";
    title.font = PingFangSCRegular(20);
    title.textColor = [UIColor whiteColor];
    [barView addSubview:title];
    [title autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:barView withOffset:-12];
    [title autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    
    UIButton *back = [UIButton newAutoLayoutView];
    [back setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:back];
    [back autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12];
    [back autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:12];
    
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI{
    CGFloat checkboxWidth = KW-120;
    CGFloat checkBorderWidth = 1;// 扫描框线宽
    CGFloat checkCornerX = (checkboxCornerWidth-checkBorderWidth)/2;// 扫描框角x坐标
    
    
    //扫描框
    UIView *checkbox = [[UIView alloc]init];
    checkbox.layer.borderColor = [UIColor whiteColor].CGColor;
    checkbox.frame = CGRectMake(0, 0, checkboxWidth, checkboxWidth);
    checkbox.center = self.view.center;
    checkbox.layer.borderWidth = checkBorderWidth;
    checkbox.tag = 1000;
    [self.view addSubview:checkbox];
    
    // 扫描框的 4个角
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(-checkCornerX,-checkCornerX,checkboxWidth + checkCornerX*2,checkboxWidth + checkCornerX*2 );
    UIImage *image = [self drawLine:checkboxWidth+20 and:checkboxWidth+20];
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    [checkbox.layer addSublayer:layer];
    
    // 扫描线
    CGFloat checklineX = CGRectGetMinX(checkbox.frame);
    CGFloat checklineY = CGRectGetMinY(checkbox.frame);
    UIImageView *checkline = [[UIImageView alloc]initWithFrame:CGRectMake(checklineX,checklineY, checkboxWidth, 15)];
    checkline.tag = 1001;
    checkline.image = [UIImage imageNamed:@"qrcode_scan_light_green"];
    [self.view addSubview:checkline];
    
    // 添加动画
    
    [self checklineAddAnimationOrRemoveAnimation:NO];

    // 遮罩
    CALayer *maskView = [[CALayer alloc]init];
    maskView.frame = self.view.bounds;
    maskView.contents = (__bridge id _Nullable)([self drawMaskView:KW and:KH].CGImage);
    [self.view.layer insertSublayer:maskView below:checkbox.layer];
    
    
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.text = @"将取景框对准二维码即\n可自动扫描";
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = PingFangSCRegular(12);
    [self.view addSubview:label];
    
    [label autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:checkbox withOffset:-20];
    [label autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.view addSubview:bottomView];
    [bottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
    [bottomView autoSetDimension:ALDimensionHeight toSize:100];
    
    
    
    UIButton *flashBtn = [[UIButton alloc]init];
    [bottomView addSubview:flashBtn];
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(openOrCloseFlash:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [flashBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:KW/2];
    [flashBtn autoSetDimensionsToSize:CGSizeMake(80, 107)];
    
    UIButton *photoBtn = [UIButton newAutoLayoutView];
    [photoBtn addTarget:self action:@selector(readQRImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];

    [bottomView addSubview:photoBtn];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
    [photoBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [photoBtn autoSetDimensionsToSize:CGSizeMake(80, 107)];
    [photoBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:KW/2];
}


/**
 扫描线添加动画

 @param remove bool yes 移除动画 no添加动画
 */
- (void)checklineAddAnimationOrRemoveAnimation:(BOOL)remove{
    
    NSString *key = @"chickLine_animation_key";
    UIView *checkbox  = [self.view viewWithTag:1000];
    UIView *checkline = [self.view viewWithTag:1001];
    if (remove) {
        [checkline.layer removeAnimationForKey:key];
    }else{
        // 基础动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:checkline.layer.position];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(checkline.layer.position.x,CGRectGetMaxY(checkbox.frame)-15)];
        animation.duration = 2;
        animation.repeatCount = HUGE_VALF;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [checkline.layer addAnimation:animation forKey:key];
    }
}


- (void)setupQRCodeScanning {
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 5.1 添加会话输入
    [_session addInput:input];
    
    // 5.2 添加会话输出
    [_session addOutput:output];
    
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    // 9、启动会话
    [_session startRunning];
}
#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 0、扫描成功之后的提示音
    [self SG_playSoundEffect:@"sound.caf"];
    
    // 1、如果扫描完成，停止会话
    [self.session stopRunning];
    
    [self checklineAddAnimationOrRemoveAnimation:YES];
    // 2、删除预览图层
    // [self.previewLayer removeFromSuperlayer];
    
    // 3、设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        BLog(@"qrcode:    %@",obj.stringValue);
        if (self.didFinishedScanedQRCode) {
            self.didFinishedScanedQRCode(obj.stringValue);
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - - - 播放音频文件
- (void)SG_playSoundEffect:(NSString *)name {
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
/** 播放完成回调函数 */
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    BLog(@"播放完成...");
}

#pragma mark - - - 开启闪光灯
- (void)openOrCloseFlash:(UIButton *)btn{
    btn.selected = !btn.selected;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        
        [device lockForConfiguration:nil];
        if (btn.selected) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}



#pragma mark - - - 从相册中识别二维码, 并进行界面跳转
- (void)readQRImageFromAlbum:(UIButton *)btn{
    
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户第一次同意了访问相册权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
                        imagePicker.delegate = self;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                    });
                } else { // 用户第一次拒绝了访问相机权限
                    
                }
            }];
            
        } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"⚠️ 警告" message:@"请去-> [设置 - 隐私 - 照片 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        } else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }
}
#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - - 从相册中识别二维码, 并进行界面跳转
- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    
    [MBProgressHUD showMessag:@"正在处理..." toView:self.view];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count>0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        CIQRCodeFeature *feature = features.firstObject;
        
        if (self.didFinishedScanedQRCode) {
            self.didFinishedScanedQRCode(feature.messageString);
        }
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"未发现二维码/条形码" toView:self.view];
        
    }
}


//TODO:绘制扫描线
-(UIImage *)drawLinarGradient:(CGFloat )width and:(CGFloat )height{
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.创建一个渐变
    //2.1 创建一个颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //2.2 设置颜色
    //颜色分量的强度值的数组
    id clearColor = (__bridge id) [UIColor clearColor].CGColor;
    id blackColor = (__bridge id) [UIColor whiteColor].CGColor;
    
    CGFloat locations[] = {0.0f,0.5f,1.0f};
    NSArray *colors = @[clearColor, blackColor,clearColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        (__bridge CFArrayRef)colors,
                                                        locations);    //渐变系数(程度)
    //3.在上下文中画渐变(参数：上下文、颜色空间、开始点、结束点、渐变模式,默认为0)
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0,15),0);
    //4.对creat创建的对象必须清理(避免内存泄露)
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    UIImage *maskImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return maskImage;
    
}

//TODO:绘制扫描框  4个角
- (UIImage *)drawLine:(CGFloat )width and:(CGFloat )height
{
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0/255.0,167/255.0,231/255.0, 1);
    CGContextSetLineWidth(context,checkboxCornerWidth);
    
    CGContextMoveToPoint(context,0,cornerLineLength);
    CGContextAddLineToPoint(context,0,0);
    CGContextAddLineToPoint(context,cornerLineLength,0);
    
    CGContextMoveToPoint(context,width-cornerLineLength,0);
    CGContextAddLineToPoint(context,width,0);
    CGContextAddLineToPoint(context,width,cornerLineLength);
    
    CGContextMoveToPoint(context,0,height-cornerLineLength);
    CGContextAddLineToPoint(context,0,height);
    CGContextAddLineToPoint(context,cornerLineLength,height);
    
    CGContextMoveToPoint(context,width-cornerLineLength,height);
    CGContextAddLineToPoint(context,width,height);
    CGContextAddLineToPoint(context,width,height-cornerLineLength);
    
    CGContextStrokePath(context);
    UIImage *lineImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lineImage;
    
}

//TODO: 遮罩
- (UIImage *)drawMaskView:(CGFloat)width and:(CGFloat)height{
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 0, 0, 0,0.4);
    CGContextFillRect(context, self.view.bounds);
    CGContextClearRect(context, [self.view viewWithTag:1000].frame);
    UIImage *maskimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return maskimage;
}



@end
