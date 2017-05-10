//
//  GFWebViewController+Picker.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/18.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFWebViewController.h"
typedef NS_ENUM(NSInteger, ByJSOrderToPerformOperations) {
    GFImagePickerOperationCamera           = 0 , // 打开相机
    GFImagePickerOperationVideo            = 1 , //  录像
    GFImagePickerOperationVideosLibrary    = 2 , // 媒体库
    GFImagePickerOperationImagesLibrary    = 3  // 照片库
} __TVOS_PROHIBITED;

@interface GFWebViewController (Picker)<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (void)pickerWithEnum:(ByJSOrderToPerformOperations)operation;

@end
