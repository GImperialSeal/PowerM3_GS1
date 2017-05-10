//
//  GFCreateChatGroupViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/29.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFCreateChatGroupViewController.h"

@interface GFCreateChatGroupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *headButton;

@end

@implementation GFCreateChatGroupViewController
- (IBAction)addHeadImage:(UIButton *)sender {
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self)weakself = self;
    [sheet addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself imagePickerWithCameraCaptureDidFinishPicking:^(UIImage *image) {
            [weakself.headButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself imagePickerWithAlbumCapureDidFinishPicking:^(UIImage *image) {
            [weakself.headButton setBackgroundImage:image forState:UIControlStateNormal];

        }];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"使用默认头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself.headButton setBackgroundImage:[UIImage imageNamed:@"timg.jpg"] forState:UIControlStateNormal];

    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];

    
    [self presentViewController:sheet animated:YES completion:^{
        
    }];
}
- (IBAction)submit {
    
    NSInteger groupcode = arc4random()%1000000;
    [GFNetworkHelper GET:CreateGroup parameters:@{@"groupname":_textField.text,@"groupcode":[NSString stringWithFormat:@"%zd",groupcode]} success:^(id responseObject) {
        BLog(@"resopnobjec:  %@",responseObject);
        BLog(@"%@: ",responseObject[@"message"]);        
        
    } failure:^(NSError *error) {
        BLog(@"error:  %@",error);
        
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textFieldMaxY = CGRectGetMaxY(_textField.frame);
    self.headButton.layer.masksToBounds = YES;
    self.headButton.layer.cornerRadius = 75;
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
