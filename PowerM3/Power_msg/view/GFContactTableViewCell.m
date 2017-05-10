//
//  GFContactTableViewCell.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/6.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFContactTableViewCell.h"
#import "GFContactInformation+CoreDataProperties.h"
#import "GFContactMessageRecord+CoreDataProperties.h"
#import "NSDate+Extension.h"
@implementation GFContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImageView.layer.masksToBounds = YES;

    // Initialization code
}

- (void)configGFContactTableViewCellWithContactInfo:(GFContactInformation *)info messageRecord:(GFContactMessageRecord *)record{
    
    self.headImageView.layer.cornerRadius = CGRectGetHeight(self.headImageView.frame)/2;
    [self.headImageView gf_loadImagesWithURL:POWERSERVERFILEPATH(info.userHeadImage)];
    
    self.titleLabel.text = info.userName;
    self.subTitleLabel.text = record.textChatContent;
    self.dateLabel.text = [record.date timeInfo];
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
