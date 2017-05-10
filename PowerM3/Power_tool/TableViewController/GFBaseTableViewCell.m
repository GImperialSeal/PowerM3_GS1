//
//  GFBaseTableViewCell.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/6.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFBaseTableViewCell.h"
#import "GFBaseTableViewCellModel.h"
@interface GFBaseTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftsideButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftsideButtonHeightConstraint;

@property (nonatomic, strong) UISwitch *gf_switch;
@end
@implementation GFBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;// 禁止选中

    // Initialization code
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
    }
    return self;
}

- (void)configCellWithModel:(GFBaseTableViewCellModel *)model{
    if (model.accessoryType == GFBaseTableViewCellTypeNone) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }else if(model.accessoryType == GFBaseTableViewCellTypeArrow){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.accessoryView = self.gf_switch;
    }
    self.headImage.image = model.leftImage;
    self.titleLabel.text = model.centerTitle;
};

- (UISwitch *)gf_switch{
    if (!_gf_switch) {
        _gf_switch = [[UISwitch alloc]init];
        [_gf_switch addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _gf_switch;
}




- (void)switchStatusChanged:(UISwitch *)sender{
    if(self.switchChangeBlock)self.switchChangeBlock(sender.on);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
