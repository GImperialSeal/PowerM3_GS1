//
//  GFFixPhoneOrEmailController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/19.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFFixPhoneOrEmailController.h"
#import "GFWebsiteCoreDataModel+CoreDataProperties.h"
#import "GFPersonInfoViewController.h"
#import "ZFSettingItem.h"

#import "NSString+Extension.h"
@interface GFFixPhoneOrEmailController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation GFFixPhoneOrEmailController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1"];
    if (!cell) {
          cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"value1"];
        UITextField *textField = [[UITextField alloc]initWithFrame:cell.contentView.bounds];
        textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 12, 1)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.tag = 101;
        [cell.contentView addSubview:textField];
        
    }
    UITextField *tf = [cell viewWithTag:101];
    if (self.isPhone) {
        tf.placeholder = self.phone;

    }else{
        tf.placeholder = self.email;

    }
    
    return cell;
        
    
}






- (void)save{
    
    UITableViewCell *cell = [self.tableView visibleCells][0];
    UITextField *tf = [cell viewWithTag:101];
    
    NSString *sessionID = [GFCommonHelper currentWebSite].sessionID;
    NSString *humainID  = [GFCommonHelper currentWebSite].humanID;
    __weak typeof(self) weakSelf = self;
    
    BLog(@"save: ");
    if (self.isPhone) {
        if (![tf.text isPhoneNumber]) {
            [MBProgressHUD showError:@"手机号码格式不正确" toView:self.view];
        }else{
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"Mobile":tf.text} options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = @{@"humanid":humainID,@"sessionid":sessionID,@"humaninfo":jsonString};

            [GFNetworkHelper GET:FixUserInfo parameters:dic success:^(id  _Nonnull responseObject) {
                
                BLog(@"%@",responseObject);
                if (responseObject[@"success"]) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];

                    [MBProgressHUD showSuccess:@"修改成功" toView:nil];
                    weakSelf.model.subtitle = tf.text;

                    GFWebsiteCoreDataModel *info = [[GFWebsiteCoreDataModel MR_findByAttribute:@"url" withValue:POWERM3URL] firstObject];
                    info.phone = tf.text;
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    GFPersonInfoViewController *personInfo = self.navigationController.viewControllers[1];
                    [personInfo.tableView reloadData];

                }else{
                    [MBProgressHUD showError:@"修改失败" toView:nil];
                }
            } failure:^(NSError * _Nonnull err) {
                BLog(@"save fail ");
            }];

        }
    }else{
        if(![tf.text isEmail]){
            [MBProgressHUD showError:@"邮箱格式不正确" toView:self.view];
        }else{
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"Email":tf.text} options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = @{@"humanid":humainID,@"sessionid":sessionID,@"humaninfo":jsonString};
            [GFNetworkHelper GET:FixUserInfo parameters:dic success:^(id  _Nonnull responseObject) {
                if (responseObject[@"success"]) {
                    
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    [MBProgressHUD showSuccess:@"修改成功" toView:nil];
                    weakSelf.model.subtitle = tf.text;

                    GFWebsiteCoreDataModel *info = [[GFWebsiteCoreDataModel MR_findByAttribute:@"url" withValue:POWERM3URL] firstObject];
                    info.email = tf.text;
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    GFPersonInfoViewController *personInfo = self.navigationController.viewControllers[1];
                    [personInfo.tableView reloadData];
                    

                }else{
                    [MBProgressHUD showError:@"修改失败" toView:nil];

                }
            } failure:^(NSError * _Nonnull err) {
                
            }];
        }
    }
}




@end
