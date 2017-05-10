//
//  ViewController.m
//  jjj
//
//  Created by 顾玉玺 on 2017/4/7.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import "ZFTextFieldController.h"

@interface ZFTextFieldController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation ZFTextFieldController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    UIButton *button = [[UIButton alloc]initWithFrame:view.bounds];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:GFThemeColor forState:UIControlStateNormal];
    button.alpha = 0.4;
    [button sizeToFit];
    view.bounds = button.bounds;
    [view addSubview:button];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
    self.rightButton = button;
    
}



- (void)done:(UIButton *)sender{
    if (sender.alpha<1) {
        return;
    }
    
    UITableViewCell *cell = [self.tableView.visibleCells firstObject];
    UITextField *tf = [cell viewWithTag:101];

    if (self.completeBlock) {
        self.completeBlock(tf.text);
    }
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"value1"];
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(12, 0, CGRectGetWidth(self.view.frame)-24, 44)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.tag = 101;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
        
    }
    UITextField *tf = [cell viewWithTag:101];
    tf.text = self.content;
    return cell;
    
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.text.length) {
        
        self.rightButton.alpha = 1;
        return YES;
    }
    self.rightButton.selected = NO;
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    return YES;
}



#pragma mark 返回每一组的header标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.header;
}
#pragma mark 返回每一组的footer标题
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.footer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
