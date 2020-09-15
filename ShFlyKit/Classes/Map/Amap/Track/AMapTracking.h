//
//  AMapTracking.h
//  AMapTracking
//
//  Created by hsh on 2018/12/10.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@protocol AMapTrackingDelegate;

@interface AMapTracking : NSObject
///代理对象
@property (nonatomic, assign) id<AMapTrackingDelegate> delegate;
///初始化时需要提供的 mapView
@property (nonatomic, unsafe_unretained) MAMapView *mapView;
///轨迹回放动画时间
@property (nonatomic, assign) NSTimeInterval duration;
///边界差值
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
///标注对应的annotation
@property (nonatomic, strong, readonly) MAPointAnnotation *annotation;
///轨迹对应的overlay
@property (nonatomic, strong, readonly) MAPolyline *polyline;



///Tracking的初始化方法---轨迹经纬度数组---经纬度个数
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
///执行轨迹回放动画
- (void)execute;
///清理对应的annotation. overlay, shapeLayer
- (void)clear;
@end


@protocol AMapTrackingDelegate <NSObject>
@optional
///轨迹回放即将开始
- (void)willBeginTracking:(AMapTracking *)tracking;
///轨迹回放完成
- (void)didEndTracking:(AMapTracking *)tracking;
@end

