//
//  GFPickerHelper.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/2/23.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFPickerHelper.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
@implementation GFPickerHelper
+ (void)pickerImages:(UIViewController *)vc didFinishPicking:(void(^)(NSArray *images))complete{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXFLOAT columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.sortAscendingByModificationDate = NO;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if(complete)complete(photos);
    }];
    
    [vc presentViewController:imagePickerVc animated:YES completion:nil];
}



+ (void)pickerVideoWithPresentController:(UIViewController *)vc didFinishPicking:(void(^)(NSString *path))complete{
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.sortAscendingByModificationDate = NO;
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, id assets) {
        [[TZImageManager manager] getVideoOutputPathWithAsset:assets completion:^(NSString *outputPath) {
            BLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
            if(complete)complete(outputPath);
            // Export completed, send video here, send by outputPath or NSData
            //         导出完成，在这里写上传代码，通过路径或者通过NSData上传
            
        }];
    }];
    [vc presentViewController:imagePickerVc animated:YES completion:nil];
}



@end
