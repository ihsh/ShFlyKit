//
//  WeatherConfig.swift
//  SHKit
//
//  Created by hsh on 2020/1/7.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//天气配置
class WeatherConfig: NSObject {
    //打雷
    class Thunder:NSObject{
        public var color:UIColor = UIColor.white                    //颜色
        public var startY:CGFloat = 10                              //起点
        public var startRange:UInt32 = 20                           //起点动态范围
        public var endY:CGFloat = ScreenSize().height/2.0           //终点
        public var endRange:UInt32 = 100                            //终点的动态范围
        public var delayRange:UInt32 = 5                            //下一次的时间间隔范围
        public var flashRange:UInt32 = 5                            //画闪电的调用次数
        public var lightBase:Int = 5                                //分支数
        public var lightRange:UInt32 = 3                            //分支数动态范围
        public var xRandomRange:UInt32 = 5                          //每一次在X轴的变化范围
        public var YRandomRange:UInt32 = 5                          //每一次在Y轴饿变化范围
        public var lineBaseW:CGFloat = 0.5                          //线宽
        public var lineRangeW:UInt32 = 20                           //线宽动态范围/10.0
    }
    //下雨
    class Rain: NSObject {
        public var count:Int = 80                                   //同时出现的点数
        public var images:UInt32 = 3                                //图片资源数
        public var from:CGPoint = CGPoint(x: -10, y: -150)          //起点
        public var to:CGPoint = CGPoint(x: 50, y: ScreenSize().height/3.0)//终点
        public var timeBase:Int = 5                                 //时间基础
        public var timeRange:Int = 5                                //时间动态范围
        public var imagePrefix:String = "ele_rainLine"              //图片资源名前缀 png
    }
    //下雪
    class Snow: NSObject {
        public var count:UInt32 = 100                               //雪花的数量
        public var from:CGPoint = CGPoint(x: 0, y: -200)            //起点
        public var toY:CGFloat = ScreenSize().height                //终点
        public var rotateDuration:UInt32 = 5                        //旋转一圈的时间
        public var baseDuration:UInt32 = 5                          //动画最短时间
        public var rangeDuration:UInt32 = 5                         //增加的时间的随机范围
        public var baseWidth:UInt32 = 10                            //基准宽度
        public var widthRange:UInt32 = 5                            //浮动宽度范围
        public var xRange:UInt32 = UInt32(ScreenSize().width)       //起点X的范围
        public var yRange:UInt32 = 100                              //起点Y的范围
        public var image:UIImage = UIImage.name("ele_snow")         //雪花图片
    }
    //太阳
    class Sun:NSObject{
        public var rotationDuration:CGFloat = 80                    //自旋时间
        public var center:CGPoint = CGPoint(x: ScreenSize().height*0.1, y: ScreenSize().height*0.1)//中心店位置
        public var sunImage:UIImage = UIImage.name("ele_sunnySun")  //太阳图片
        public var sunWidth:CGFloat = 200
        public var shineImage:UIImage? = UIImage.name("ele_sunnySunshine")//耀斑图片
        public var shineWidth:CGFloat = 500
    }
}



//粒子发射的配置
class EmitterConfig:NSObject{
    public var content:UIImage!                 //粒子的图片
    public var size = CGSize(width: ScreenSize().width, height: 1)
    public var position = CGPoint(x: ScreenSize().width/2.0, y: -60)
    
    public var birthRate:Float = 15             //每秒产生速率(最终数量=layer速率*cell速率)
    public var lifeTime:Float = 10              //粒子存活时间
    public var velocity:CGFloat = 20            //速率
    public var velocityRange:CGFloat = 20       //速率浮动范围
    public var yAcceleration:CGFloat = 100      //Y轴加速度
    public var emissionLongitude:CGFloat = CGFloat.pi/4.0*3.0   //初始方向朝下
    public var spin:CGFloat = 0                 //自旋速度
    public var scale:CGFloat = 0.3              //缩放比例
    public var scaleRange:CGFloat = 0.3         //缩放比例浮动范围
    
}
