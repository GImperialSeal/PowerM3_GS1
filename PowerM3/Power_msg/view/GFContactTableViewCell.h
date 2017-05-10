//
//  GFContactTableViewCell.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/6.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GFContactMessageRecord;
@class GFContactInformation;
@interface GFContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (void)configGFContactTableViewCellWithContactInfo:(GFContactInformation *)info messageRecord:(GFContactMessageRecord *)record;
@end
