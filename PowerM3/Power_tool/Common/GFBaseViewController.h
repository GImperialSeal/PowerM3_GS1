//
//  GFBaseViewController.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/29.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFBaseViewController : UIViewController


/**
 键盘会移动到 当前 textfield 下方20像素,多个textField时候建议使用最下方的textField坐标
 */
@property (nonatomic) CGFloat textFieldMaxY;


/**
 第三方照片选择器
 选择一张
 @param complete done
 */
- (void)imagePickerWithAlbumCapureDidFinishPicking:(void(^)(UIImage *image))complete;

/**
 拍照
 @param complete done
 */
- (void)imagePickerWithCameraCaptureDidFinishPicking:(void(^)(UIImage *image))complete;

/**
录像
@param complete done
*/
- (void)videoPickerWithCameraCaptureDidFinishPicking:(void(^)(NSString *path))complete;

// 视频
- (void)videoPickerWithAlbumCapureDidFinishPicking:(void(^)(NSString *path))complete;

@end
