//
//  GFSearchResultController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/17.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFSearchResultController.h"
#import "GFContactModel.h"
#import "PureLayout.h"
#import "GFContactsTableViewCell.h"
#import "GFConversationViewController.h"
@interface GFSearchResultController ()

@end

@implementation GFSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.rowHeight = 56;
    // self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    
    
    self.sourceArray = [NSMutableArray arrayWithCapacity:50];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GFContactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    GFContactModel *model = self.sourceArray[indexPath.row];
    [cell.headImageView gf_loadImagesWithURL:POWERSERVERFILEPATH(model.portraitUri)];
    cell.titleLabel.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GFContactModel *model = self.sourceArray[indexPath.row];
    GFConversationViewController *conversationVC = [[GFConversationViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = model.userId;
    conversationVC.title = model.name;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.nav pushViewController:conversationVC animated:YES];
    
    
}




@end
