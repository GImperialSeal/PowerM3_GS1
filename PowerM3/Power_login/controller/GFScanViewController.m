//
//
//
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "GFScanViewController.h"
#import "LBXScanResult.h"
#import "LBXScanWrapper.h"
#import "LBXScanVideoZoomView.h"

#import "PureLayout.h"

#define NavHeight 64
@interface GFScanViewController (){
    BOOL _showNavBar;
}
@property (nonatomic, strong) LBXScanVideoZoomView *zoomView;

@property (nonatomic, copy) void(^scanedResult)(NSString *resultString);

@end

@implementation GFScanViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.style = [self qrCodeSettings];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = _showNavBar;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = YES;
    }else{
        _showNavBar = YES;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [self drawBottomItems];
     [self drawTitle];
     [self.view bringSubviewToFront:_topTitle];
  
}

//绘制扫描区域
- (void)drawTitle{
    if (!_topTitle)
    {
        self.topTitle = [UILabel newAutoLayoutView];
        
        if ([UIScreen mainScreen].bounds.size.height <= 568 ){
            _topTitle.font = [UIFont systemFontOfSize:14];
        }
        
        _topTitle.textAlignment = NSTextAlignmentCenter;
        _topTitle.numberOfLines = 0;
        _topTitle.text = @"将取景框对准二维码即可自动扫描";
        _topTitle.textColor = [UIColor whiteColor];
        [self.view addSubview:_topTitle];
        
        [_topTitle autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_topTitle autoSetDimension:ALDimensionWidth toSize:145];
        [_topTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:84];

    }
}

- (void)cameraInitOver{
    [self zoomView];

}

- (LBXScanVideoZoomView *)zoomView{
    if (!_zoomView)
    {
      
        CGRect frame = self.view.frame;
        
        int XRetangleLeft = self.style.xScanRetangleOffset;
        
        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
        
        if (self.style.whRatio != 1)
        {
            CGFloat w = sizeRetangle.width;
            CGFloat h = w / self.style.whRatio;
            
            NSInteger hInt = (NSInteger)h;
            h  = hInt;
            
            sizeRetangle = CGSizeMake(w, h);
        }
        
        CGFloat videoMaxScale = [self.scanObj getVideoMaxScale];
        
        //扫码区域Y轴最小坐标
        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
        CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
        
        CGFloat zoomw = sizeRetangle.width + 40;
        _zoomView = [[LBXScanVideoZoomView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-zoomw)/2, YMaxRetangle + 40, zoomw, 18)];
        
        [_zoomView setMaximunValue:videoMaxScale/4];
        
        
        __weak __typeof(self) weakSelf = self;
        _zoomView.block= ^(float value)
        {            
            [weakSelf.scanObj setVideoScale:value];
        };
        [self.view addSubview:_zoomView];
                
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [self.view addGestureRecognizer:tap];
    }
    
    return _zoomView;
   
}

- (void)tap
{
    _zoomView.hidden = !_zoomView.hidden;
}

- (void)drawBottomItems
{
    if (_bottomItemsView) {
        
        return;
    }
    
    self.bottomItemsView = [UIView newAutoLayoutView];
    [self.view addSubview:_bottomItemsView];
    
    UIView *view = [UIView newAutoLayoutView];
    [self.bottomItemsView addSubview:view];
    
    self.btnFlash = [UIButton newAutoLayoutView];
     [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    [_bottomItemsView addSubview:_btnFlash];

    
    self.btnPhoto = [UIButton newAutoLayoutView];
    [_btnPhoto setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
    [_btnPhoto setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_down"] forState:UIControlStateHighlighted];
    [_btnPhoto addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    [_bottomItemsView addSubview:_btnPhoto];
    
    
    [_bottomItemsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [_bottomItemsView autoSetDimension:ALDimensionHeight toSize:100];
    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    [view autoSetDimensionsToSize:CGSizeMake(10, 100)];
    [view autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [view autoAlignAxisToSuperviewAxis:ALAxisVertical];

    
    [_btnFlash autoSetDimensionsToSize:CGSizeMake(65, 87)];
    [_btnFlash autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_btnFlash autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:view];
    
    
    [_btnPhoto autoSetDimensionsToSize:CGSizeMake(65, 87)];
    [_btnPhoto autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_btnPhoto autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:view];

    
    
    // 自定义一个导航条
    UIView *navBackView = [UIView newAutoLayoutView];
    navBackView.backgroundColor = [UIColor blackColor];
    navBackView.alpha = 0.6;
    [self.view addSubview:navBackView];
    [self.view bringSubviewToFront:navBackView];
    
    
    [navBackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [navBackView autoSetDimension:ALDimensionHeight toSize:64];
    
    
    UIButton *backButton = [UIButton newAutoLayoutView];
    [backButton setBackgroundImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navBackView addSubview:backButton];
    
    [backButton autoSetDimensionsToSize:CGSizeMake(30, 30)];
    [backButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12];
    [backButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
}







- (void)showError:(NSString*)str{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str chooseBlock:nil buttonsStatement:@"知道了",nil];
}



- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    
    if (array.count < 1)
    {
        [self popAlertMsgWithScanResult:nil];
     
        return;
    }
     
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    
    if (!strResult) {
        
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //震动提醒
   // [LBXScanWrapper systemVibrate];
    //声音提醒
    [LBXScanWrapper systemSound];
    
    if  (self.scanedResult)self.scanedResult(scanResult.strScanned);
}

- (void)popAlertMsgWithScanResult:(NSString*)strResult{
    if (!strResult) {
        
        strResult = @"识别失败";
    }
    
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showAlertWithTitle:@"扫码内容" msg:strResult chooseBlock:^(NSInteger buttonIdx) {
        
        //点击完，继续扫码
        [weakSelf reStartDevice];
    } buttonsStatement:@"知道了",nil];
}

- (void)didScanQrCodeCompletion:(void (^)(NSString *))complete{
    self.scanedResult = complete;
}


#pragma mark -底部功能项
//打开相册
- (void)openPhoto
{
    if ([LBXScanWrapper isGetPhotoPermission])
        [self openLocalPhoto];
    else
    {
        [self showError:@"      请到设置->隐私中开启本程序相册权限     "];
    }
}

//开关闪光灯
- (void)openOrCloseFlash
{
    
    [super openOrCloseFlash];
   
    
    if (self.isOpenFlash)
    {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    }
    else
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
}


- (LBXScanViewStyle *)qrCodeSettings{
    //创建参数对象
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    
    //矩形区域中心上移，默认中心点为屏幕中心点
    style.centerUpOffset = 44;
    
    //扫码框周围4个角的类型,设置为外挂式
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    
    //扫码框周围4个角绘制的线条宽度
    style.photoframeLineW = 6;
    
    //扫码框周围4个角的宽度
    style.photoframeAngleW = 24;
    
    //扫码框周围4个角的高度
    style.photoframeAngleH = 24;
    
    //扫码框内 动画类型 --线条上下移动
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //线条上下移动图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];

    return style;
}



@end
