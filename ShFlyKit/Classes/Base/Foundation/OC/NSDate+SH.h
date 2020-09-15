//
//  NSDate+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (SH)

//时间戳转成HHmm的时间格式输出
+ (NSString *)toHHmm:(NSInteger)timeInternal;
//获取时间戳对应的年份
+ (NSInteger)yearWithInterval:(NSInteger)timeInterval;
//获取时间戳对应的月份
+ (NSInteger)monthWithInterval:(NSInteger)timeInterval;
//获取时间戳对应的天数
+ (NSInteger)dayWithInterval:(NSInteger)timeInterval;

//判断是否是今天
- (BOOL)isToday;

//年份
- (NSInteger)year;
//月份
- (NSInteger)month;
//天数
- (NSInteger)day;


//昨天的开始
- (NSDate *)startOfYestoday;
//昨天的结束
- (NSDate *)endOfYestoday;
//今年的开始
- (NSDate *)startOfYear;
//今年的结束
- (NSDate *)endOfYear;
//今天的开始
- (NSDate *)startOfDay;
//今天的结束
- (NSDate *)endOfDay;
//明天的开始
- (NSDate *)startOfTomorrow;
//明天的结束
- (NSDate *)endOfTomorrow;
//一年中的周数
- (NSInteger)weekOfYear;
//这周的开始
- (NSDate *)startOfWeek;
//这周的结束
- (NSDate *)endOfWeek;

//特定的年月日
- (NSDate *)startOfSpecicalYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day;
//今天特定的月日
- (NSDate *)startOfSpecicalMonth:(NSInteger)month Day:(NSInteger)day;
//这个月特定的日期
- (NSDate *)startOfSpecicalDay:(NSInteger)day;
//这个月的起始
- (NSDate *)startOfMonth;
//这个月的结束
- (NSDate *)endOfMonth;
//时间直接通过hh:mm设置时间
- (NSDate *)setHHmm:(NSString *)HHmm;
//生成hh:mm的时间格式字符串
- (NSString *)toHHmm;
//两个日期之间的差值
- (NSInteger)daysToDate:(NSDate *)date;
//两个日期的月份差
- (NSInteger)monthsToDate:(NSDate *)date;


+ (NSArray *)monthsFrom:(NSInteger)beginTime toDate:(NSInteger)endTime;
//某年某月有多少天
+ (NSInteger)daysOfMonth:(NSInteger)month inYear:(NSInteger)year;

@end

NS_ASSUME_NONNULL_END
