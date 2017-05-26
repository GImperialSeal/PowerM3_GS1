//
//  NextStepController.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/5/27.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "NextStepController.h"
#import "GFProgressView.h"
#import "GFCommonHelper.h"
#import "PowerM3TextField.h"
#import "LoginDataSource.h"
#import "UIImageView+PowerCache.h"
#import "ZipArchive.h"
#import "MBProgressHUD.h"
#import "GFWebsiteCoreDataModel+CoreDataProperties.h"
#import "FileCacheManager.h"
#import "GFDownloadManager.h"
#import "AppDelegate.h"

@interface NextStepController ()<UICollisionBehaviorDelegate>


@property (weak, nonatomic) IBOutlet PowerM3TextField *userName;
@property (weak, nonatomic) IBOutlet PowerM3TextField *passWord;
@property (weak, nonatomic) IBOutlet UIImageView *companyLogo;
@property (weak, nonatomic) IBOutlet UILabel     *companyName;
@property (weak, nonatomic) IBOutlet GFProgressView *downloadView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *remeberCode;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) UIActivityIndicatorView *activity;
@end


@implementation NextStepController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.textFieldMaxY = CGRectGetMaxY(self.loginButton.frame);
    
    // 加载二维码的图片
    _companyLogo.layer.masksToBounds = YES;
    _companyLogo.layer.cornerRadius = _companyLogo.frame.size.height/2;
    
    // 用户名
    _userName.text = [GFCommonHelper currentWebSite].admin;
    _passWord.text = [GFCommonHelper currentWebSite].password;
    _userName.leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_username"]];
    _passWord.leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_password"]];
    _userName.leftViewMode = UITextFieldViewModeAlways;
    _passWord.leftViewMode = UITextFieldViewModeAlways;
    _passWord.secureTextEntry = YES;
    
    
    [GFNetworkHelper GET:WebsiteInfo parameters:nil success:^(id responseObject) {
        LoginDataSource *model = [[LoginDataSource alloc]initWithJsonDict:responseObject[@"data"]];
        
        BLog(@"resobj:  %@",responseObject);
        if (model.logoImage) {
            [_companyLogo gf_loadImagesWithURL:model.logoImage];
        }
        if (model.title) {
            _companyName.text = [NSString stringWithFormat:@"%@\n%@",model.title,model.subTitle];
        }
        GFWebsiteCoreDataModel *info = [GFCommonHelper currentWebSite];
        info.loginImage = model.logoImage;
        BLog(@"info:  %@",info.loginImage);
        info.title = model.title;
        info.subtitle = model.title;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } failure:^(NSError *err) {
        
    }];

}



#pragma mark - 登录请求
// 请求个人信息
// 验证用户名和密码 请求缓存数据包
- (IBAction)clickLoginButton:(UIButton *)sender{
    __weak typeof(self)weakself = self;
    [MBProgressHUD showMessag:@"正在登录...." toView:self.view];
    [GFCommonHelper login:_userName.text code:_passWord.text completion:^(LoginSuccessedDataSource *model){
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        // 下载安装包
        [weakself downloadApp_webCookies:model.app_downloadCookie];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        [GFAlertView showAlertWithTitle:@"提示" message:[GFDomainError localizedDescription:error] completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
            if (buttonIndex == 1) {
                [weakself clickLoginButton:sender];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"重试",nil];
    }];
}


#pragma mark - 下载 web cookis
- (void)downloadApp_webCookies:(NSString *)app_downloadCookieUrl{
    self.downloadView.hidden = NO;
    self.loginButton.hidden = YES;
    
    __weak typeof(self)weakself = self;
    [[GFDownloadManager manager] downLoad:app_downloadCookieUrl progress:^(float progress) {
        weakself.downloadView.progress =  100.f * progress;
        
    } complete:^(NSURL *filePath) {
        if (![GFUserDefault boolForKey:@"unarchive_zip"])[weakself unArchiveFileWithName:filePath];
        
        [GFCommonHelper replaceRootViewControllerOptions:ReplaceWithTabbarController];
    } failure:^(NSError *error) {
        [GFCommonHelper replaceRootViewControllerOptions:ReplaceWithTabbarController];
        [MBProgressHUD showError:@"数据缓存失效" toView:nil];
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark - 解压
- (void)unArchiveFileWithName:(NSURL *)URL{
    
    BLog(@"(***********  开始解压  **********");

    // 解压
    NSString *zipPath = URL.path;
    NSString *unzipPath = [self cacheSavePath];
    ZipArchive *archive = [[ZipArchive alloc]init];
    if ([archive UnzipOpenFile:zipPath]){
        BOOL ret = [archive UnzipFileTo:unzipPath overWrite:YES];
        if (!ret){
            [archive UnzipCloseFile];
            
             BLog(@"(***********8erro");
        }else{
            [GFUserDefault setBool:YES forKey:@"unarchive_zip"];
            
        }
    }else{
        BLog(@"(*********** zip **********");

    }
}


// 解压路径
- (NSString *)cacheSavePath{
    NSString *domain = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *path = [domain stringByAppendingPathComponent:@"缓存文件"];
    
    path = [path stringByAppendingPathComponent:@"JS文件"];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}


#pragma mark - 点击事件
- (IBAction)remeberCode:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (IBAction)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField  == self.userName) {
        
        //点击换行  让下一个textField成为焦点 即passwordTextField成为焦点
        [self.passWord becomeFirstResponder];
        return YES;
    }
    if (textField == self.passWord) {
        [self clickLoginButton:nil];
    }
    return YES;
}

@end
