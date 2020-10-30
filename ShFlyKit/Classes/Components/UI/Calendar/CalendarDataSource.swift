//
//  CalendarData.swift
//  SHKit
//
//  Created by hsh on 2019/9/4.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


//日历数据来源
public class CalendarDataSource: NSObject {
    //variable
    public static var restDays:[String:[String:Bool]] = [:]    //休假加班的信息 例如 ["2019":["1-1":true,"1-2":true,"12-31":false]]
    
    
    //传入一个当月的日期，创建当月的数据
    class public func initData(_ date:Date)->CalendarSectionData{
        let result = CalendarSectionData();
        //这个月的第一天是周几
        result.firstWeekDay = date.firstWeekDayInMonth();
        //日期格式
        let dateFormat:DateFormatter = DateFormatter();
        dateFormat.dateFormat = "yyyy-MM-dd";
        //创建日数据
        func initCellData(year:Int,month:Int,day:Int)->CalendarData{
            let data = CalendarData()
            data.year = year;
            data.month = month;
            data.day = day;
            return data;
        }
        //创建内容--农历节日--公历节日--节气--普通农历
        func contentOfDay(year:Int,month:Int,day:Int,date:Date,solars:[(String,String)], data:inout CalendarData)->String{
            //农历
            let lunal:String = date.lunalText()
            //24节气
            var solar:String?
            let dateStr = String(format: "%ld-%ld", month,day);
            for item in solars {
                if item.0 == dateStr {
                    solar = item.1;
                    break;
                }
            }
            //公历节日
            let holiday:String? = Date.getGregorianHoliday(year, month: month, day: day);
            //农历节日
            let lunalHoliday:String? = date.lunalHoliday();
            //排序
            if lunalHoliday != nil {
                data.holidayType = 3
                return lunalHoliday!;
            }else if holiday != nil{
                data.holidayType = 2;
                return holiday!;
            }else if solar != nil{
                data.holidayType = 1;
                return solar!;
            }else{
                if lunal.contains("月"){
                    data.holidayType = 1;   //月首
                }
                return lunal;
            }
        }
        //上个月月末的几天
        let preDate = date.offsetMonthDate(-1,middle: true);            //上个月日期
        let preDays = preDate.totolDaysInMonth();                       //上个月共几天
        let preIndex = preDays - result.firstWeekDay + 1;               //上个月在这个月显示的起始日期
        if preIndex <= preDays {
            let tmp1 = preDate.dateForYMD();
            //节假日
            let holidays1 = CalendarDataSource.restDays[String(format: "%ld", tmp1.0)];
            let solars1 = Date.get24SolarDay(tmp1.0);                                   //节气
            for i in preIndex...preDays{
                let date = dateFormat.date(from: String(format: "%ld-%ld-%ld", tmp1.0,tmp1.1,i));
                var dayData = initCellData(year: tmp1.0, month: tmp1.1, day: i);
                dayData.content = contentOfDay(year: tmp1.0, month: tmp1.1, day: i, date: date!, solars: solars1, data: &dayData);
                let key = String(format: "%ld-%ld", tmp1.1,i);
                if (holidays1 != nil && holidays1!.keys.contains(key)) {
                    let bool:Bool = holidays1![key]!;
                    dayData.isRest = bool;
                    dayData.isOverTime = bool == false;
                }
                let week = date?.weekDayOfDay();
                dayData.isWork = (week != 0 && week != 6);
                result.days.append(dayData);
            }
        }
        //当前月所有
        let tmp2 = date.dateForYMD();
        result.year = tmp2.0;
        result.month = tmp2.1;
        let solars2 = Date.get24SolarDay(tmp2.0);
        let holidays2 = CalendarDataSource.restDays[String(format: "%ld", tmp2.0)];
        for i in 1...date.totolDaysInMonth(){
            let date = dateFormat.date(from: String(format: "%ld-%ld-%ld", tmp2.0,tmp2.1,i));
            var dayData = initCellData(year: tmp2.0, month: tmp2.1, day: i);
            dayData.content = contentOfDay(year: tmp2.0, month: tmp2.1, day: i, date: date!, solars: solars2, data: &dayData);
            let key = String(format: "%ld-%ld", tmp2.1,i);
            if (holidays2 != nil && holidays2!.keys.contains(key)){
                let bool:Bool = holidays2![key]!;
                dayData.isRest = bool;
                dayData.isOverTime = bool == false;
            }
            dayData.isCurrent = true;
            let week = date?.weekDayOfDay();
            dayData.isWork = (week != 0 && week != 6);
            dayData.isToday = (date?.isCurent(focusDay: true))!;
            result.days.append(dayData);
        }
        result.daysCount = date.totolDaysInMonth();
        //下个月开始的几天
        let rows:Int = Int(ceil(Double(result.days.count)/7.0));
        let count:Int = rows * 7 - result.days.count;
        if count > 1 {
            let nextDate = date.offsetMonthDate(1,middle: true);
            let tmp3 = nextDate.dateForYMD();
            let solars3 = Date.get24SolarDay(tmp3.1 == 12 ? tmp3.0 + 1 : tmp3.0);
            let holidays3 = CalendarDataSource.restDays[String(format: "%ld", tmp3.0)];
            for i in 1...count {
                let date = dateFormat.date(from: String(format: "%ld-%ld-%ld", tmp3.0,tmp3.1,i));
                var dayData = initCellData(year: tmp3.0, month: tmp3.1, day: i);
                dayData.content = contentOfDay(year: tmp3.0, month: tmp3.1, day: i, date: date!, solars: solars3, data: &dayData);
                let key = String(format: "%ld-%ld", tmp3.1,i);
                if (holidays3 != nil && holidays3!.keys.contains(key)){
                    let bool:Bool = holidays3![key]!;
                    dayData.isRest = bool;
                    dayData.isOverTime = bool == false;
                }
                let week = date?.weekDayOfDay();
                dayData.isWork = (week != 0 && week != 6);
                result.days.append(dayData);
            }
        }
        result.lineCount = rows;
        return result;
    }

    
}



//日历每天的数据
public class CalendarData: NSObject {
    public var day:Int!                 //日期
    public var month:Int!               //月份
    public var year:Int!                //年份
    public var content:String!          //显示顺序--农历节日--节气--公历节日--农历
    public var isCurrent:Bool = false   //是否是当月的
    public var isToday:Bool = false     //是否是今日
    public var extraInfo:AnyObject!     //其他数据
    //节假日信息
    public var isRest:Bool = false      //是否是额外休息日
    public var isWork:Bool!             //是否是工作日
    public var isOverTime:Bool = false  //是否加班
    public var holidayType:Int = 0      //0无节日 1节气 2公历节日 3农历节日
}



//一个月数据
public class CalendarSectionData:NSObject {
    public var year:Int!                        //年份
    public var month:Int!                       //月份
    public var firstWeekDay:Int!                //每个月第一天是星期几 0-6 周日-周六
    public var daysCount:Int!                   //当月的天数
    public var lineCount:Int!                   //一周7天显示的行数
    public var days:[CalendarData] = []         //月份中天的信息
    public var hasExtraInfo:Bool = false        //附加信息是否初始化，用于减少数据运算
    
    //是否是当月 -1前月 0 1下月
    public func isCurrentMonth(_ index:Int)->Int{
        for (i,value) in days.enumerated(){
            if i == index && value.isCurrent == false {
                if i < daysCount {
                    return 1;
                }else {
                    return 2;
                }
            }
        }
        return 0
    }
}
