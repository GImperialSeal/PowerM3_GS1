//
//  GFCheckedUserInfoController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/6.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFContactInfoController.h"
#import "GFContactInformation+CoreDataProperties.h"
#import "GFChatViewController.h"
#import "GFContactDetailCell.h"
@interface GFContactInfoController ()

@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation GFContactInfoController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self section_zero];
    [self section_first];
    [self section_second];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GFContactDetailCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
}



- (void)section_zero{
    GFBaseTableViewSectionModel *section = [[GFBaseTableViewSectionModel alloc]init];
    
    GFBaseTableViewCellModel    *item0 = [[GFBaseTableViewCellModel alloc]init];
    
    item0.leftImage =  [UIImage imageNamed:@"icon_default"];
    
    item0.cellType = GFBaseTableViewCellTypeDefault;
    
    item0.centerTitle = self.contactModel.userName;
    
   
    
    section.cellModelArray = @[item0];
    
    [self.allSectionModelArray addObject:section];
  
}

- (void)section_first{
    
    GFBaseTableViewSectionModel *section = [[GFBaseTableViewSectionModel alloc]init];
//    
//    GFBaseTableViewCellModel    *item0 = [[GFBaseTableViewCellModel alloc]init];
//    
//    item0.cellType = GFBaseTableViewCellTypeLeftTitle;
//    
//    item0.leftTitle =  @"ID";
//    
//    item0.centerTitle = self.contactModel.userID;
//    
//    item0.accessoryType = GFBaseTableViewCellTypeNone;
    
   
    
    GFBaseTableViewCellModel    *item1 = [[GFBaseTableViewCellModel alloc]init];
    
    item1.leftTitle =  @"账号";
    item1.cellType = GFBaseTableViewCellTypeLeftTitle;

    
    item1.centerTitle = self.contactModel.userAccount;
    
    item1.accessoryType = GFBaseTableViewCellTypeNone;
    
    
    section.cellModelArray = @[item1];
    
    [self.allSectionModelArray addObject:section];
}

- (void)section_second{
    
    __weak typeof(self)weakself = self;

    GFBaseTableViewSectionModel *section0 = [[GFBaseTableViewSectionModel alloc]init];
    
    section0.gf_header = @"发送消息";
    
    section0.gf_backgroundColor = RGBCOLOR(32, 176, 136);
    
    section0.gf_titleColor = [UIColor whiteColor];
    
    section0.gf_heightForHeader = 46;
    section0.gf_heightForFooder = 10;
    
    section0.didClick_header = ^(){
        GFContactInformation *contact = [weakself addContactWithAlert:NO];
        GFChatViewController *chat = [[GFChatViewController alloc]init];
        chat.gf_Contact = contact;
        [self.navigationController pushViewController:chat animated:YES];
    };
    
    GFBaseTableViewSectionModel *section1 = [[GFBaseTableViewSectionModel alloc]init];
    
    section1.gf_header = @"添加联系人";
    
    section1.gf_backgroundColor = [UIColor blackColor];
    
    section1.gf_titleColor = [UIColor whiteColor];
    
    section1.gf_heightForHeader = 46;
    section1.gf_heightForFooder = 10;

    section1.didClick_header = ^(){
        [weakself addContactWithAlert:YES];
    };
    
    [self.allSectionModelArray addObject:section0];
    [self.allSectionModelArray addObject:section1];
}

- (GFContactInformation *)addContactWithAlert:(BOOL)show{
    NSArray *array = [GFContactInformation MR_findByAttribute:@"userID" withValue:self.contactModel.userID];
    if (array.count==0) {
        GFContactInformation *contact = [GFContactInformation MR_createEntity];
        contact.userID = self.contactModel.userID;
        contact.userName = self.contactModel.userName;
        contact.userAccount = self.contactModel.userAccount;
        contact.userHeadImage = self.contactModel.userHeadImage;
        contact.date = [NSDate date];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return contact;
    }else{
        [GFAlertView alertWithTitle:@"联系人已存在"];
        for (GFContactInformation *contact in array) {
            contact.date = [NSDate date];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return array.firstObject;
    }
}



@end
