//
//  GFPopView.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/28.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFPopView.h"
#import "DXPopover.h"

@implementation GFPopView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        UITableView *tableView = [[UITableView alloc]initWithFrame:self.bounds];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 44;
        tableView.scrollEnabled = NO;
        tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
        
        [self addSubview:tableView];
    }
    return self;
}

+ (void)popTableViewAtPoint:(CGPoint)point inView:(UIViewController *)vc completion:(void(^)(NSInteger index))complete titles:(NSString *)titles,...{
    NSMutableArray *array = [NSMutableArray array];
    
    if (titles != nil) {
        id eachObject;
        va_list argumentList;
        if (titles) {
            
            [array addObject:titles];
            
            va_start(argumentList, titles);
            while ((eachObject = va_arg(argumentList, id))) {
                
                [array addObject:eachObject];
            }
            va_end(argumentList);
        }
    }
    
    
    GFPopView *pop = [[self alloc]initWithFrame:CGRectMake(0, 0, 150, 44 *array.count)];
    pop.sourceArray = array;
    pop.popover = [DXPopover popover];
    pop.completeBlock = complete;
    [pop.popover showAtPoint:point popoverPostion:DXPopoverPositionDown withContentView:pop inView:vc.view];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    }
    
    cell.textLabel.text = self.sourceArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.sourceArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.popover remove];
    if (self.completeBlock) {
        self.completeBlock(indexPath.row);
    }
}





@end
