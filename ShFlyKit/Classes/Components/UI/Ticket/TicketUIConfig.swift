//
//  TicketUIConfig.swift
//  SHKit
//
//  Created by hsh on 2019/11/25.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///UI配置
class TicketUIConfig: NSObject {
    //Variable
    public var screen = TicketUIConfig.Screen()
    public var indicater = TicketUIConfig.Indicater()
    public var thumbnail = TicketUIConfig.Thumbnail()
    public var scroll = TicketUIConfig.Scroll()
    public var head = TicketUIConfig.Head()
    public var image = TicketUIConfig.Image()
    public var backColor:UIColor = UIColor.colorHexValue("F3F4F5");
    

    //荧幕
    class Screen:NSObject{
        public var backColor = UIColor.colorHexValue("F3F4F5")          //荧幕背景色
        public var screenText:String?                                   //银幕中显示的文字
        public var font:UIFont = kFont(10)                              //银幕中显示的文字字号
        public var textColor:UIColor = .black                           //银幕中显示的文字颜色
        public var textYspan:CGFloat = 16                               //银幕中显示的文字距顶部距离
        public var width:CGFloat = 150                                  //荧幕的宽度-弧线宽度
        public var zoomWidth:CGFloat = 40                               //可扩展宽度
        public var zoomHeight:CGFloat = 5                               //可拓展高度
        public var zoomRate:CGFloat = 0.95                              //放大比例缩小
        public var curveY:CGFloat = 20                                  //弧线的Y
        public var scrollHeight:CGFloat = 40                            //滚动视图高度
        public var height:CGFloat = 25                                  //中间文本所在视图高度
        public var layerColor:UIColor = UIColor.red                     //弧线颜色
        public var layerWidth:CGFloat = 2                               //弧线线宽
        public var shadowRadius:CGFloat = 6                             //阴影半径
        public var shadowoOffset:CGFloat = 5                            //阴影Y轴偏移
        public var shadowOpacity:Float = 0.9                            //阴影透明度
    }
    
    
    //左侧指示条
    class Indicater:NSObject{
        public var leftSpan:CGFloat = 6                                 //距左边距
        public var backColor = UIColor.colorHexValue("4A4A4A")          //背景色
        public var alpha:CGFloat = 0.3                                  //透明度
        public var cornerRadius:CGFloat = 8                             //圆角
        public var width:CGFloat = 16                                   //宽度
        public var font:UIFont = kFont(8)                               //文字字号
        public var textColor:UIColor = UIColor.white;                   //文字颜色
    }
    
    
    //头部
    class Head:NSObject{
        public var height:CGFloat = 40                                  //整个高度
        public var subWidth:CGFloat = 80                                //子视图宽度
        public var btnWidth:CGFloat = 16                                //子视图中按钮宽高
        public var btnHeight:CGFloat = 13                               //子视图中按钮宽高
        public var font:UIFont = kFont(10)                              //子视图中文本字号
        public var textColor:UIColor = .black                           //子视图中文本颜色
        public var norText:String = "可选"
        public var soldText:String = "已售"
        public var bestZoneText:String = "最佳观影区"
        public var layerWidth:CGFloat = 1                               //最佳观影区线宽
        public var layerColor:UIColor = .red                            //最佳观影区线颜色
        public var layerDash = [NSNumber.init(value: 2),NSNumber.init(value: 2)]
    }
    
    
    //缩略图
    class Thumbnail:NSObject{
        public var backColor = UIColor.colorHexValue("000000", alpha: 0.4)//背景色
        public var gridColor = UIColor.white                              //可选颜色
        public var soldColor = UIColor.red                                //已售颜色
        public var selectColor:UIColor = UIColor.colorRGB(red: 122, green: 218, blue: 57)           //选中颜色
        public var zoneFillColor =  UIColor.colorRGB(red: 228, green: 0, blue: 22, alpha: 0.5)      //区域颜色
        public var cornerRadius:CGFloat = 1                               //单元格圆角
        public var viewLeftSpan:CGFloat = 2                               //距父视图左边距
        public var xSpan:CGFloat = 2                                      //单元格间水平间隔
        public var ySpan:CGFloat = 2                                      //单元格间垂直间隔
        public var grid:CGFloat = 5                                       //单元格宽高
        public var space:CGFloat = 3                                      //单元格距边的间距 左-下-右
        public var topSpace:CGFloat = 16                                  //单元格距顶部间距
        public var hideTimes:Double = 1.5                                 //不操作后多久隐藏时间间隔
    }
    
    
    //滚动视图
    class Scroll:NSObject{
        public var topSpan:CGFloat = 80                                     //距离最顶部间距
        public var xMargin:CGFloat = 5                                      //水平方向上座位之间的间距
        public var yMargin:CGFloat = 10                                     //垂直方向上座位之间的间距
        public var maximumZoomScale:CGFloat = 1.5                           //最大放缩比例，最小是1
        public var clickZoomScale:CGFloat = 1.2                             //点击时放大的比例
        public var separatorColor:UIColor = .gray                           //分割线虚线的颜色
        public var separatorLineWidth:CGFloat = 0.5                         //分割线线宽
        public var separatorlineDashPattern = [NSNumber.init(value: 2),NSNumber.init(value: 2)] //分割线虚线样式
        public var zoneColor:UIColor = .red                                 //区域线颜色
        public var zoneLineWidth:CGFloat = 0.5                              //区域线虚线线宽
        public var zonelineDashPattern = [NSNumber.init(value: 2),NSNumber.init(value: 2)] //区域线虚线样式
    }
    
    
    //图片
    class Image: NSObject {
        public var soldImage:UIImage? = UIImage.name("seat_sold")           //已售状态位置的图片
        public var norImage:UIImage? = UIImage.name("seat_available")       //正常状态位置的图片
        public var selectImage:UIImage? = UIImage.name("seat_selected")     //选中状态位置的图片
        public var bestZoneImage:UIImage?                                   //最佳观影区自定义图片
    }
    
    
}
