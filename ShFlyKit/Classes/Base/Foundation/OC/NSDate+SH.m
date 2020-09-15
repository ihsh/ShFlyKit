//
//  NSDate+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSDate+SH.h"

@implementation NSDate (SH)


//时间戳转成HHmm的时间格式输出
+ (NSString *)toHHmm:(NSInteger)timeInternal{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInternal];
    return [date toHHmm];
}


//获取时间戳对应的年份
+ (NSInteger)yearWithInterval:(NSInteger)timeInterval{
    time_t tt = (time_t)(timeInterval);
    struct tm *tm = localtime(&tt);
    return tm->tm_year + 1900;
}


//获取时间戳对应的月份
+ (NSInteger)monthWithInterval:(NSInteger)timeInterval{
    time_t tt = (time_t)(timeInterval);
    struct tm *tm = localtime(&tt);
    return tm->tm_mon + 1;
}


//获取时间戳对应的天数
+ (NSInteger)dayWithInterval:(NSInteger)timeInterval{
    time_t tt = (time_t)(timeInterval);
    struct tm *tm = localtime(&tt);
    return tm->tm_mday;
}


//判断是否是今天
- (BOOL)isToday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}


//年份
- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}


//月份
- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}


//天数
- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}



//昨天的开始
- (NSDate *)startOfYestoday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:-[comps hour] - 24];
    [comps setMinute:-[comps minute]];
    [comps setSecond:-[comps second]];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//昨天的结束
- (NSDate *)endOfYestoday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:-[comps hour]];
    [comps setMinute:-[comps minute]];
    [comps setSecond:-[comps second] - 1];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//今年的开始
- (NSDate *)startOfYear{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear fromDate:self];
    [comps setYear:([comps year])];
    return [calendar dateFromComponents:comps];
}


//今年的结束
- (NSDate *)endOfYear{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitSecond fromDate:self];
    [comps setYear:([comps year] + 1)];
    [comps setSecond:-1];
    return [calendar dateFromComponents:comps];
}


//今天的开始
- (NSDate *)startOfDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        return [calendar startOfDayForDate:self];
    }
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:-[comps hour]];
    [comps setMinute:-[comps minute]];
    [comps setSecond:-[comps second]];
    [comps setNanosecond:-[comps nanosecond]];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//今天的结束
- (NSDate *)endOfDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:-[comps hour] + 24];
    [comps setMinute:-[comps minute]];
    [comps setSecond:-[comps second] - 1];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//明天的开始
- (NSDate *)startOfTomorrow{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:-[comps hour] + 24];
    [comps setMinute:-[comps minute]];
    [comps setSecond:-[comps second]];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//明天的结束
- (NSDate *)endOfTomorrow{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:-[comps hour] + 48];
    [comps setMinute:-[comps minute]];
    [comps setSecond:-[comps second] - 1];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//一年中的周数
- (NSInteger)weekOfYear{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    return [comps weekOfYear];
}


//这周的开始
- (NSDate *)startOfWeek{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSInteger weekDay = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfYear forDate:self];
    [comps setDay:([comps day] - weekDay + 1)];
    return [calendar dateFromComponents:comps];
}


//这周的结束
- (NSDate *)endOfWeek{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSInteger weekDay = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfYear forDate:self];
    [comps setDay:([comps day] - weekDay + 1 + 7)];
    [comps setSecond:-1];
    return [calendar dateFromComponents:comps];
}


//特定的年月日
-(NSDate *)startOfSpecicalYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    return [calendar dateFromComponents:comps];
}


//今天特定的月日
-(NSDate *)startOfSpecicalMonth:(NSInteger)month Day:(NSInteger)day{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    [comps setMonth:month];
    [comps setDay:day];
    return [calendar dateFromComponents:comps];
}


//这个月特定的日期
-(NSDate *)startOfSpecicalDay:(NSInteger)day{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour ) fromDate:self];
    [comps setDay:day];
    return [calendar dateFromComponents:comps];
}


//这个月的起始
- (NSDate *)startOfMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    return [calendar dateFromComponents:comps];
}


//这个月的结束
- (NSDate *)endOfMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    [comps setDay:range.length];
    [comps setHour:23];
    [comps setMinute:59];
    [comps setSecond:59];
    return [calendar dateFromComponents:comps];
}


//时间直接通过hh:mm设置时间
- (NSDate *)setHHmm:(NSString *)HHmm{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self];
    if (HHmm != nil && HHmm.length > 0) {
        NSArray *array = [HHmm componentsSeparatedByString:@":"];
        if (array != nil && array.count >= 2) {
            NSInteger hour = [[array objectAtIndex:0] integerValue];
            NSInteger min = [[array objectAtIndex:1] integerValue];
            [comps setHour:hour];
            [comps setMinute:min];
        }
    }
    return [calendar dateFromComponents:comps];
}


//生成hh:mm的时间格式字符串
- (NSString *)toHHmm{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self];
    return [NSString stringWithFormat:@"%.2d:%.2d", (int)comps.hour, (int)comps.minute];
}


//两个日期之间的差值
- (NSInteger)daysToDate:(NSDate *)date{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:self options:0];
    return [comps day];
}


//两个日期的月份差
- (NSInteger)monthsToDate:(NSDate *)date{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&fromDate interval:NULL forDate:self];
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&toDate interval:NULL forDate:date];
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:fromDate toDate:toDate options:0];
    return comps.month;
}



+ (NSArray *)monthsFrom:(NSInteger)beginTime toDate:(NSInteger)endTime{
    if (beginTime == 0 || endTime == 0) {
        return @[];
    }
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:beginTime - 86400 * 31];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *beginComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:beginDate];
    NSDateComponents *endComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:endDate];
    
    NSInteger year = beginComps.year;
    NSInteger month = beginComps.month;
    NSMutableArray *months = [NSMutableArray array];
    while (year <= endComps.year || months.count < 3) {
        [months addObject:@(year * 100 + month++)];
        if (month > 12) {
            year++;
            month = 1;
        }
        if (months.count < 3) {
            continue;
        }
        if (year == endComps.year && month > endComps.month) {
            break;
        }
    }
    return months;
}


//- (MonthDataInfo *)fetchDataInfoForSection:(NSInteger)section
//{
//    NSNumber *month = [self monthWithSection:section];
//    NSInteger curYear = month.integerValue / 100;
//    NSInteger curMonth = month.integerValue % 100;
//
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:[NSDate date]];
//
//    MonthDataInfo *dataInfo = [[MonthDataInfo alloc] init];
//    if (curMonth == comps.month) {
//        dataInfo.today = comps.day;
//    }
//
//    [comps setYear:curYear];
//    [comps setMonth:curMonth];
//    [comps setDay:1];
//
//    NSDate *startOfMonth = [calendar dateFromComponents:comps];
//    comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:startOfMonth];
//
//
//    dataInfo.indexOfFirstDay = comps.weekday - 1;
//    dataInfo.daysOfMonth = [self daysOfMonth:curMonth inYear:curYear];
//
//    if (section > 0) {
//        NSNumber *lastMonth = [self monthWithSection:section - 1];
//        dataInfo.daysOfLastMonth = [self daysOfMonth:lastMonth.integerValue % 100 inYear:lastMonth.integerValue / 100];
//    }
//
//    if (_delegate && [_delegate respondsToSelector:@selector(calendarDaysView:itemsDictAtMonth:)]) {
//        dataInfo.itemsDict = [_delegate calendarDaysView:self itemsDictAtMonth:month];
//    }
//
//    return dataInfo;
//}


+ (NSInteger)daysOfMonth:(NSInteger)month inYear:(NSInteger)year{
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 2:
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                return 29;
            } else {
                return 28;
            }
        default:
            return 30;
    }
}


@end
