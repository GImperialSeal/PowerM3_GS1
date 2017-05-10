//
//  GFFixPasswordController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/9.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFFixPasswordController.h"
@interface GFFixPasswordController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation GFFixPasswordController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    
}


- (void)save{
    NSString *sessionID = [GFCommonHelper currentWebSite].sessionID;

    UITableViewCell *cell0 = [self.tableView visibleCells][0];
    UITableViewCell *cell1 = [self.tableView visibleCells][1];
    UITableViewCell *cell2 = [self.tableView visibleCells][2];
    UITextField *tf0 = [cell0 viewWithTag:101];
    UITextField *tf1 = [cell1 viewWithTag:101];
    UITextField *tf2 = [cell2 viewWithTag:101];
    
    NSString *oldPassWord  = tf0.text;
    NSString *newPassWord0 = tf1.text;
    NSString *newPassWord1 = tf2.text;
    
    if (oldPassWord.length==0) {
        oldPassWord = @"";
    }
    
    if (newPassWord0.length==0||newPassWord1.length==0) {
        [MBProgressHUD showError:@"密码长度不能少于6位" toView:nil];
        return;
    }
    
    if (![newPassWord0 isEqualToString:newPassWord1]) {
        [MBProgressHUD showError:@"两次密码输入不一致" toView:nil];
        return;
    }
   
    
    BLog(@"新密码:  %@  原密码: %@",tf0.text,tf1.text);
    NSDictionary *dic = @{@"sessionid":sessionID,@"oldpass":oldPassWord,@"newpass":tf2.text};
    [GFNetworkHelper POST:FixPassword parameters:dic success:^(id responseObject) {
        BLog(@"responseObject :%@ %@",responseObject,responseObject[@"message"]);
        if (![responseObject[@"success"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];

            [MBProgressHUD showError:@"修改失败" toView:nil];
        }else{
            [MBProgressHUD showSuccess:@"修改成功" toView:nil];
        }

    } failure:^(NSError *err) {
        
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"value1"];
        UITextField *textField = [[UITextField alloc]initWithFrame:cell.contentView.bounds];
        textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 12, 1)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.tag = 101;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
        
    }
    UITextField *tf = [cell viewWithTag:101];
    if (indexPath.row == 0) {
        tf.placeholder = @"原密码";
        tf.returnKeyType = UIReturnKeyNext;

    }else if(indexPath.row == 1){
        tf.placeholder = @"新密码";
        tf.returnKeyType = UIReturnKeyNext;

    }else{
        tf.placeholder = @"确认密码";
        tf.returnKeyType = UIReturnKeyDone;

    }
    return cell;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    UITableViewCell *cell0 = [self.tableView visibleCells][0];
    UITableViewCell *cell1 = [self.tableView visibleCells][1];
    UITableViewCell *cell2 = [self.tableView visibleCells][2];
    UITextField *tf0 = [cell0 viewWithTag:101];
    UITextField *tf1 = [cell1 viewWithTag:101];
    UITextField *tf2 = [cell2 viewWithTag:101];
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self save];
    }else{
        if (tf0.isFirstResponder) {
            [tf1 becomeFirstResponder];
        }else{
            [tf2 becomeFirstResponder];
        }
    }
    return YES;
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
