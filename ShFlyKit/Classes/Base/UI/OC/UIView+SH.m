//
//  UIView+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UIView+SH.h"

@implementation UIView (SH)

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)width{
    return self.bounds.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height{
    return self.bounds.size.height;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)maxX{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)maxY{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)centerX{
    return self.center.x;
}


- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = CGPointMake(self.centerX, self.centerY);
    center.x = centerX;
    self.center = center;
}


- (CGFloat)centerY{
    return self.center.y;
}


- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = CGPointMake(self.centerX, self.centerY);
    center.y = centerY;
    self.center = center;
}



-(void)setRadius:(CGFloat)radius{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}


-(void)setRadius:(CGFloat)radius corners:(UIRectCorner)corner{
    if (@available(iOS 11.0,*)) {
        self.layer.cornerRadius = radius;
        self.layer.maskedCorners = (CACornerMask)corner;
    }else{
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
}


- (UIViewController *)viewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return (UIViewController *)next;
}


-(void)setShadow:(UIColor*)shadowColor opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius{
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
}







+(UIView *)viewForColor:(UIColor *)color{
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = color;
    return line;
}


+(UIView*)viewForDashLineSize:(CGSize)size color:(UIColor *)lineColor length:(NSUInteger)length space:(NSUInteger)space{
    UIView *line = [[UIView alloc]init];
    line.frame = CGRectMake(0, 0, size.width, size.height);
    line.backgroundColor = UIColor.clearColor;
    //是否水平
    BOOL horizontal = size.width > size.height;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [shapeLayer setPosition:CGPointMake(size.width/2,size.height/2)];
    [shapeLayer setFillColor:UIColor.clearColor.CGColor];
    //设置虚线颜色
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //设置虚线宽度
    [shapeLayer setLineWidth:horizontal ? size.height : size.width];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:(int)length],[NSNumber numberWithInt:(int)space],nil]];
    //设置路径
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, 0, 0);
    if (horizontal) {
         CGPathAddLineToPoint(pathRef, NULL,size.width, 0);
    }else{
         CGPathAddLineToPoint(pathRef, NULL,0,size.height);
    }
    [shapeLayer setPath:pathRef];
    CGPathRelease(pathRef);
    //把绘制好的虚线添加上来
    [line.layer addSublayer:shapeLayer];
    return line;
}


-(CGRect)onTouchRect{
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    return [self convertRect: self.bounds toView:window];
}


- (UIImage *)normalSnapshotImage{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}


-(CGPoint)midPointOfPoint:(CGPoint)p1 point2:(CGPoint)p2{
    return CGPointMake((p1.x+p2.x)/2.0, (p1.y+p2.y)/2.0);
}


@end
