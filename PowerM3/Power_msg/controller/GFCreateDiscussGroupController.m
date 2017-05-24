//
//  ViewController.m
//  12212
//
//  Created by 顾玉玺 on 2017/4/11.
//  Copyright © 2017年 顾玉玺. All rights reserved.
//

#import "GFCreateDiscussGroupController.h"
#import "CollectionViewCell.h"
#import "GFTextField.h"
#import "GFRCloudHelper.h"
#import "GFConversationViewController.h"
#import "GFUserInfoCoreDataModel+CoreDataProperties.h"

@interface GFCreateDiscussGroupController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,GFTextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionWidthConstraint;
@property (weak, nonatomic) IBOutlet GFTextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchImageWidthConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

// 存放 选择的数据
@property (nonatomic, strong) NSMutableArray *collectSourceArray;
// 标记
@property (nonatomic, strong) NSMutableDictionary *choosedDictionary;
@end

static  NSArray *mark_KeysArray;
static  NSDictionary *mark_SourceDictionary;

@implementation GFCreateDiscussGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];
}


- (void)setUI{
  
    

    self.titleLabel.text = self.title;
    
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"id"];
    
    _textField.deleteBackwordDelegate = self;
    // 监听textfield 的输入
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    // 修改光标颜色
    [_textField setTintColor:GFThemeColor];
    
    // 改变索引的颜色
    _tableView.sectionIndexColor = GFThemeColor;
    // 改变索引选中的背景颜色
    _tableView.sectionIndexTrackingBackgroundColor = [UIColor blackColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    mark_SourceDictionary = _sourceDictionary;
    mark_KeysArray = _sectionTitlesArray;
    
}


- (void)layoutCollectionViewAtIndexPath:(NSUInteger)row insertOrDelete:(BOOL)delete{
    NSInteger count = self.collectSourceArray.count;
    NSIndexPath *index = nil;
    
    if (!count) {
        self.doneButton.enabled = NO;
        self.doneButton.alpha = 0.8;
        [self.doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.doneButton setTitle:@"确认" forState:UIControlStateNormal];

    }else{
        self.doneButton.enabled = YES;
        self.doneButton.alpha = 1;
        [self.doneButton setTitleColor:GFThemeColor forState:UIControlStateNormal];
        [self.doneButton setTitle:[NSString stringWithFormat:@"确认(%zd)",count] forState:UIControlStateNormal];
    }

    if (count<6) {
        self.collectionWidthConstraint.constant = (count-1)*8+count*40+(count==0?0:12);
        self.searchImageWidthConstraint.constant = count==0?13:0;
        [self.view layoutIfNeeded];
    }

    if (delete) {
        index = [NSIndexPath indexPathForRow:row inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[index]];
    }else{
        index = [NSIndexPath indexPathForRow:count-1 inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[index]];
        [_collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }


}

#pragma mark - collectionView  delegate
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _collectSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"id" forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:303];
    GFUserInfoCoreDataModel *p = [GFUserInfoCoreDataModel findUserByUserId:_collectSourceArray[indexPath.row]];
    [imageView gf_loadImagesWithURL:p.portraitUri];
    return cell;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.choosedDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[self.collectSourceArray objectAtIndex:indexPath.row] isEqualToString:obj]) {
            [self.choosedDictionary removeObjectForKey:key];
            [self.collectSourceArray removeObjectAtIndex:indexPath.row];
            [self layoutCollectionViewAtIndexPath:indexPath.row insertOrDelete:YES];
            [self.tableView reloadData];
            *stop = YES;
        };
    }];
    
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}
//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

#pragma mark - tableView  delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionTitlesArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sourceDictionary[_sectionTitlesArray[section]] count];
}
// 设置分区头部文字
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 90, 20)];
    lab.font = [UIFont systemFontOfSize:15];
    lab.text = _sectionTitlesArray[section];
    lab.textColor = [UIColor grayColor];
    [view addSubview:lab];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *key = [NSString stringWithFormat:@"%zd-%zd",indexPath.section,indexPath.row];
    UIImageView *head = [cell.contentView viewWithTag:100];
    UILabel *label = [cell.contentView viewWithTag:101];
    UIImageView *picker = [cell.contentView viewWithTag:102];
    RCUserInfo *p = _sourceDictionary[_sectionTitlesArray[indexPath.section]][indexPath.row];

    if (self.choosedDictionary[key]) {
        picker.image = [UIImage imageNamed:@"xuanze_green"];
    }else{
        picker.image = [UIImage imageNamed:@"weixuanze"];
        
        for (NSString *userId in _memberListArray) {
            if ([userId isEqualToString:p.userId]) {
                picker.image = [UIImage imageNamed:@"xuanze_gray"];
                break;
            }
        }
    }

    [head gf_loadImagesWithURL:p.portraitUri];
    label.text = p.name;
        
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [NSString stringWithFormat:@"%zd-%zd",indexPath.section,indexPath.row];
    UIImageView *picker = [[tableView cellForRowAtIndexPath:indexPath] viewWithTag:102];
    RCUserInfo *p = _sourceDictionary[_sectionTitlesArray[indexPath.section]][indexPath.row];
    
    for (NSString *userId in _memberListArray) {
        if ([userId isEqualToString:p.userId]) {
            picker.image = [UIImage imageNamed:@"xuanze_gray"];
            return;
        }
    }

    NSString *userId = p.userId;
    if (self.choosedDictionary[key]) {
        [_choosedDictionary removeObjectForKey:key];
        picker.image = [UIImage imageNamed:@"weixuanze"];
        NSUInteger index = [self.collectSourceArray indexOfObject:userId];
        [self.collectSourceArray removeObject:userId];
        [self layoutCollectionViewAtIndexPath:index insertOrDelete:YES];
    }else{
        picker.image = [UIImage imageNamed:@"xuanze_green"];
        [self.choosedDictionary setObject:userId forKey:key];
        [self.collectSourceArray addObject:userId];
        [self layoutCollectionViewAtIndexPath:1 insertOrDelete:NO];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _sectionTitlesArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _showSectionIndex ? _sectionTitlesArray:nil;
}


#pragma mark - textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.searchImageWidthConstraint.constant = 0;
    return YES;
}


- (void)textFieldDeleteBackward:(UITextField *)textField{
    
    if (textField.text.length) {
        
        return;
    }
    NSInteger count = _collectSourceArray.count;
    if (count) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:count-1 inSection:0];
        CollectionViewCell *cell = (CollectionViewCell *)[_collectionView cellForItemAtIndexPath:index];
        if (cell.selected) {
            
            [self.choosedDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([[self.collectSourceArray lastObject] isEqualToString:obj]) {
                    [self.choosedDictionary removeObjectForKey:key];
                    [self.collectSourceArray removeLastObject];
                    [self layoutCollectionViewAtIndexPath:count-1 insertOrDelete:YES];
                    [self.tableView reloadData];
                    *stop = YES;
                };
            }];
        }else{
            [_collectionView selectItemAtIndexPath:index animated:YES scrollPosition:UICollectionViewScrollPositionRight];
        }
    }else{
        self.searchImageWidthConstraint.constant = 13;
        [textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length) {
        NSMutableArray *result = [NSMutableArray array];
        for (NSArray *arr in self.sourceDictionary.allValues) {
            BLog(@"array: %@",arr);
            [result addObjectsFromArray:[arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@",textField.text]]];
        }
        self.sectionTitlesArray  = @[@"联系人"];
        self.sourceDictionary = @{@"联系人":result};
        self.showSectionIndex = NO;
        [self.tableView reloadData];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField{
    
    if (textField.text.length) {
    }else{
        self.sectionTitlesArray  = mark_KeysArray;
        self.sourceDictionary = mark_SourceDictionary;
        self.showSectionIndex = YES;
        [self.tableView reloadData];
    }
    
    
    
    
    
}
#pragma mark -  get func

- (NSMutableDictionary *)choosedDictionary{
    if (_choosedDictionary) return _choosedDictionary;
    _choosedDictionary = [NSMutableDictionary dictionary];
    return _choosedDictionary;
}

- (NSMutableArray *)collectSourceArray{
    if (_collectSourceArray) return _collectSourceArray;
    _collectSourceArray = [NSMutableArray array];
    return _collectSourceArray;
}


#pragma mark - click  func

- (IBAction)cancle {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)done {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completeBlock) {
            self.completeBlock(_collectSourceArray);
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
