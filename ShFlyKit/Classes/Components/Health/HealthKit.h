//
//  HealthKit.h
//  SHKit
//
//  Created by hsh on 2019/2/13.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>
@class HeartRateItem;


@interface HealthKit : NSObject
@property(nonatomic,strong)HKHealthStore *healthStore;      //健康信息储存类


//设置需要请求的权限集合-可选
-(void)setReadType:(NSSet*)readTypes write:(NSSet*)writeTypes;


//生成今天的谓词
+(NSPredicate*)predicateForToday;
//生成现在到几天前的凌晨的时间区间谓词
+(NSPredicate*)predicateForPreday:(NSInteger)dayCount;



//获取步行+跑步距离
-(void)distanceForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double distance, NSError *error))handler;
//获取步数
-(void)stepForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double step, NSError *error))handler;
//骑行距离
-(void)cycleForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double distance, NSError *error))handler;
//活动能量
-(void)calorieActiveForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double calorie, NSError *error))handler;
//静息能量
-(void)calorieBasalForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double energy, NSError *error))handler;
//心率
-(void)healthRateForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(NSArray<HeartRateItem*> *rates , NSError *error))handler;
//睡眠秒数
-(void)sleepAnalysis:(void(^)(double sec, NSError *error))handler;
//身高-米
-(void)height:(void(^)(double kilometers, NSError *error))handler;
//体重-克
-(void)mass:(void(^)(double gm, NSError *error))handler;
//获取生日
-(void)birthQuery:(void(^)(NSDateComponents *birth,NSError *error))handler;
//获取性别
-(void)sexQuery:(void(^)(HKBiologicalSexObject *sex,NSError *error))handler;




//写入步数
-(void)writeStepStartTime:(NSDate*)start duration:(NSInteger)duration step:(NSInteger)stepCount;
//写入步行跑步距离
-(void)writeStepDistanceStartTime:(NSDate*)start duration:(NSInteger)duration distance:(double)distance;
//写入骑行距离
-(void)writeCycleStartTime:(NSDate*)start duration:(NSInteger)duration distance:(double)distance;
//写入睡眠时间
-(void)writeSleepAnalysis:(NSDate*)startDate sec:(double)sec;

@end








//心跳的模型
@interface HeartRateItem : NSObject
@property(nonatomic,assign)NSInteger rate;
@property(nonatomic,strong)NSString *device;
@property(nonatomic,strong)NSString *date;
@property(nonatomic,strong)NSString *time;
@end
