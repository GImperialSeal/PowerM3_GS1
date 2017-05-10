//
//  GFWebViewController+Picker.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/18.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFWebViewController+Picker.h"
#import "AFNetworking.h"
#import "UIImage+Alisa.h"
#import "HandleJSCommand.h"
#import "GFBaseViewController.h"

#import "GFUploadManager.h"

@import MobileCoreServices;

@implementation GFWebViewController (Picker)
- (void)pickerWithEnum:(ByJSOrderToPerformOperations)operation{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    __weak typeof(self)weakself = self;
   
    switch (operation){
        case GFImagePickerOperationCamera:{
            [self imagePickerWithCameraCaptureDidFinishPicking:^(UIImage *image) {
                assert(image);
                [weakself handleImage:image];
            }];
            break;
        }
        case GFImagePickerOperationVideo:{
          [self videoPickerWithCameraCaptureDidFinishPicking:^(NSString *path) {
              [weakself handleVideo:path];
          }];
            break;
        }
        case GFImagePickerOperationVideosLibrary:{
            
            [self videoPickerWithAlbumCapureDidFinishPicking:^(NSString *path) {
                
                [weakself handleVideo:path];
            }];
            break;
        }
        case GFImagePickerOperationImagesLibrary:{
            
            [self imagePickerWithAlbumCapureDidFinishPicking:^(UIImage *image) {
                [weakself handleImage:image];
            }];
            break;
        }
        default:
            break;
    }
   
    
}


- (void)handleImage:(UIImage *)image{
    
    if (self.handleJS.translateBase64){
        [self translateImageToBase64WithImage:image];
    }
    // 上传
    NSDictionary *uploadDic = self.handleJS.uploadServer;
    if ([uploadDic[@"upload"] boolValue]){
        
        
        
        CGFloat scale = [uploadDic[@"scale"] floatValue];
        
        NSDictionary *dic = @{@"KeyWord":uploadDic[@"keyword"],
                              @"KeyValue":uploadDic[@"keyvalue"],
                              @"_fileid":[[NSUUID UUID]UUIDString],
                              @"action":@"upload"};
        
        __weak typeof(self)weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showMessag:@"上传中..." toView:self.view];
        });

        [[GFUploadManager manager] UploadPicturesWithURL:Upload parameters:dic images:@[image] scale:scale UploadProgress:^(float progress) {
            
        } success:^(id responseObject) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            BLog(@"----------------------dic: %@",responseObject);
            if ([responseObject[@"success"]boolValue]) {
                [MBProgressHUD showSuccess:@"上传成功" toView:nil];
                [weakSelf callBackJSWithArguments:image];
            }else{
                [MBProgressHUD showError:responseObject[@"message"] toView:nil];
            }

        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [MBProgressHUD showError:@"上传失败" toView:nil];

        }];
    }

}

- (void)handleVideo:(NSString *)path{
    if ([self.handleJS.uploadServer[@"upload"] boolValue]) {
        
        NSDictionary *uploadDic = self.handleJS.uploadServer;

        NSDictionary *dic = @{@"KeyWord":uploadDic[@"keyword"],
                              @"KeyValue":uploadDic[@"keyvalue"],
                              @"_fileid":[[NSUUID UUID]UUIDString]};
        __weak typeof(self)weakSelf = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showMessag:@"正在上传视频文件..." toView:self.view];
        });
        [[GFUploadManager manager] uploadVideoWithParameters:dic VideoPath:path UrlString:Upload complete:^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.context[weakSelf.handleJS.function] callWithArguments:@[path]];
        } failure:^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [MBProgressHUD showError:@"上传失败" toView:weakSelf.view];
        }];
    }
    

}



#pragma mark -- 保存
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (image) {
        [self callBackJSWithArguments:nil];
    }else{
        BLog(@"图片保存到相册失败");
    }
}


- (void)translateImageToBase64WithImage:(UIImage *)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.context evaluateScript:self.handleJS.function];
        [self callBackJSWithArguments:image];
    });
}

#pragma mark - 回调

- (void)callBackJSWithArguments:(UIImage *)image{
    NSString *str = [UIImageJPEGRepresentation(image, 0.3) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self.context[self.handleJS.function] callWithArguments:@[str]];

}


@end
