//
//  GFFixHeadImageController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/19.
//  Copyright © 2016年 qymgc. All rights reserved.
//
typedef NS_ENUM(NSInteger, ByJSOrderToPerformOperations) {
    GFImagePickerOperationCamera           = 0 , // 打开相机
    GFImagePickerOperationImagesLibrary    = 3  // 照片库
} __TVOS_PROHIBITED;
#import "GFFixHeadImageController.h"
#import "UIImage+Alisa.h"
#import "AFNetworking.h"
#import "GFPersonInfoViewController.h"
#import "ZFSettingItem.h"
#import "GFActionSheet.h"

@interface GFFixHeadImageController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) GFWebsiteCoreDataModel *website;
@end

@implementation GFFixHeadImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    assert(self.portraitUri.length);
    
    BLog(@"portraitUri: %@",self.portraitUri);

     UIImageView *imageView = [[UIImageView alloc]init];
    
    [imageView gf_loadImagesWithURL:self.portraitUri completion:^{
        CGSize size = [imageView.image gf_scaleImageToWidth:KW-40].size;
        imageView.frame = CGRectMake((KW-size.width)/2, (CGRectGetHeight(self.view.frame)-size.height)/2, size.width, size.height);
    }];
    
    
    [self.view addSubview:imageView];
    
    self.headImageView = imageView;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self rightNavgationBarItem];
    
    self.website = [GFCommonHelper currentWebSite];
}

- (void)rightNavgationBarItem{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(clickMore)];
}

#pragma mark - click func
- (void)clickMore{
    
    [GFActionSheet ActionSheetWithTitle:@"选择照片" buttonTitles:@[@"拍照",@"打开相册"] cancelButtonTitle:@"取消" completionBlock:^(NSUInteger buttonIndex) {
        if (buttonIndex == 0) {
        }else if(buttonIndex == 1){
            [self imagePickerWithCameraCaptureDidFinishPicking:^(UIImage *image) {
                [self showSelectedImageAndUpload:image];
            }];
        }else{
            [self imagePickerWithAlbumCapureDidFinishPicking:^(UIImage *image) {
                [self showSelectedImageAndUpload:image];
            }];
        }
    }];

}


- (void)showSelectedImageAndUpload:(UIImage *)photo{
    CGSize size = [photo gf_scaleImageToWidth:KW-40].size;
    self.headImageView.frame = CGRectMake((KW-size.width)/2, (CGRectGetHeight(self.view.frame)-size.height)/2, size.width, size.height);
    self.headImageView.image = photo;
    [self upload:UIImageJPEGRepresentation(photo, 0.1)];
}






- (void)upload:(NSData *)data{
    
    [MBProgressHUD showMessag:@"上传中..." toView:self.view];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:POWERM3URL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",str];
    NSString *uuid = [[NSUUID UUID]UUIDString];
    NSDictionary *dic = @{@"KeyWord":@"Human",
                          @"KeyValue":_website.humanID,
                          @"_filename":fileName,
                          @"_fileid":uuid,
                          @"_start":@(0),
                          @"_end":@(data.length),
                          @"_total":@(data.length),
                          @"action":@"upload"};
    __weak typeof(self)weakself = self;
    [manager POST:Upload parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:@"FileData" fileName:fileName mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            if ([dic[@"success"]boolValue]) {
                BLog(@"上传成功");
                [weakself fixServerData:uuid];
            }else{
                [MBProgressHUD showError:dic[@"message"] toView:nil];
            }
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"上传失败" toView:nil];
    }];
}

- (void)fixServerData:(NSString *)uuid {
    
    NSString *sessionID = _website.sessionID;
    NSString *humanID = _website.humanID;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"HeadSmall":uuid} options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    BLog(@"uuid: %@",uuid);
    
    __weak typeof (self)weakSelf = self;
    BLog(@"修改 服务器 数据");

    [GFNetworkHelper POST:FixUserInfo parameters:@{@"humanid":humanID,@"sessionid":sessionID,@"humaninfo":jsonString} success:^(id  _Nonnull responseObject) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        BLog(@"message   %@",responseObject);
        
        if ([responseObject[@"success"] boolValue]) {
            [MBProgressHUD showSuccess:@"修改成功" toView:self.view];
            _website.headImage = POWERSERVERFILEPATH(uuid);
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            weakSelf.model.icon = POWERSERVERFILEPATH(uuid);
            GFPersonInfoViewController *info = self.navigationController.viewControllers[1];
            [info.tableView reloadData];
            
        }
    } failure:^(NSError * _Nonnull err) {
        [MBProgressHUD showError:@"修改失败" toView:nil];

    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
