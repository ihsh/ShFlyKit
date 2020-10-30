//
//  DateExtension.swift
//  SHKit
//
//  Created by hsh on 2019/9/9.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//日期的扩展
public extension Date{
    ///Variable
    static private let calendar:NSCalendar = NSCalendar.init(identifier: .gregorian)!                   //公历
    static private let localCalendar:NSCalendar = NSCalendar.init(calendarIdentifier: .chinese)!        //农历
    //保存变量
    static private var montherDays:[String:String] = [:]            //母亲节的日期  ["年份":"月-日"]
    static private var fatherDays:[String:String] = [:]             //父亲节
    static private var easterDays:[String:String] = [:]             //复活节
    static private var thanksgivingDays:[String:String] = [:]       //感恩节
    
    
    ///偏移月份得到的时间
    func offsetMonthDate(_ offset:Int,middle:Bool = false)->Date{
        let components:NSDateComponents = Date.calendar.components([.year,.month,.day], from: self) as NSDateComponents;
        //定位到当月中间日子
        if middle == true{
            components.day = 15;
        }
        //年份减
        let year = offset / 12;
        components.year += year;
        //月份
        let month = offset % 12;
        let comMonth = components.month;
        if comMonth + month < 1 {
            components.month = 12 - abs(comMonth + month);
            components.year -= 1;
        }else if comMonth + month > 12 {
            components.month = comMonth + month - 12;
            components.year += 1;
        }else{
            components.month += month;
        }
        let date:Date = Date.calendar.date(from: components as DateComponents)!;
        return date;
    }
    
    
    //获取年月日
    func dateForYMD()->(Int,Int,Int){
        let components:NSDateComponents = Date.calendar.components([.year,.month,.day], from: self) as NSDateComponents;
        return (components.year,components.month,components.day);
    }
    
    
    //当月总天数
    func totolDaysInMonth()->Int{
        let total = NSCalendar.current.range(of: .day, in: .month, for: self)?.count ?? 0;
        return total;
    }
    
    
    //返回每个月的第一天 0-6 周日到周六
    func firstWeekDayInMonth(sundayFirst:Bool = true)->Int{
        let calendar:NSCalendar = Date.calendar;
        let components:NSDateComponents = calendar.components([.year,.month,.day,.weekday], from: self) as NSDateComponents;
        components.day = 1;
        //不重新生成，修改day无效
        let tmpDate = calendar.date(from: components as DateComponents);
        let comp:NSDateComponents = calendar.components([.year,.month,.day,.weekOfMonth,.weekday,.weekdayOrdinal], from: tmpDate!) as NSDateComponents;
        let firstWeek = comp.weekday;
        return sundayFirst ? firstWeek - 1 : firstWeek;
    }
    
    
    //日期的星期
    func weekDayOfDay(sundayFirst:Bool = true)->Int{
        let calendar:NSCalendar = Date.calendar;
        let components:NSDateComponents = calendar.components([.year,.month,.day,.weekday], from: self) as NSDateComponents;
        let week = components.weekday;
        return sundayFirst ? week - 1 : week;
    }
    
    
    //是否是这个月
    func isCurent(focusDay:Bool = false)->Bool{
        let components:NSDateComponents = Date.calendar.components([.year,.month,.day,.weekday], from: self) as NSDateComponents;
        let curenCom:NSDateComponents = Date.calendar.components([.year,.month,.day,.weekday], from: Date()) as NSDateComponents;
        if focusDay {
            return (components.year == curenCom.year && components.month == curenCom.month && components.day == curenCom.day);
        }else{
            return (components.year == curenCom.year && components.month == curenCom.month);
        }
    }
    
    
    //普通农历
    func lunalText()->String{
        let days = ["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十",
                    "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十",
                    "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"];
        let months = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"];
        //农历
        let localCompo:NSDateComponents = Date.localCalendar.components([.year,.month,.day], from: self) as NSDateComponents;
        var result:String!
        //月首的第一天
        if localCompo.day - 1 == 0 {
            result = months[localCompo.month - 1];
        }else{
            //每个月的第几天
            result = days[localCompo.day - 1]
        }
        return result;
    }
    
    
    //农历节日
    func lunalHoliday()->String?{
        let localCompo:NSDateComponents = Date.localCalendar.components([.year,.month,.day], from: self) as NSDateComponents;
        let month = localCompo.month;
        let day = localCompo.day;
        //固定的农历节日
        let chineseHolidays = ["1-1":"春节","1-15":"元宵节","5-5":"端午节","7-7":"七夕节","7-15":"中元节",
                               "8-15":"中秋节","9-9":"重阳节","12-8":"腊八","12-23":"北方小年","12-24":"南方小年"];
        let tmpKey = String(format: "%ld-%ld", month,day);
        var final:String?
        if chineseHolidays.keys.contains(tmpKey){
            final = chineseHolidays[tmpKey];
        }else if month == 12 && day > 26{//减少计算次数
            //动态的农历节日-春节
            let nextDay = Date.init(timeInterval: 3600 * 24, since: self);
            let compo = Date.localCalendar.components([.year,.month,.day], from: nextDay);
            //下一天就是新年第一天的话
            if compo.month == 1 && compo.day == 1{
                final = "除夕夜";
            }
        }
        return final;
    }
    
    
    
    //获取公历的节日
    static func getGregorianHoliday(_ year:Int,month:Int,day:Int)->String?{
        let fixDays = ["1-1":"元旦","2-14":"情人节","3-12":"植树节","4-1":"愚人节","5-1":"劳动节",
                       "5-4":"青年节","6-1":"儿童节","7-1":"建党节","8-1":"建军节","9-10":"教师节",
                       "10-1":"国庆节","10-31":"万圣节","12-24":"平安夜","12-25":"圣诞节"];
        //月-日
        let tmpKey = String(format: "%ld-%ld", month,day);
        //在当前当中
        var final:String?
        if fixDays.keys.contains(tmpKey){
            final = fixDays[tmpKey];
        }else{
            //复用的比较函数
            func compare(key:String,compare:String?,festival:String){
                if compare != nil{
                    if key == compare!{
                        final = festival;
                    }
                }
            }
            //循环遍历体
            func enumarate(days:Int,count:Int,weekDay:Int,dic:inout [String:String])->String?{
                let dateFormat:DateFormatter = DateFormatter();
                dateFormat.dateFormat = "yyyy-MM-dd";
                var num = 0;
                for i in 1...days {
                    let date = dateFormat.date(from: String(format: "%ld-%ld-%ld", year,month,i));
                    let week = date!.weekDayOfDay();
                    if week == weekDay {
                        num += 1;
                    }
                    if num >= count {
                        let str = String(format: "%ld-%ld", month,i);
                        dic[String(format: "%ld", year)] = str;
                        return str;
                    }
                }
                return nil;
            }
            //动态的公历节日--父亲节(6月第三个星期日)，母亲节(5月第二个星期日),复活节(公式),感恩节(每年11月第四个星期四)
            if month == 5 {
                var monthDay = Date.montherDays[String(format: "%ld", year)];
                if monthDay == nil {
                    monthDay = enumarate(days: 31, count: 2, weekDay: 0, dic: &Date.montherDays);
                }
                compare(key: tmpKey, compare: monthDay,festival: "母亲节");
            }else if month == 6 {
                var father = Date.fatherDays[String(format: "%ld", year)];
                if father == nil {
                    father = enumarate(days: 30, count: 3, weekDay: 0, dic: &Date.fatherDays);
                }
                compare(key: tmpKey, compare: father,festival: "父亲节");
            }else if month == 11{
                var thanks = Date.thanksgivingDays[String(format: "%ld", year)];
                if thanks == nil{
                    thanks = enumarate(days: 30, count: 4, weekDay: 4, dic: &Date.thanksgivingDays);
                }
                compare(key: tmpKey, compare: thanks,festival: "感恩节");
            }else if (month == 3 || month == 4 && (year >= 1900 && year <= 2099)) {
                var easter = Date.easterDays[String(format: "%ld", year)];
                if easter == nil {
                    let N:Int = year - 1900;
                    let A:Int = N % 19;
                    let Q:Int = N / 4;
                    let B:Int = (7 * A + 1) / 19;
                    let M:Int = (11 * A + 4 - B) % 29;
                    let W:Int = (N + Q + 31 - M) % 19;
                    let final:Int = 25 - M - W;
                    if final <= 0 {
                        easter = String(format: "3-%ld", 31-final);
                    }else{
                        easter = String(format: "4-%ld", final);
                    }
                    Date.easterDays[String(format: "%ld", year)] = easter!;
                }
                compare(key: tmpKey, compare: easter,festival: "复活节");
            }
        }
        return final;
    }
    
    
    //返回农历的年份
    static func lunalYear(_ year:Int)->String{
        //0是为了计算方便，是整除的时候，其实是整除数
        let tiangan = ["4":"甲","5":"乙","6":"丙","7":"丁","8":"戊","9":"已","0":"庚","1":"辛","2":"壬","3":"癸"];
        let dizhi = ["4":"子","5":"丑","6":"寅","7":"卯","8":"辰","9":"巳","0":"午","11":"未","12":"申","1":"酉","2":"戌","3":"亥"];
        let rate = year % 10;
        let value1 = tiangan[String(format: "%ld", rate)];
        let remain = year % 12;
        let value2 = dizhi[String(format: "%ld", remain)];
        return value1!+value2!;
    }
    
    
    //获取一年的24节气分布  --  返回格式 ["1-5":"小寒"]
    static func get24SolarDay(_ year:Int)->[(String,String)]{
        //数据--[月份:[节气:[21世纪C值，20世纪C值]]]
        let solars = ["1":["小寒":[5.4055,6.11],"大寒":[20.12,20.84]],
                      "2":["立春":[3.87,4.15],"雨水":[18.73,18.73]],
                      "3":["惊蛰":[5.63,5.63],"春分":[20.646,20.646]],
                      "4":["清明":[4.81,5.59],"谷雨":[20.1,20.888]],
                      "5":["立夏":[5.52,6.318],"小满":[21.04,21.86]],
                      "6":["芒种":[5.678,6.5],"夏至":[21.37,2.20]],
                      "7":["小暑":[7.108,7.928],"大暑":[22.83,23.65]],
                      "8":["立秋":[7.5,8.35],"处暑":[23.23,23.95]],
                      "9":["白露":[7.646,8.44],"秋分":[23.042,23.822]],
                      "10":["寒露":[8.318,9.098],"霜降":[23.438,24.218]],
                      "11":["立冬":[7.438,8.218],"小雪":[22.36,23.08]],
                      "12":["大雪":[7.18,7.9],"冬至":[21.94,22.60]]];
        //例外情况
        let exceptions = ["冬至":["-1":["1918","2021"]],"小寒":["-1":["2019"],"1":["1982"]],
                          "大寒":["1":["2082"]],"雨水":["-1":["2026"]],"春分":["1":["2084"]],
                          "立夏":["-1":["闰年"]],"小满":["1":["2008"]],"芒种":["1":["1902"]],
                          "小暑":["1":["1925","2016"]],"大暑":["1":["1922"]],"立秋":["1":["2002"]],
                          "白露":["1":["1927"]],"秋分":["1":["1942"]],"霜降":["1":["2089"]],
                          "立冬":["1":["2089"]],"小雪":["1":["1978"]],"大雪":["1":["1954"]]];
        //通用公式--年份的后2位*0.2422加C取整数l减L(闰年数)
        func calculDayYDCL(_ year:Int,C:Double)->Int{
            let D = 0.2422;
            let Y = year % 100;
            var num = Int(Double(Y) * D + C);
            num = num - Int(Y/4);
            return num;
        }
        //修正例外的数据
        func correctSolar(_ name:String,num:Int,year:Int)->Int{
            let data = exceptions[name];
            var result = num;
            if data != nil {//存在例外情况
                //内部函数
                func enumarateStrs(_ strs:[String],factor:Int,year:Int,origin:Int)->Int{
                    let tmp = String(format: "%ld", year);
                    for str in strs {
                        if str == tmp {
                            return origin + factor;
                        }else if str == "闰年" {
                            if ((year % 4 == 0 && year % 100 != 0)||(year % 400 == 0)) {
                                return origin + factor;
                            }
                        }
                    }
                    return origin;
                }
                //遍历例外数据
                for it in data!{
                    let key:String = it.key;
                    let array:[String] = it.value ;
                    //减一天
                    if key == "-1"{
                        result = enumarateStrs(array, factor: -1, year: year, origin: num);
                    }else if key == "1"{//加一天
                        result = enumarateStrs(array, factor: 1, year: year, origin: num);
                    }
                }
                
            }
            return result;
        }
        //结果集
        var result:[(String,String)] = [];
        //从1到12月
        for i in 1...12 {
            //对应月份的数据
            let data = solars[String(format: "%ld", i)];
            //两个节气遍历
            for it in data!{
                var C:Double = 0
                //20世纪和21世纪C值不一样
                if year > 2000 {
                    C = it.value.first!;
                }else{
                    C = it.value.last!;
                }
                //计算出来的值
                var num = calculDayYDCL(year, C: C);
                //例外修正
                num = correctSolar(it.key, num: num,year: year);
                //最终结果
                result.append((String(format: "%ld-%ld", i,num),it.key));
            }
        }
        return result;
    }
    
    
    //返回日期数
    static func daysCount(year:Int,month:Int)->Int{
        switch month {
        case 1,3,5,7,8,10,12:
            return 31;
        case 2:
            if (year % 4 == 0 && year % 100 != 0 || (year % 400 == 0)){
                return 29;
            }else{
                return 28;
            }
        default:
            return 30;
        }
    }
    
    
}

