//
//  ViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/3.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFLoginViewController.h"
#import "PowerM3TextField.h"
#import "NextStepController.h"
#import "PureLayout.h"
#import "NSString+Extension.h"
#import "QRCodeViewController.h"
@interface GFLoginViewController ()
{
    UIButton *_goButton;
}
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UIImageView *scancodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *copyedLabel;

@end

@implementation GFLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

}
- (void)viewDidLoad{
    [super viewDidLoad];
    UIButton *go = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, CGRectGetHeight(_websiteTextField.frame))];
    [go setTitle:@"GO" forState:UIControlStateNormal];
    [go addTarget:self action:@selector(wentToNextView) forControlEvents:UIControlEventTouchUpInside];
    _goButton = go;
    _goButton.backgroundColor = GFThemeColor;
    _websiteTextField.rightView = go;
    _websiteTextField.rightViewMode = UITextFieldViewModeAlways;
    self.copyedLabel.text = @"2017 © 上海普华科技发展股份有限公司";
    _websiteTextField.text = POWERM3URL?POWERM3URL:@"dev.p3china.com:9508";
    self.websiteTextField.placeholder = @"web service address";
    //_websiteTextField.text = @"192.168.0.47:8088";
    
  }

#pragma mark - click 方法   __  go 登录页面
- (void)wentToNextView{
    if([_websiteTextField.text isEmpty]){
        [GFAlertView alertWithTitle:@"请配置服务器站点"];
    }else{
        [self performSegueWithIdentifier:@"showNextStepController" sender:nil];
        if (![_websiteTextField.text hasPrefix:@"http://"]&&![_websiteTextField.text hasPrefix:@"https://"]) {
            NSString *url = [@"http://" stringByAppendingString:_websiteTextField.text];
            [GFUserDefault setObject:url forKey:PowerOnWebsiteUserDefaultKey];
        }else{
            [GFUserDefault setObject:_websiteTextField.text forKey:PowerOnWebsiteUserDefaultKey];
        }
    }
}

//TODO:扫一扫
- (IBAction)scanQRCode:(UIButton *)sender{
    //添加一些扫码或相册结果处理
    QRCodeViewController *_qrCode = [QRCodeViewController new];
    [self.navigationController pushViewController:_qrCode animated:YES];
    __weak typeof(self)weakself = self;
    [_qrCode setDidFinishedScanedQRCode:^(NSString *resultString) {
        [weakself.navigationController pushViewController:MAINSTORYBOARD(@"NextStepController") animated:YES];
        [GFUserDefault setObject:resultString forKey:PowerOnWebsiteUserDefaultKey];
    }];
}


#pragma mark - 发送请求/保存站点

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
//TODO: 隐藏btn (下一步)
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.618 animations:^{
        _goButton.alpha = 1;
        
    } completion:nil];
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField  == self.websiteTextField) {
        //点击换行  让下一个textField成为焦点 即passwordTextField成为焦点
        [self wentToNextView];
        return YES;
    }
    return YES;
}



@end
