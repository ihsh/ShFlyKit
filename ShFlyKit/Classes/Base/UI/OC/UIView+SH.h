//
//  UIView+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (SH)
@property (nonatomic,assign) CGFloat x;                     //x
@property (nonatomic,assign) CGFloat y;                     //y
@property (nonatomic,assign) CGFloat width;                 //宽
@property (nonatomic,assign) CGFloat height;                //高
@property (assign,nonatomic,readonly) CGFloat maxX;         //在X轴的最大值
@property (assign,nonatomic,readonly) CGFloat maxY;         //在Y轴的最大值
@property (assign,nonatomic,readonly) CGFloat centerX;      //中心点的X坐标
@property (assign,nonatomic,readonly) CGFloat centerY;      //中心点的Y坐标


//当前视图所在的视图控制
- (UIViewController *)viewController;
//简单的添加圆角
-(void)setRadius:(CGFloat)radius;
//设置部分圆角
-(void)setRadius:(CGFloat)radius corners:(UIRectCorner)corner;
//设置阴影
-(void)setShadow:(UIColor*)shadowColor opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius;


//返回某个颜色的视图
+(UIView *)viewForColor:(UIColor *)color;
//虚线
+(UIView*)viewForDashLineSize:(CGSize)size color:(UIColor *)lineColor length:(NSUInteger)length space:(NSUInteger)space;

//返回视图点击在整个窗口的位置
-(CGRect)onTouchRect;
//截图
-(UIImage*)normalSnapshotImage;
//两点的中点
-(CGPoint)midPointOfPoint:(CGPoint)p1 point2:(CGPoint)p2;

@end

