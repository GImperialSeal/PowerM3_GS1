//
//  UIImageView+PowerCache.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/9/6.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "UIImageView+PowerCache.h"

#import "GFImageCache.h"

@implementation UIImageView (PowerCache)



// 加载图片
- (void)gf_loadImagesWithURL:(NSString *)url{
    self.image = [UIImage imageNamed:@"icon_default"];
    [GFImageCache downLoad:url complete:^(UIImage *image) {
        self.image = image;
    }];
}

- (void)gf_loadImagesWithURL:(NSString *)url completion:(dispatch_block_t)block{
    
    self.image = [UIImage imageNamed:@"icon_default"];
    [GFImageCache downLoad:url complete:^(UIImage *image) {
        self.image = image;
        if (block) {
            block();
        }
    }];
}

// 在浏览器中显示图片
static UIImageView *orginImageView;
- (void)showAvatarBrowserImage{
    
    orginImageView = self;
    orginImageView.alpha = 0;
    
    // window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // Mask 遮罩
    UIView *backgroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    CGRect oldFrame = [self convertRect:self.bounds toView:window];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    backgroundView.alpha = 1;
    
    // 图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldFrame];
    imageView.image = self.image;
    imageView.tag = 1;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    imageView.transform = CGAffineTransformMakeScale(0.2, 0.2);

    // 点手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    UIImage *image = self.image;
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,
                                   ([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2,
                                   [UIScreen mainScreen].bounds.size.width,
                                   image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;

    }];
}
- (void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=[orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
        backgroundView.alpha=0;
    }];
}




@end



