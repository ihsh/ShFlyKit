//
//  LineChartView.swift
//  SHKit
//
//  Created by mac on 2020/9/9.
//  Copyright © 2020 hsh. All rights reserved.
//


import UIKit



//内容如果超出使用的滚动系列
public class LineChartScrollV:UIView ,UIScrollViewDelegate{
    //显示区域
    public var showRect:CGRect = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 300)
    //私有滚动视图
    private var scrollV:UIScrollView!
    private var lineChart:LineChartView!
    
    
    //显示需要滚动的视图
    public func showData(_ data:LineChartData){
        self.backgroundColor = UIColor.white;
        //设置可滚动
        if lineChart == nil {
            scrollV = UIScrollView();
            scrollV.backgroundColor = UIColor.clear;
            scrollV.showsHorizontalScrollIndicator = false;
            scrollV.bounces = false;
            scrollV.delegate = self;
            scrollV.layer.masksToBounds = false;
            self.addSubview(scrollV);
            lineChart = LineChartView();
            lineChart.drawYaxis = false;
            lineChart.showRect = showRect;
            scrollV.addSubview(lineChart);
        }
        lineChart.showData(data);
        scrollV.frame = CGRect(x: lineChart.baseX, y: 0, width: ScreenSize().width-lineChart.baseX, height: lineChart.layerFrame.height+data.margins.bottom);
        lineChart.frame = CGRect(x: 0-lineChart.baseX, y: 0, width: lineChart.layerFrame.width+lineChart.baseX, height: showRect.height);
        scrollV.contentSize = CGSize(width: lineChart.scrollX+lineChart.baseX, height: 0);
        //绘制Y轴
        self.setNeedsDisplay();
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scollX = scrollView.contentOffset.x;
        if scollX < lineChart.data.circleWidth {
            scrollV.layer.masksToBounds = false;
        }else{
            scrollV.layer.masksToBounds = true;
        }
    }
    
    
    //单单绘制Y坐标
    public override func draw(_ rect: CGRect) {
        super.draw(rect);
        let data:LineChartData = lineChart.data;
        //没有数据
        if data == nil {
            return;
        }
        let ctx = UIGraphicsGetCurrentContext();
        ctx?.setStrokeColor(data.lineColor.cgColor);
        ctx?.setLineWidth(data.lineWidth);
        //绘制Y轴
        ctx?.setStrokeColor(data.lineColor.cgColor);
        ctx?.move(to: CGPoint(x: lineChart.baseX, y: lineChart.baseY));
        ctx?.addLine(to: CGPoint(x: lineChart.baseX, y: data.margins.top));
        ctx?.strokePath();
        for (i,pos) in lineChart.yAxisPoints.enumerated() {
            let desc:NSString = lineChart.yAxisValues[i] as NSString;
            let width:CGFloat = desc.width(with: data.font);
            let rect = CGRect(x: pos.x-6-width, y: pos.y, width: width, height: 20);
            let attributes = NSMutableDictionary();
            attributes.setValue(data.font, forKey: NSAttributedStringKey.font.rawValue);
            attributes.setValue(data.fontColor, forKey: NSAttributedStringKey.foregroundColor.rawValue);
            desc.draw(in: rect, withAttributes: attributes as! [NSAttributedStringKey : Any]);
        }
    }
    
    
}


///折线图
public class LineChartView: UIView , CAAnimationDelegate {
    //public
    public var showRect:CGRect = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 300)
    public var drawYaxis:Bool = true                         //绘制U轴
    public private (set) var layerFrame:CGRect!              //显示阴影的图层
    public private (set) var baseX:CGFloat = 0               //左下角的起点X
    public private (set) var baseY:CGFloat = 0               //左下角的起点Y
    public private (set) var scrollX:CGFloat = 0             //可滚动区域
    public private (set) var data:LineChartData!             //数据
    public private (set) var pointsLine:[CGPoint] = []       //线的点
    public private (set) var yAxisPoints:[CGPoint] = []      //Y坐标的点群
    public private (set) var yAxisValues:[String] = []       //Y坐标的值的点群
    public private (set) var xAxisPoints:[CGPoint] = []      //x坐标的点群
    
    
    
    ///Interface
    public func showData(_ data:LineChartData){
        self.data = data;
        self.backgroundColor = UIColor.clear;
        //计算值
        self.calculValues();
        //显示
        self.setNeedsDisplay();
        //显示动画
        
    }

    
    //绘制方法
    public override func draw(_ rect: CGRect) {
        super.draw(rect);
        //没有数据
        if data == nil {
            return;
        }
        let ctx = UIGraphicsGetCurrentContext();
        ctx?.setStrokeColor(data.lineColor.cgColor);
        ctx?.setLineWidth(data.lineWidth);
        //绘制x轴
        ctx?.move(to: CGPoint(x: baseX, y: baseY));
        let rightX = scrollX+baseX+20;
        ctx?.addLine(to: CGPoint(x: rightX, y: baseY));
        ctx?.strokePath();
        for (i,pos) in xAxisPoints.enumerated() {
            let da = self.data.dataSet[i];
            let desc:NSString = da.axisDesc as NSString;
            var rect:CGRect!
            if data.xAxisValueHorizon {
                let width:CGFloat = desc.width(with: data.font);
                rect = CGRect(x: pos.x - width/2.0, y: pos.y + 15, width: width, height: height);
            }else{
                let height:CGFloat = desc.height(forWidth: 20, font: data.font);
                rect = CGRect(x: pos.x - 5, y: pos.y + 10, width: 20, height: height);
            }
            let attributes = NSMutableDictionary();
            attributes.setValue(data.font, forKey: NSAttributedStringKey.font.rawValue);
            attributes.setValue(data.fontColor, forKey: NSAttributedStringKey.foregroundColor.rawValue);
            desc.draw(in: rect, withAttributes: attributes as! [NSAttributedStringKey : Any]);
        }
        if drawYaxis {
            //绘制Y轴
            ctx?.setStrokeColor(data.lineColor.cgColor);
            ctx?.move(to: CGPoint(x: baseX, y: baseY));
            ctx?.addLine(to: CGPoint(x: baseX, y: data.margins.top));
            ctx?.strokePath();
            for (i,pos) in yAxisPoints.enumerated() {
                let desc:NSString = yAxisValues[i] as NSString;
                let width:CGFloat = desc.width(with: data.font);
                let rect = CGRect(x: pos.x-6-width, y: pos.y, width: width, height: 20);
                let attributes = NSMutableDictionary();
                attributes.setValue(data.font, forKey: NSAttributedStringKey.font.rawValue);
                attributes.setValue(data.fontColor, forKey: NSAttributedStringKey.foregroundColor.rawValue);
                desc.draw(in: rect, withAttributes: attributes as! [NSAttributedStringKey : Any]);
            }
        }
        //画网格线
        if data.drawGrid {
            ctx?.setStrokeColor(data.gridColor.cgColor);
            ctx?.setLineWidth(0.5);
            
            var startY:CGFloat = data.margins.top;
            while startY < baseY {
                ctx?.move(to: CGPoint(x: baseX + 1, y: startY));
                ctx?.addLine(to: CGPoint(x: rightX, y: startY));
                startY += max(2,data.gridYspan);
            }
            var startX:CGFloat = data.margins.left;
            while startX <= rightX {
                ctx?.move(to: CGPoint(x: min(startX, rightX), y: data.margins.top));
                ctx?.addLine(to: CGPoint(x: min(startX, rightX), y: baseY));
                startX += data.gridXspan;
            }
            //画虚线
            ctx?.setLineDash(phase: 0, lengths: data.lineDash);
            ctx?.strokePath();
        }
        
        //线的path
        ctx?.setLineWidth(data.lineWidth);
        ctx?.setStrokeColor(data.lineColor.cgColor);
        let path:CGMutablePath = CGMutablePath()
        //阴影的path
        let drawPath:CGMutablePath = CGMutablePath();
        drawPath.move(to: CGPoint(x: baseX, y: baseY));
        for (i,pos) in pointsLine.enumerated() {
            if i == 0 {
                path.move(to: pos);
            }else{
                path.addLine(to: pos);
            }
            drawPath.addLine(to: pos);
        }
        let last = pointsLine.last;
        drawPath.addLine(to: CGPoint(x: last!.x, y: baseY));
        //闭合路径
        ctx?.addPath(path);
        ctx?.strokePath();
        
        //阴影的图层
        if data.drawShadow {
            let layer = CAGradientLayer()
            layer.frame = layerFrame;
            layer.startPoint = CGPoint(x: 0.5, y: 0);
            layer.endPoint = CGPoint(x: 0.5, y: 1);
            layer.locations = [0.1,0.3,0.5,0.7,0.9];
            layer.colors = data.shadowColor;
            let shape = CAShapeLayer();
            shape.path = drawPath;
            layer.mask = shape;
            self.layer.addSublayer(layer);
        }
        //画值
        if data.drawValues {
            for (i,pos) in pointsLine.enumerated() {
                let str = String.formatLu(value: self.data.dataSet[i].value, decimal: self.data.yAxisDecimalCount);
                let desc:NSString = str as NSString;
                let width:CGFloat = desc.width(with: self.data.font);
                let rect = CGRect(x: pos.x-width/2.0, y: pos.y-18, width: width, height: 20);
                let attributes = NSMutableDictionary();
                attributes.setValue(data.font, forKey: NSAttributedStringKey.font.rawValue);
                attributes.setValue(data.fontColor, forKey: NSAttributedStringKey.foregroundColor.rawValue);
                desc.draw(in: rect, withAttributes: attributes as! [NSAttributedStringKey : Any]);
            }
        }
        //画圈
        if data.drawCircle {
            ctx?.setStrokeColor(data.circleColor.cgColor);
            for pos in pointsLine {
                let rect = CGRect(x: pos.x - (data.circleWidth/2.0), y: pos.y-(data.circleWidth/2.0), width: data.circleWidth, height: data.circleWidth);
                ctx?.setFillColor(UIColor.white.cgColor);
                ctx?.fill(rect);
                ctx?.addEllipse(in: rect);
                ctx?.setFillColor(data.circleColor.cgColor);
                ctx?.fillPath()
            }
        }
        
        
    }
    
    

    ///private method
    public func calculValues(){
        //最大可显示范围
        let width = ScreenSize().width - (data.margins.left + data.margins.right);
        let height = showRect.height - (data.margins.top + data.margins.bottom);
        
        //y值的范围
        var minY:CGFloat = 0;
        var maxY:CGFloat = 0;
        for pos in data.dataSet {
            minY = min(minY,pos.value);
            maxY = max(maxY,pos.value);
        }
        let range = maxY - minY;
        //高度换算比例
        let rate:CGFloat = height >= range ? 1 : (height/range);
        
        //x方向的间距
        var xSpan:CGFloat = data.targetXspan;
        //当预期太大的时候,重新计算
        if (data.targetXspan * CGFloat(data.dataSet.count) > width) {
            xSpan = width / CGFloat(data.dataSet.count);
            xSpan = max(xSpan,data.minXspan);
            data.gridXspan = xSpan;
        }
        
        
        baseX = data.margins.left;
        baseY = data.margins.top + height;
        
        //X轴的绘制点
        xAxisPoints.removeAll();
        for (i,pos) in data.dataSet.enumerated() {
            if data.xAxisTop {
                let point:CGPoint = CGPoint(x: baseX + xSpan * CGFloat(i), y: data.margins.top);
                xAxisPoints.append(point);
            }else{
                let point:CGPoint = CGPoint(x: baseX + xSpan * CGFloat(i), y: baseY);
                xAxisPoints.append(point);
            }
        }
        //Y轴的绘制点
        let yDivider:CGFloat = range / CGFloat(data.yAxisCount);//值的值分段距离
        yAxisPoints.removeAll();
        yAxisValues.removeAll();
        for i in 0...data.yAxisCount {
            let value = minY + yDivider * CGFloat(i);
            let y = baseY - yDivider * CGFloat(i) * rate - 10;
            let str = String.formatLu(value: value, decimal: data.yAxisDecimalCount);
            yAxisValues.append(str);
            yAxisPoints.append(CGPoint(x: baseX, y: y));
        }
        //值的位置
        var minYValue:CGFloat = 0;
        var maxXValue:CGFloat = 0;
        pointsLine.removeAll();
        for (i,pos) in data.dataSet.enumerated() {
            let x:CGFloat = baseX + data.xOffset + xSpan * CGFloat(i);
            let y:CGFloat = baseY - fabs(pos.value - minY) * rate;
            minYValue = min(minYValue,y);
            maxXValue = max(maxXValue,x);
            pointsLine.append(CGPoint(x: x, y: y));
        }
        scrollX = maxXValue - baseX;
        //图层的范围
        layerFrame = CGRect(x: 0, y: 0, width:maxXValue, height: fabs(baseY-minYValue));
    }
    
    
}




///折线图数据
public class LineChartData:NSObject{
    public var animate:Bool = false             //是否动画
    public var lowLimit:CGFloat = 0             //底部限制
    public var drawCircle:Bool = true           //是否画圈
    public var drawValues:Bool = true           //画值
    public var drawShadow:Bool = true           //绘制阴影
    public var isSmooth:Bool = false            //是否使用顺滑曲线处理
    public var xAxisTop:Bool = false            //X轴绘制在上面
    public var drawGrid:Bool = true             //绘制网格
    public var gridYspan:CGFloat = 30
    public var gridXspan:CGFloat = 30
    public var xAxisValueHorizon = true         //X轴文字是否水平
    
    public var margins:UIEdgeInsets = UIEdgeInsets(top: 24, left: 32, bottom: 40, right: 32)//间距
    public var xOffset:CGFloat = 0              //绘制的点的X偏移
    public var yOffset:CGFloat = 0              //绘制的点的Y偏移
    public var yAxisCount:UInt = 5              //Y轴的点数量
    public var yAxisDecimalCount:UInt = 0       //Y轴值的小数位数
    public var targetXspan:CGFloat = 30         //期待X方向上的间隔
    public var minXspan:CGFloat = 1             //最小可接受间距
    public var lineWidth:CGFloat = 1            //线宽
    public var lineDash:[CGFloat] = [10,0]      //虚线样式
    public var lineColor:UIColor = UIColor.randomColor()//线颜色
    public var gridColor:UIColor = UIColor.colorHexValue("F0F0F0")
    public var font:UIFont = .systemFont(ofSize: 12);
    public var fontColor:UIColor = .black
    public var circleColor:UIColor = UIColor.randomColor()
    public var circleWidth:CGFloat = 6          //圆圈半径
    public var shadowColor:[CGColor] = []       //阴影颜色组
    
    
    public private (set) var dataSet:[LineData] = []//数据
    
    
    ///添加已经生成的数据
    public func addDatas(_ array:[LineData]){
        dataSet.append(contentsOf: array);
    }
    
    
    ///添加原始数据
    public func addOriginData(_ array:[(CGFloat,String)]){
        for item in array {
            let data = LineData();
            data.value = item.0;
            data.axisDesc = item.1;
            dataSet.append(data);
        }
    }
    
    
    ///清空
    public func clear(){
        self.dataSet.removeAll();
    }
    
    
    ///点数据
    public class LineData:NSObject{
        public var value:CGFloat = 0           //纵坐标数据
        public var axisDesc:String = ""        //横坐标数据
    }
    
    
}
