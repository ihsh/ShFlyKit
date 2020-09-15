//
//  HealthKit.m
//  SHKit
//
//  Created by hsh on 2019/2/13.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "HealthKit.h"
#import "NSDate+SH.h"


@interface HealthKit ()
@property(nonatomic,strong)NSSet *readTypes;        //读取的类型集合
@property(nonatomic,strong)NSSet *writeType;        //写入的类型集合
@end


@implementation HealthKit


///MARK-Load
- (instancetype)init{
    self = [super init];
    if (self) {
        self.healthStore = [[HKHealthStore alloc]init];
        self.readTypes = [self dataReadPermitSet];
        self.writeType = [self dataWritePermitSet];
    }
    return self;
}


//设置读写类型
-(void)setReadType:(NSSet *)readTypes write:(NSSet *)writeTypes{
    if (readTypes != nil) {
        self.readTypes = readTypes;
    }
    if (writeTypes != nil) {
        self.writeType = writeTypes;
    }
}


///MARK-Private Method
//需要读权限的集合
-(NSSet*)dataReadPermitSet{
    HKQuantityType *stepCount = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];               //步数
    HKQuantityType *walkRuning = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]; //步行距离
    HKQuantityType *cycle = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];             //骑行距离
    HKQuantityType *basicalEnergy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];   //静息能量
    HKQuantityType *activeEnergy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];   //活动能量
    HKQuantityType *heartRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];               //心率
    HKQuantityType *height = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];                     //身高
    HKQuantityType *weight = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];                   //体重
    HKCategoryType *sleep = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];                 //睡眠分析
    //不可写属性--需要用户自己设置才行
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];     //出生日期
    HKCharacteristicType *sexType      = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];   //性别
    return [NSSet setWithObjects:stepCount,walkRuning,cycle,basicalEnergy,activeEnergy,heartRate,sleep,height,weight,birthdayType,sexType, nil];
}


//写入权限的集合
-(NSSet*)dataWritePermitSet{
    HKQuantityType *stepCount = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *walkRunning = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *cycle = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKCategoryType *sleep = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKQuantityType *height = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weight = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    return [NSSet setWithObjects:stepCount,walkRunning,cycle,sleep,height,weight,nil];
}


//获取权限
-(void)getPermissions:(HKObjectType*)type completion:(void(^)(BOOL success,NSString *desc))Handle{
    if ([[UIDevice currentDevice]systemVersion].doubleValue >= 8.0) {//判断系统版本是否大于等于8.0
        if ([HKHealthStore isHealthDataAvailable]) {//是否支持健康
            if (self.healthStore == nil) {
                self.healthStore = [[HKHealthStore alloc]init];
            }
            //注册
            HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:type];
            if (status == HKAuthorizationStatusSharingDenied) {//有些类型，明明允许了，这个函数仍然返回拒绝
                Handle(NO,@"用户拒绝");
            }else if (status == HKAuthorizationStatusSharingAuthorized){
                Handle(YES,@"已通过");
            }else{
                [self.healthStore requestAuthorizationToShareTypes:self.writeType readTypes:self.readTypes completion:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        Handle(YES,@"提交申请");//允许，或者不允许都走这里
                    }
                }];
            }
        }else{
            Handle(NO,@"健康不可用");
        }
    }else{
        Handle(NO,@"系统版本不支持");
    }
}


//格式化错误信息
-(NSError*)formatError:(NSString*)desc{
    NSString *domain = @"healthkit";//自定义的名字
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};//包装错误描述
    NSError *error = [[NSError alloc]initWithDomain:domain code:-1001 userInfo:userInfo];//自定义的code,无含义
    return error;
}



///MARK-Interface
//生成今天的谓词
+(NSPredicate*)predicateForToday{
    NSDate *now = [NSDate date];//当前时间
    NSDate *start = [now startOfDay];//今天凌晨0.00
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:now options:HKQueryOptionStrictStartDate];
    return predicate;
}


//生成现在到几天前的谓词
+(NSPredicate*)predicateForPreday:(NSInteger)dayCount{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];//当前时间
    NSDate *start = [calendar dateByAddingUnit:NSCalendarUnitDay value:-dayCount toDate:now options:0];//当前时间往前回溯几天
    start = [start startOfDay];//回溯时间的当天0.00
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:now options:HKQueryOptionStrictStartDate];
    return predicate;
}


///读取
//步行+跑步距离
-(void)distanceForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double distance, NSError *error))handler{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    [self getPermissions:type completion:^(BOOL success, NSString *desc) {
        HKStatisticsQuery *staticQuery = [[HKStatisticsQuery alloc]initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
            HKQuantity *quantity = result.sumQuantity;
            NSInteger stepCount = [quantity doubleValueForUnit:[HKUnit meterUnit]];
            if (stepCount == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(stepCount,error);
            }
        }];
        [self.healthStore executeQuery:staticQuery];
    }];
}


//步数
-(void)stepForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double step, NSError *error))handler{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [self getPermissions:type completion:^(BOOL success, NSString *desc) {
        //间隔一天
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = 1;
        //统计查询-统计，按source分开
        HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[NSDate date] intervalComponents:dateComponents];
        collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
            
            NSInteger stepCount = 0;
            //所有的统计数据
            for (HKStatistics *statistic in result.statistics) {
                //健康中的总步数
                if (stepCount == 0) {
                    stepCount = [[statistic sumQuantity]doubleValueForUnit:[HKUnit countUnit]];
                }
                //过滤作弊的数据
                for (HKSource *source in statistic.sources) {
                    //每个source的名字
                    if ([source.bundleIdentifier containsString:@"com.apple.health"] == false) {
                        stepCount -= [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                    }
                }
            }
            if (stepCount == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(stepCount,error);
            }
        };
        [self.healthStore executeQuery:collectionQuery];
    }];
}


//骑行距离
-(void)cycleForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double distance, NSError *error))handler{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    [self getPermissions:type completion:^(BOOL success, NSString *desc) {
        HKStatisticsQuery *staticQuery = [[HKStatisticsQuery alloc]initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
            HKQuantity *quantity = result.sumQuantity;
            NSInteger distance = [quantity doubleValueForUnit:[HKUnit meterUnit]];
            if (distance == 0 && success == NO ) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(distance,error);
            }
        }];
        [self.healthStore executeQuery:staticQuery];
    }];
}


//活动能量
-(void)calorieActiveForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double calorie, NSError *error))handler{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    [self getPermissions:type completion:^(BOOL success, NSString *desc) {
        HKStatisticsQuery *staticQuery = [[HKStatisticsQuery alloc]initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
            HKQuantity *quantity = result.sumQuantity;
            NSInteger calorie = [quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
            if (calorie == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(calorie,error);
            }
        }];
        [self.healthStore executeQuery:staticQuery];
    }];
}


//静息能量
-(void)calorieBasalForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(double energy, NSError *error))handler{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
    [self getPermissions:type completion:^(BOOL success, NSString *desc) {
        HKStatisticsQuery *staticQuery = [[HKStatisticsQuery alloc]initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
            HKQuantity *quantity = result.sumQuantity;
            NSInteger calorie = [quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
            if (calorie == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                 handler(calorie,error);
            }
        }];
        [self.healthStore executeQuery:staticQuery];
    }];
}


//心率
-(void)healthRateForPredicate:(NSPredicate*)predicate completionHandler:(void(^)(NSArray<HeartRateItem*> *rates , NSError *error))handler{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    [self getPermissions:type completion:^(BOOL success, NSString *desc) {
        HKQueryAnchor *anchor = [HKQueryAnchor anchorFromValue:HKAnchoredObjectQueryNoAnchor];
        HKAnchoredObjectQuery *heartQuery = [[HKAnchoredObjectQuery alloc]initWithType:type predicate:predicate anchor:anchor limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            if (sampleObjects != nil) {
                for (HKSample *sample in sampleObjects) {
                    NSString *desc = sample.description;//转换成文字
                    NSArray *strArr = [desc componentsSeparatedByString:@" "];
                    if (strArr.count > 3) {
                        NSString *rate = strArr.firstObject;  //心率值
                        NSString *device = [strArr objectAtIndex:3];//设备名
                        NSString *date = [strArr objectAtIndex:strArr.count-3];//日期 yyyy-MM-dd
                        NSString *time = [strArr objectAtIndex:strArr.count-2];//时间 hh:mm:ss
                        HeartRateItem *item = [[HeartRateItem alloc]init];
                        item.rate = rate.integerValue;
                        item.device = device;
                        item.date = date;
                        item.time = time;
                        [tmpArray addObject:item];
                    }
                }
            }
            if (tmpArray.count == 0 && success == NO) {
                handler([NSArray array],[self formatError:desc]);
            }else{
                handler(tmpArray,error);
            }
        }];
        [self.healthStore executeQuery:heartQuery];
    }];
}


//睡眠分析
-(void)sleepAnalysis:(void(^)(double sec, NSError *error))handler{
    HKSampleType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    [self getPermissions:sleepType completion:^(BOOL success, NSString *desc) {
        NSSortDescriptor *sortDescripter = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
        NSDate *start = [[NSDate date]startOfDay];
        NSDate *end = [NSDate date];
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:end options:HKQueryOptionNone];
        HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:sleepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescripter] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            //睡眠秒数
            NSInteger totalSleep = 0;
            for (HKCategorySample *sample in results) {
                if (sample.value == 1) {
                    NSTimeInterval time = [sample.endDate timeIntervalSinceDate:sample.startDate];
                    totalSleep += time;
                }
            }
            if (totalSleep == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(totalSleep,error);
            }
        }];
        [self.healthStore executeQuery:query];
    }];
}


//获取身高
-(void)height:(void(^)(double kilometers, NSError *error))handler{
    HKQuantityType *height = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    [self getPermissions:height completion:^(BOOL success, NSString *desc) {
        NSSortDescriptor *sortDescripter = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
        HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:height predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescripter] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            HKQuantitySample *sample = results.firstObject;
            double height = 0;
            if (sample) {
                HKQuantity *quantity = sample.quantity;
                height = [quantity doubleValueForUnit:[HKUnit meterUnit]];
            }
            if (height == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(height,error);
            }
        }];
        [self.healthStore executeQuery:query];
    }];
}



//获取体重
-(void)mass:(void(^)(double gm, NSError *error))handler{
    HKQuantityType *mass = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    [self getPermissions:mass completion:^(BOOL success, NSString *desc) {
        NSSortDescriptor *sortDescripter = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
        HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:mass predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescripter] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            HKQuantitySample *sample = results.firstObject;
            double mass = 0;
            if (sample) {
                HKQuantity *quantity = sample.quantity;
                mass = [quantity doubleValueForUnit:[HKUnit gramUnit]];
            }
            if (mass == 0 && success == NO) {
                handler(-1,[self formatError:desc]);
            }else{
                handler(mass,error);
            }
        }];
        [self.healthStore executeQuery:query];
    }];
}


//获取生日
-(void)birthQuery:(void(^)(NSDateComponents *birth,NSError *error))handler{
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    [self getPermissions:birthdayType completion:^(BOOL success, NSString *desc) {
        if (success) {
            NSError *error;
            NSDateComponents *birth = [self.healthStore dateOfBirthComponentsWithError:&error];
            handler(birth,error);
        }else{
            handler(nil,[self formatError:desc]);
        }
    }];
}


//获取性别
-(void)sexQuery:(void(^)(HKBiologicalSexObject *sex,NSError *error))handler{
    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    [self getPermissions:sexType completion:^(BOOL success, NSString *desc) {
        if (success) {
            NSError *error;
            HKBiologicalSexObject *sex = [self.healthStore biologicalSexWithError:&error];
            handler(sex,error);
        }else{
            HKBiologicalSexObject *object = [[HKBiologicalSexObject alloc]init];
            handler(object,[self formatError:desc]);
        }
    }];
}






///写入
//写入步数
-(void)writeStepStartTime:(NSDate*)start duration:(NSInteger)duration step:(NSInteger)stepCount{
    if (start == nil) {
        start = [NSDate dateWithTimeInterval:-duration sinceDate:[NSDate date]];
    }
    //结束日期
    NSDate *endDate = [NSDate dateWithTimeInterval:duration sinceDate:start];
    HKQuantity *stepQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepCount];
    HKQuantityType *stepConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //创建样本数据
    HKQuantitySample *stepConsumedSample = [HKQuantitySample quantitySampleWithType:stepConsumedType quantity:stepQuantityConsumed startDate:start endDate:endDate];
    [self.healthStore saveObject:stepConsumedSample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"写入成功");
        }
    }];
}



//写入步行距离
-(void)writeStepDistanceStartTime:(NSDate*)start duration:(NSInteger)duration distance:(double)distance{
    if (start == nil) {
        start = [NSDate dateWithTimeInterval:-duration sinceDate:[NSDate date]];
    }
    //结束时间
    NSDate *endDate = [NSDate dateWithTimeInterval:duration sinceDate:start];
    HKQuantity *distanceQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
    HKQuantityType *distanceConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    //样本数据
    HKQuantitySample *distanceConsumedSample = [HKQuantitySample quantitySampleWithType:distanceConsumedType quantity:distanceQuantityConsumed startDate:start endDate:endDate];
    [self.healthStore saveObject:distanceConsumedSample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"写入成功");
        }
    }];
}



//添加睡眠的记录
-(void)writeSleepAnalysis:(NSDate*)startDate sec:(double)sec{
    if (startDate == nil) {
        startDate = [NSDate dateWithTimeInterval:-sec sinceDate:[NSDate date]];
    }
    //结束日期
    NSDate *endDate = [NSDate dateWithTimeInterval:sec sinceDate:startDate];
    //类型
    HKCategoryType *sleepCatrgory = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    //创建样本
    HKCategorySample *sample = [HKCategorySample categorySampleWithType:sleepCatrgory value:HKCategoryValueSleepAnalysisAsleep startDate:startDate endDate:endDate];
    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"写入成功");
        }
    }];
}



//添加骑行的记录
-(void)writeCycleStartTime:(NSDate*)start duration:(NSInteger)duration distance:(double)distance{
    if (start == nil) {
        start = [NSDate dateWithTimeInterval:-duration sinceDate:[NSDate date]];
    }
    NSDate *endDate = [NSDate dateWithTimeInterval:duration sinceDate:start];
    HKQuantity *cycleQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
    HKQuantityType *cycleConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKQuantitySample *cycleConsumedSample = [HKQuantitySample quantitySampleWithType:cycleConsumedType quantity:cycleQuantityConsumed startDate:start endDate:endDate];
    [self.healthStore saveObject:cycleConsumedSample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"写入成功");
        }
    }];
}



@end















@implementation HeartRateItem

@end
