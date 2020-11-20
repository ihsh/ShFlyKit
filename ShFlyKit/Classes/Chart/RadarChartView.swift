//
//  RadarChartView.swift
//  SHKit
//
//  Created by mac on 2020/9/10.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


///雷达图
public class RadarChartView: UIView {
    //Public
    public var showSize:CGSize = CGSize(width: 300, height: 300);   //显示的大小
    //Private
    public private(set) var data:RadarShowData!//数据
    private var pointsGrid:[[CGPoint]] = [] //网格的数组
    private var pointsPlot:[CGPoint] = []   //端点的数组
    private var pointsDesc:[CGPoint] = []   //描述文字的坐标
    private var chartPlotLayer:CAShapeLayer!//雷达图层
    
    
    //绘制视图
    public func drawData(_ data:RadarShowData){
        //至少3个端点
        guard data.dataSet.count >= 3 else {
            return;
        }
        self.data = data;
        //重新计算每段分隔,计算一个压缩比例
        let length = CGFloat(data.plotCircles) * data.valueDivider * 2.0;
        if (length > self.showSize.width - data.margin * 2.0) {
            let half = (self.showSize.width - data.margin * 2.0)/2.0;
            var divider:CGFloat = ceil(half / CGFloat(data.plotCircles));
            divider = max(divider,2);
            let rate:CGFloat = divider / self.data.valueDivider;
            self.data.valueRate = rate;
        }
        //计算
        self.calculateChartPoints();
        //绘制
        self.drawChart();
    }
    
    
    //系统绘制方法
    public override func draw(_ rect: CGRect) {
        super.draw(rect);
        //设置属性
        let ctx = UIGraphicsGetCurrentContext();
        ctx?.setStrokeColor(data.lineColor.cgColor);
        ctx?.setFillColor(UIColor.clear.cgColor);
        ctx?.setLineWidth(1);
        ctx?.setLineJoin(.round);
        //绘制环线
        for (i,array) in pointsGrid.enumerated() {
            for (j,pos) in array.enumerated() {
                if j == 0 {
                    ctx?.move(to: pos);
                }else{
                    ctx?.addLine(to: pos);
                }
            }
            ctx?.closePath();
        }
        //绘制从中心到端点的线段
        let last = pointsGrid.last;
        for pos in last! {
            ctx?.move(to: CGPoint(x: showSize.width/2.0, y: showSize.height/2.0));
            ctx?.addLine(to: pos);
        }
        ctx?.strokePath();
        //绘制文字
        if data.showDesc {
            for (i,item) in data.dataSet.enumerated() {
                let str:NSString = item.desc as! NSString;
                let pos:CGPoint = pointsDesc[i];
                let attributes = NSMutableDictionary();
                attributes.setValue(data.fontSize, forKey: NSAttributedStringKey.font.rawValue);
                attributes.setValue(data.fontColor, forKey: NSAttributedStringKey.foregroundColor.rawValue);
                let width:CGFloat = str.width(with: data.fontSize);
                let height:CGFloat = str.height(forWidth: CGFloat(MAXFLOAT), font: data.fontSize);
                let rect:CGRect = CGRect(x: pos.x - width/2.0, y: pos.y - height/2.0, width: width, height: height);
                str.draw(in: rect, withAttributes: attributes as! [NSAttributedStringKey : Any]);
            }
        }
        
    }
    
    
    
    ///Private
    private func calculateChartPoints(){
        //计算基础值
        var angles:[CGFloat] = [];
        var values:[CGFloat] = [];
        var descs:[String] = [];
        
        let count = CGFloat(data.dataSet.count);
        let pi:CGFloat = CGFloat(M_PI);
        //计算角度值
        for (i,item) in data.dataSet.enumerated(){
            values.append(item.value);
            descs.append(item.desc);
            let angleValue:CGFloat = ((data.clockWise == true) ? (pi - CGFloat(i) * pi * 2 / count) : (-pi + CGFloat(i) * pi * 2 / count));
            angles.append(angleValue);
        }
        //计算端点
        pointsPlot.removeAll();
        for (i,value) in values.enumerated() {
            let angle:CGFloat = angles[i];
            let length = value * data.valueRate;
            let x:CGFloat = showSize.width/2.0 + length * CGFloat(sinf(Float(angle)));
            let y:CGFloat = showSize.height/2.0 + length * CGFloat(cosf(Float(angle)));
            pointsPlot.append(CGPoint(x: x, y: y));
        }
        //计算网格
        //每个多边形的径向距离
        var lengths:[CGFloat] = [];
        for i in 0...data.plotCircles {
            lengths.append(CGFloat(i)*data.valueDivider*data.valueRate);
        }
        pointsGrid.removeAll();
        pointsDesc.removeAll();
        for (i,length) in lengths.enumerated() {
            var array:[CGPoint] = [];
            for (j,angle) in angles.enumerated() {
                let x = showSize.width/2.0 + length * CGFloat(sinf(Float(angle)));
                let y = showSize.height/2.0 + length * CGFloat(cosf(Float(angle)));
                //当最外层时
                if i == lengths.count - 1 {
                    let str:NSString = data.dataSet[j].desc as! NSString;
                    let width = str.width(with: data.fontSize);
                    let height = str.height(forWidth: CGFloat(MAXFLOAT), font: data.fontSize);
                    var t = sqrt(width*width+height*height+data.descMargin);
                    if j == 0 {
                        t = height + data.descMargin;
                    }
                    let tmpMargin = t/2.0;
                    let descX = showSize.width/2.0 + (length + tmpMargin) * CGFloat(sinf(Float(angle)));
                    let descY = showSize.height/2.0 + (length + tmpMargin) * CGFloat(cosf(Float(angle)));
                    pointsDesc.append(CGPoint(x: descX, y: descY));
                }
                array.append(CGPoint(x: x, y: y));
            }
            pointsGrid.append(array);
        }
        
    }
    
    
    //执行绘制
    private func drawChart(){
        //绘制
        self.setNeedsDisplay();
        //绘制圈层
        self.drawPlotLayer();
        //添加动画
        if data.displayAnimated {
            self.addAnimationIfNeed();
        }
    }
    
    
    //绘制雷达图层
    private func drawPlotLayer(){
        
        if self.chartPlotLayer == nil {
            self.chartPlotLayer = CAShapeLayer();
            self.chartPlotLayer.lineCap = kCALineCapButt;
            self.chartPlotLayer.lineWidth = 1.0;
            self.chartPlotLayer.frame = CGRect(x: 0, y: 0, width: self.showSize.width, height: self.showSize.height);
            self.layer.addSublayer(chartPlotLayer);
        }
        //计算路径
        let path = CGMutablePath();
        for (index,pos) in pointsPlot.enumerated() {
            if index == 0 {
                path.move(to: pos);
            }else{
                path.addLine(to: pos);
            }
        }
        path.closeSubpath();
        chartPlotLayer.fillColor = data.fillColor.cgColor;
        chartPlotLayer.strokeColor = data.strokeColor.cgColor;
        chartPlotLayer.path = path;
    }
    
    
    //添加动画组
    private func addAnimationIfNeed(){
        let scaleAni = CABasicAnimation.init(keyPath: "transform.scale");
        scaleAni.fromValue = 0;
        scaleAni.toValue = 1;
        let opaAni = CABasicAnimation.init(keyPath: "opacity")
        opaAni.fromValue = 0;
        opaAni.toValue = 1;
        let rotateAni = CABasicAnimation.init(keyPath: "transform.rotation.z");
        rotateAni.fromValue = M_PI;
        rotateAni.toValue = 0;
    
        let group = CAAnimationGroup();
        if data.animateRotate {
            group.animations = [scaleAni,opaAni, rotateAni];
        }else{
            group.animations = [scaleAni,opaAni];
        }
        group.duration = data.animateDuration;
        chartPlotLayer.add(group, forKey: "group");
    }
    
    
}



//雷达图显示数据
public class RadarShowData:NSObject{
    public var clockWise:Bool = true       //顺时针
    public var showDesc:Bool = true        //显示描述
    public var displayAnimated:Bool = true //展示动画
    public var animateRotate:Bool = true   //动画中是否旋转
    public var animateDuration:TimeInterval = 1 //动画时长
    
    public var backColor:UIColor = .black  //背景色
    public var lineColor:UIColor = UIColor.colorHexValue("FFFFFF", alpha: 0.4)  //网格线颜色
    public var fontColor:UIColor = .white
    public var fontSize:UIFont = .systemFont(ofSize: 12)
    public var fillColor:UIColor = UIColor.colorHexValue("FFFFFF", alpha: 0.2)  //填充色
    public var strokeColor:UIColor = .white                                     //图层边缘线颜色
    
    public var dataSet:[RadarDataItem] = [] //数据
    public var fixMax:CGFloat = 0           //设置的固定大小
    public var valueDivider:CGFloat = 15    //设置的径向分段距离值
    public var margin:CGFloat = 30          //径向端点与视图边缘的距离
    public var descMargin:CGFloat = 6       //文字区域边缘和端点之间的距离
    public var valueRate:CGFloat = 1        //实际显示的值与valueDivider的比值 压缩比例
    public private(set) var calculMax:CGFloat = 0  //计算得出的最大值
    public private(set) var plotCircles:Int!       //计算得出的多边形个数
    
    
    ///计算值
    public func calculValue(){
        //计算最大值
        var tmp:CGFloat = 0;
        for item in self.dataSet {
            tmp = max(item.value,tmp);
        }
        self.calculMax = tmp;
        //计算多边形数量
        self.plotCircles = Int(ceil(calculMax/valueDivider));
        //固定的间隔
        if (fixMax > 0 && fixMax > valueDivider) {
            self.plotCircles = Int(ceil(fixMax/valueDivider));
        }
    }
    
    
    ///添加一系列值
    public func appendArray(_ array:[RadarDataItem]){
        self.dataSet.append(contentsOf: array);
        self.calculValue();
    }
    
    
    ///子项
    public class RadarDataItem:NSObject{
        public var value:CGFloat!       //值
        public var desc:String!         //描述
        
        public class func initItem(_ value:CGFloat,desc:String?)->RadarDataItem{
            let item = RadarDataItem();
            item.value = value;
            item.desc = desc ?? "";
            return item;
        }
    }
    
    
}
