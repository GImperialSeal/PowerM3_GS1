//
//  ProgressView.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/6/6.
//  Copyright © 2016年 shPower. All rights reserved.
//
#define   DEGREES(degrees)  ((M_PI * (degrees))/ 180.f)

#import "GFProgressView.h"

@implementation GFProgressView


- (void)awakeFromNib{
    [super awakeFromNib];
    CGRect frame = self.frame;
    self.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:.2];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = frame.size.height/2;
    
   // http://www.cnblogs.com/YouXianMing/p/3793913.html
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:.2];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.height/2;
    }
    return self;
}

-(void)setProgress:(CGFloat)progress
{
    CGRect rect = self.frame;
    CGFloat width = CGRectGetWidth(rect)-4;
    _gradient.frame =  CGRectMake(2,2,width*_progress, CGRectGetHeight(rect)-4);
    [self setNeedsDisplay];
    _progress = progress;

}
#pragma mark - 绘制渐变色
- (void)drawRect:(CGRect)rect
{
    _gradient = [CAGradientLayer layer];
    
    CGFloat width = CGRectGetWidth(rect)-4;
    
    _gradient.frame =  CGRectMake(2,2,width*_progress, CGRectGetHeight(rect)-4);
    
    // 颜色分配
    _gradient.colors = [NSArray arrayWithObjects:
                       
                       (id)[UIColor lightGrayColor].CGColor,
                       
                       (id)[UIColor colorWithRed:90/255.0 green:151/255.0 blue:255/255.0 alpha:1].CGColor,
                       
                       (id)[UIColor lightGrayColor].CGColor,
                       
                       nil];
    // 起始点
    _gradient.startPoint = CGPointMake(0, 0);
    // 结束点
    _gradient.endPoint   = CGPointMake(0, 1);
    
   // gradient.locations = @[@(-0.2), @(-0.1), @(0)];
    
    _gradient.masksToBounds = YES;
    
    _gradient.cornerRadius = (CGRectGetHeight(rect)- 4) /2;
    
    [self.layer insertSublayer:_gradient atIndex:0];
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(animation:) userInfo:gradient repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];


}

- (void)animation:(NSTimer *)info
{
    CAGradientLayer *gradient = (CAGradientLayer *)info.userInfo;
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"locations"];
    fadeAnim.fromValue = @[@(-0.2), @(-0.1), @(0)];
    fadeAnim.toValue   = @[@(1.0), @(1.1),@(1.2)];
    fadeAnim.duration  = 1.5;
    [gradient addAnimation:fadeAnim forKey:nil];
}


+ (CAShapeLayer *)LayerWithCircleCenter:(CGPoint)point
                                 radius:(CGFloat)radius
                             startAngle:(CGFloat)startAngle
                               endAngle:(CGFloat)endAngle
                              clockwise:(BOOL)clockwise
                        lineDashPattern:(NSArray *)lineDashPattern
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    // 贝塞尔曲线(创建一个圆)
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0)
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:clockwise];
    
    // 获取path
    layer.path = path.CGPath;
    layer.position = point;
    
    // 设置填充颜色为透明
    layer.fillColor = [UIColor clearColor].CGColor;
    
    // 获取曲线分段的方式
    if (lineDashPattern)
    {
        layer.lineDashPattern = lineDashPattern;
    }
    
    return layer;
}



@end
