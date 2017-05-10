//
//  GFContactCell.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/14.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GFContactInformation;
@interface GFContactCell : UITableViewCell
- (void)configCellWithContactModel:(GFContactInformation *)model;

@end
