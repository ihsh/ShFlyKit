//
//  CalendarUIConfig.swift
//  SHKit
//
//  Created by hsh on 2019/9/10.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//选中的样式
enum CalendarSelectStyle{
    case CircleFill,SquareFill,SquarePath
}


///显示的配置
class CalendarUIConfig: NSObject {
    //variable
    //选中时的样式
    public var selectStyle:CalendarSelectStyle = .SquarePath
    //滚动之后默认勾选的日子-0默认勾选当前的天，没有则最后一天，不为0则固定某天
    public var monthSelectDay:Int = 0
    //是否显示当月之前和之后的日期
    public var showHeadTail:Bool = true
    //显示内容
    public var showContent:Bool = true
    
    //日历单元格高度
    public var cellHeight:CGFloat = 60
    //非当月数据的透明度
    public var notCurrentAlpha:CGFloat = 0.3
    //圈选的线宽
    public var strokeLineWidth:CGFloat = 2
    //圈选的圆角
    public var strokeCornerRadius:CGFloat = 10
    //选中填充/圈选的颜色色
    public var fillStrokeColor:UIColor = UIColor.black
    //选中时字体颜色
    public var fillTextColor:UIColor?;
    
    //今日的颜色
    public var todayColor:UIColor = UIColor.colorHexValue("F2F2F2");
    //工作日的日期颜色
    public var dayWorkColor:UIColor = UIColor.colorRGB(red: 68, green: 68, blue: 68)
    //周末的日期颜色
    public var dayWeekendColor:UIColor = UIColor.colorRGB(red: 186, green: 37, blue: 47)
    //休息日的背景颜色
    public var restBackColor:UIColor = UIColor.colorRGB(red: 66, green: 142, blue: 89)
    //加班的背景颜色
    public var overBackColor:UIColor = UIColor.colorRGB(red: 186, green: 37, blue: 47)
    //普通农历的内容颜色
    public var norLunalColor:UIColor = UIColor.colorRGB(red: 131, green: 132, blue: 132)
    //节气的内容颜色
    public var solarsColor:UIColor = UIColor.colorRGB(red: 108, green: 165, blue: 129)
    //假日的内容颜色
    public var holidayColor:UIColor = UIColor.colorRGB(red: 186, green: 37, blue: 47)
    
    //日期数字的字体
    public var dayFont:UIFont = kBoldFont(20)
    //内容的字体
    public var contentFont:UIFont = kFont(12)
    //休假/加班的字体
    public var restOverFont:UIFont = kFont(9)
    
}
