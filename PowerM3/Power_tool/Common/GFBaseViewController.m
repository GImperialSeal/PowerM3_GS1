//
//  GFBaseViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/29.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFBaseViewController.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"

@interface GFBaseViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, copy) void(^didFinishPickingImageHandle)(UIImage *image);

@property (nonatomic, copy) void(^didFinishPickingVideoHandle)(NSString *path);

@end

@implementation GFBaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)keyboardChange:(NSNotification *)noti{
    NSDictionary *userInfo = [noti userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (noti.name == UIKeyboardWillShowNotification) {
            if ( KH-keyboardEndFrame.size.height-_textFieldMaxY -20<0) {
                 self.view.transform = CGAffineTransformMakeTranslation(0, KH-keyboardEndFrame.size.height-_textFieldMaxY -20);
            }
        }else{
            self.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 相册
- (void)imagePickerWithAlbumCapureDidFinishPicking:(void(^)(UIImage *image))complete{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.sortAscendingByModificationDate = NO;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if(complete)complete(photos.firstObject);
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

// 拍照
- (void)imagePickerWithCameraCaptureDidFinishPicking:(void(^)(UIImage *image))complete{
    BOOL camera =[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!camera) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"照相机不能打开" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return ;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置来源为摄像机
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;//拍照
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//后置摄像头
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

    self.didFinishPickingImageHandle = complete;
}


// 录像
- (void)videoPickerWithCameraCaptureDidFinishPicking:(void(^)(NSString *path))complete{
    BOOL camera =[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!camera) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"照相机不能打开" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return ;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置来源为摄像机
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;//录像
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//后置摄像头
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
    self.didFinishPickingVideoHandle = complete;
}

// 视频
- (void)videoPickerWithAlbumCapureDidFinishPicking:(void(^)(NSString *path))complete{
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
    [self presentViewController:imagePickerVc animated:YES completion:nil];

}


//取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    // 图片
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]){
         BLog(@"拍照");
                if (self.didFinishPickingImageHandle) {
            self.didFinishPickingImageHandle(info[UIImagePickerControllerOriginalImage]);
        }
    // 视频
    }else{
        BLog(@"录像");
        NSURL *path = info[UIImagePickerControllerMediaURL];
        
        assert(path);
        
        
        NSLog(@"path: %@",path);
        if (self.didFinishPickingVideoHandle) {
            self.didFinishPickingVideoHandle([self avAssetExportWithPath:path]);
        }
    }
}


/**
 压缩视频

 @param videoPath 路径
 @return 沙盒保存路径 失败返回空
 */
- (NSString *)avAssetExportWithPath:(NSURL *)videoPath{
    
    __block NSString *success;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    /**获得视频资源*/
    AVURLAsset * avAsset = [AVURLAsset assetWithURL:videoPath];
    /**压缩*/
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    /**转化后直接写入Library---caches*/
    NSString *  videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[self randomString]]];
    avAssetExport.outputURL = [NSURL fileURLWithPath:videoWritePath];
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    avAssetExport.shouldOptimizeForNetworkUse = YES;
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([avAssetExport status]) {
            case AVAssetExportSessionStatusCompleted:{
                success = videoWritePath;
                dispatch_semaphore_signal(sem);
                break;
            }
            default:
                dispatch_semaphore_signal(sem);
                break;
        }
        
        NSLog(@"error: %@",[avAssetExport error].description);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return success;
}

- (NSString *)randomString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    return [formatter stringFromDate:[NSDate date]];
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
