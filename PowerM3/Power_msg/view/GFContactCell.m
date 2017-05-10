//
//  GFContactCell.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/14.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFContactCell.h"
#import "GFContactInformation+CoreDataProperties.h"
@interface GFContactCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
@implementation GFContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.cornerRadius = 20;
    // Initialization code
    
}

- (void)configCellWithContactModel:(GFContactInformation *)model{
    
    [self.headImage gf_loadImagesWithURL:POWERSERVERFILEPATH(model.userHeadImage)];
    self.titleLabel.text = model.userName;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
