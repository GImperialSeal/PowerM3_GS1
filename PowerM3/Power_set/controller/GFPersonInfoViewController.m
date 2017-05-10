//
//  GFPersonInfoViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/19.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFPersonInfoViewController.h"
#import "UIImage+Alisa.h"
#import "GFFixHeadImageController.h"
#import "GFFixPhoneOrEmailController.h"
@interface GFPersonInfoViewController ()

@property (nonatomic,strong) NSMutableArray *sourceArray;

@end

@implementation GFPersonInfoViewController


- (void)dataSource{
    
    GFWebsiteCoreDataModel *info = [GFCommonHelper currentWebSite];

    NSLog(@"info headImage : %@",info.headImage);
    
    ZFSettingItem *head  = [ZFSettingItem itemWithHeadImage:info.headImage title:info.name subtitle:info.title];
    head.operation = ^(ZFSettingItem *item) {
        GFFixHeadImageController *fix = [GFFixHeadImageController new];
        fix.portraitUri = info.headImage;
        fix.model = item;
        [self.navigationController pushViewController:fix animated:YES];
    };
    ZFSettingItem *phone = [ZFSettingItem itemWithTitle:@"手机" subtitle:info.phone];
    phone.operation = ^(ZFSettingItem *item) {
        GFFixPhoneOrEmailController *fix = [GFFixPhoneOrEmailController new];
        fix.phone = info.phone;
        fix.isPhone = YES;
        fix.model = item;
        [self.navigationController pushViewController:fix animated:YES];
  
    };
    ZFSettingItem *user  = [ZFSettingItem itemWithTitle:@"公司" subtitle:info.subtitle];
    user.type = ZFSettingItemTypeNone;
    
    ZFSettingItem *email = [ZFSettingItem itemWithTitle:@"邮箱" subtitle:info.email];
    email.operation = ^(ZFSettingItem *item) {
        GFFixPhoneOrEmailController *fix = [GFFixPhoneOrEmailController new];
        fix.phone = info.email;
        fix.isPhone = NO;
        fix.model = item;
        [self.navigationController pushViewController:fix animated:YES];
  
    };
    ZFSettingGroup *headGroup    = [ZFSettingGroup groupWithItem:@[head]];
    
    ZFSettingGroup *infoGroup = [ZFSettingGroup groupWithItem:@[user,phone,email]];
    
    
    [_allGroups addObject:headGroup];
    [_allGroups addObject:infoGroup];



    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
   // tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    [self dataSource];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
