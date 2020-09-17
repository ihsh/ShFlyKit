//
//  SHLabelPath.h
//  SHLabel
//
//  Created by hsh on 19/8/22.
//  Copyright © 2019年 hsh. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//对SHPath类的OC封装
@interface SHLabelPath : NSObject
//构建路径起点
+(instancetype)pathForBeginPoint:(CGPoint)point;

//移动起点
-(void)moveBeginPoint:(CGPoint)point;
//添加直线
-(void)addLineToPoint:(CGPoint)point;
//添加圆曲线，半径由上一条路径结束点和圆心共同确定
-(void)addArcWithCentrePoint:(CGPoint)centrePoint angle:(CGFloat)angle;
//添加贝塞尔曲线
-(void)addCurveToPoint:(CGPoint)point anchorPoint:(CGPoint)anchorPoint;
//添加自定义曲线
-(void)addCustomPoint:(NSArray *)customPoint;
//强制刷新路径点坐标数组
-(void)setNeedsUpdate;

//获取路径长度
-(CGFloat)getLength;
//获取等距路径点数组
-(NSArray<NSValue*> *)getPosTan:(CGFloat)precision;
//深度复制一条路径
-(SHLabelPath *)clone;
@end
