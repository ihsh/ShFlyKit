//
//  NSString+Animation.m
//  SHKit
//
//  Created by hsh on 2019/8/22.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "NSString+Animation.h"
#import <CoreGraphics/CoreGraphics.h>
#import "UIBezierPath+TextPath.h"


@implementation NSString (Animation)


- (void)animateOnView:(UIView *)aView lineWidth:(CGFloat)width rect:(CGRect)aRect font:(UIFont *)aFont color:(UIColor *)aColor duration:(CGFloat)aDuration{
    // 创建文字路径
    UIBezierPath *path = [UIBezierPath bezierPathWithText:self font:aFont];
    // 创建路径图层
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = aRect;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    pathLayer.geometryFlipped = NO;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [aColor CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = width;
    pathLayer.lineJoin = kCALineJoinBevel;
    [aView.layer addSublayer:pathLayer];
    // 绘图动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];// strokeStart 是擦除效果
    pathAnimation.duration = aDuration;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.removedOnCompletion = YES;
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}


@end
