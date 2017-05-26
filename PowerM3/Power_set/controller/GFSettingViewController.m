//
//  AdvancedController.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/7/18.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "GFSettingViewController.h"
#import "GFWebsiteViewController.h"
#import "GFPersonInfoViewController.h"
#import "GFFixPasswordController.h"
#import "QRCodeViewController.h"
#import "GFItemModel.h"
#import "NSString+Extension.h"
#import "GFCommonHelper.h"
#import "GFDomainManager.h"

@interface GFSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isOpen[20];
}
@property (nonatomic,strong) NSArray *sourceArr;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GFSettingViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    GFItemModel *model1 = [[GFItemModel alloc]initWithTitle:@"站点管理" subTitle:nil headImage:@"icon_website"];
    [model1 setDidSelectedRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        
        
        GFWebsiteViewController *webSite = [GFWebsiteViewController new];
        webSite.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webSite animated:YES];
    }];
    
    GFItemModel *model2 = [[GFItemModel alloc]initWithTitle:@"个人信息" subTitle:nil headImage:@"icon_person"];
    [model2 setDidSelectedRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        GFPersonInfoViewController *person = [GFPersonInfoViewController new];
        person.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:person animated:YES];

    }];
    
    GFItemModel *model3 = [[GFItemModel alloc]initWithTitle:@"修改密码" subTitle:nil headImage:@"icon_fix"];
    [model3 setDidSelectedRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        GFFixPasswordController *fix = [[GFFixPasswordController alloc]init];
        fix.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:fix animated:YES];

    }];
    
    GFItemModel *model4 = [[GFItemModel alloc]initWithTitle:@"扫码登录" subTitle:nil headImage:@"icon_qrLogin"];
    [model4 setDidSelectedRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        [self scanQRCode];

    }];
    
    GFItemModel *model5 = [[GFItemModel alloc]initWithTitle:@"清理缓存" subTitle:nil headImage:@"icon_deleteCaches"];
    [model5 setDidSelectedRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger size = [GFDomainManager fileSizeOfAllCachesFile];
        NSString *message = [NSString stringWithFormat:@"缓存文件大小为%.2fM",(long)size/(1024.0*1024.0)];
        [GFAlertView showAlertWithTitle:@"提示" message:message completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
            if (buttonIndex==1)[GFDomainManager deleteAllCaches];
        } cancelButtonTitle:@"取消" otherButtonTitles:@"清理",nil];
    }];

    
    GFItemModel *model6 = [[GFItemModel alloc]initWithTitle:@"退出登录" subTitle:nil headImage:@"icon_exit"];
    [model6 setDidSelectedRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        [self loginOut];
    }];
    
    _sourceArr= @[model1,model2,model3,model4,model5,model6];
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
    tableView.delegate = self;
    
    tableView.dataSource = self;
        
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    self.title = @"设置";
   
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_sourceArr count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == self.sourceArr.count-1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    GFItemModel *model = self.sourceArr[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:model.headImageUrl];
   
    cell.textLabel.text = model.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GFItemModel *model = self.sourceArr[indexPath.row];
    
    if (model.didSelectedRowBlock) {
        model.didSelectedRowBlock(tableView,indexPath);
    }
}


- (void)loginOut{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"退出登录" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GFCommonHelper replaceRootViewControllerOptions:ReplaceWithLoginController];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (NSString *)handleQrLoginParmatters:(NSString *)strID{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *phoneNum = [ud stringForKey:@"SBFormattedPhoneNumber"];
    
    if (!phoneNum || [phoneNum isEmpty]) phoneNum = @"";
    
    
    NSString *sessionID = [GFCommonHelper currentWebSite].sessionID;
    
    NSString *phoneMac = [UIDevice macAddress];
    
    NSDictionary *dic = @{@"id":strID,@"sessionid":sessionID,@"phonesim":phoneNum,@"phonemac":phoneMac};
    
    NSString *parmatter = [dic DictionaryConversionStringOfJson];
    
    return  [GFCommonHelper HloveyRC4:parmatter key:@"PowerM3"];
    
}

- (void)scanQRCode{
    BLog(@"扫一扫");
    QRCodeViewController *qrCode = [[QRCodeViewController alloc]init];
    qrCode.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:qrCode animated:YES];
    __weak typeof(self)weakself = self;
    [qrCode setDidFinishedScanedQRCode:^(NSString *resultstring) {
        NSDictionary *dic = [[resultstring base64Decode] StringOfJsonConversionDictionary];
        if ([dic[@"type"] isEqualToString:@"login"]) {
            NSDictionary *parameters = @{@"json":[weakself handleQrLoginParmatters:dic[@"id"]]};
            NSString *url = dic[@"url"];
            if ([url isUrl]) {
                BLog(@"扫描 不存在 使用默认地址, url: %@",url);
                url = [NSString stringWithFormat:@"%@/APPAccount/QrCodeLogin",url];
            }else{
                url = [NSString stringWithFormat:@"%@/APPAccount/QrCodeLogin",POWERM3URL];
            }
            [GFNetworkHelper POST:url parameters:parameters success:^(id responseObject) {
                [MBProgressHUD showSuccess:@"扫描完成" toView:nil];
                [weakself.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *err) {
                [MBProgressHUD showSuccess:@"扫描失败" toView:nil];
            }];
        }else{
            [MBProgressHUD showSuccess:@"其他类型的扫码" toView:nil];
        }

    }];
}

@end
