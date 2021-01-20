//
//  LineChartView.swift
//  SHKit
//
//  Created by mac on 2020/9/9.
//  Copyright © 2020 hsh. All rights reserved.
//


import UIKit


///折线图
public class LineChartView: UIView {
    //public
    public private(set) var data:LineChartData!                 //数据
    public private(set) var showLayerV:UIView!                  //展示视图
    //Private
    private var scrollV:UIScrollView!                           //滚动视图
    //图层
    private var lineLayer:CAShapeLayer!                         //线条
    private var circleLayer:CAShapeLayer!                       //圆圈
    private var gridLayer:CAShapeLayer!                         //网格
    private var yAxisLayer:CAShapeLayer!                        //Y轴
    private var xAxisLayer:CAShapeLayer!                        //X轴
    private var shadowLayer:CAGradientLayer!                    //阴影
    //图层管理
    private var yAxisValueLayers:[CATextLayer] = []             //Y轴字符
    private var xAxisValueLayers:[CATextLayer] = []             //X轴字符
    //运算值
    private var contentSizeX:CGFloat = 0                        //可滚动区域
    private var rate:CGFloat = 0                                //视图高度与值范围的比例
    private var minValue:CGFloat = 0                            //值的最小值
    
    
    
    ///Interface
    public func showData(_ data:LineChartData){
        self.data = data;
        self.backgroundColor = data.backColor;
        //显示
        self.drawLayers();
        //显示动画
        if data.animate {
            let ani = CABasicAnimation.init(keyPath: "strokeEnd");
            ani.duration = 5;
            ani.fromValue = 0;
            ani.toValue = 1;
            ani.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            ani.isRemovedOnCompletion = true;
            lineLayer.add(ani, forKey: "ani");
        }
    }
    
    
    
    ///绘制图层
    public func drawLayers(){
        //配置视图
        self.configLayers();
        //计算数据
        self.calculData();
        //绘制图层
        drawYaxis();
        drawXaxis();
        drawGrid();
        drawLine();
    }
    
    
    ///计算数据
    private func calculData(){
        contentSizeX = 0;
        var mi:CGFloat = 0;
        var ma:CGFloat = 0;
        for entry in data.dataSet {
            contentSizeX += data.xSpan;
            mi = min(mi, entry.value);
            ma = max(ma, entry.value);
        }
        //屏幕高度-上距离-下距离-图表最高点与图表上边距离
        let yRange:CGFloat = data.showRect.height - data.margins.top - data.margins.bottom - data.lineTop;
        let range:CGFloat = ma - mi;
        rate = yRange / range;
        minValue = mi;
    }
    
    
    ///绘制Y轴
    private func drawYaxis(){
        //轴线
        if data.drawYaxis {
            let path = CGMutablePath();
            path.move(to: CGPoint(x: data.margins.left - data.xyAxisLineWidth,
                                  y: data.showRect.height - data.margins.bottom));
            path.addLine(to: CGPoint(x: data.margins.left - data.xyAxisLineWidth, y: data.margins.top));
            yAxisLayer.path = path;
        }
        //绘制轴线上的文字
        if data.drawYaxisValues {
            let yRange:CGFloat = data.showRect.height - data.margins.top - data.margins.bottom - data.lineTop;
            let count:Int = Int(ceil(yRange/data.gridYspan));
            let bottomY:CGFloat = data.showRect.height - data.margins.bottom;
            let divide = data.gridYspan;
            for i in 0...count {
                let str = String.formatLu(value: divide * CGFloat(i) * rate, decimal: data.yAxisDecimalCount);
                let nsStr = NSString(string: str);
                let width = nsStr.width(with: UIFont.systemFont(ofSize: data.yAxisValueFontSize));
                let height = nsStr.height(forWidth: 100, font: UIFont.systemFont(ofSize: data.yAxisValueFontSize));
                let rect = CGRect(x: data.margins.left - width - data.yAxisValueTailSpan,
                                  y: bottomY - divide * CGFloat(i) - height/2.0, width: width, height: height);
                let layer = CATextLayer();
                layer.contentsScale = UIScreen.main.scale;
                layer.fontSize = data.yAxisValueFontSize;
                layer.string = str;
                layer.frame = rect;
                layer.foregroundColor = data.yAxisValueColor.cgColor;
                yAxisLayer.addSublayer(layer);
            }
        }
    }
    
    
    ///绘制X轴
    private func drawXaxis(){
        let xPath = CGMutablePath();
        let y:CGFloat = data.showRect.height - data.margins.bottom - data.margins.top;
        xPath.move(to: CGPoint(x: 0, y: y));
        xPath.addLine(to: CGPoint(x: contentSizeX, y: y));
        xAxisLayer.path = xPath;
        //绘制X轴文字
        if data.drawXaxisValues {
            let startY = data.showRect.height - data.margins.bottom;
            for (i,entry) in data.dataSet.enumerated() {
                let nsStr = NSString(string: entry.axisDesc);
                let width:CGFloat = nsStr.width(with: UIFont.systemFont(ofSize: data.xAxisValueFontSize));
                let height:CGFloat = nsStr.height(forWidth: 100,
                                                  font: UIFont.systemFont(ofSize: data.xAxisValueFontSize));
                let rect = CGRect(x: CGFloat(i) * data.xSpan - data.xSpan/2.0, y: startY, width:width, height: height);
                let layer = CATextLayer();
                layer.contentsScale = UIScreen.main.scale;
                layer.fontSize = data.xAxisValueFontSize;
                layer.string = entry.axisDesc;
                layer.frame = rect;
                layer.foregroundColor = data.xAxisValueColor.cgColor;
                xAxisLayer.addSublayer(layer);
            }
        }
    }
    
    
    ///绘制网格
    private func drawGrid(){
        if data.drawYGrid || data.drawXGrid {
            let gridPath = CGMutablePath();
            let topY:CGFloat = data.margins.top;
            let bottomY:CGFloat = data.showRect.height - data.margins.bottom - data.xyAxisLineWidth - data.margins.top;
            //竖向
            if data.drawYGrid {
                var startX:CGFloat = data.gridXspan;
                while startX < (contentSizeX)  {
                    gridPath.move(to: CGPoint(x: min(startX, (contentSizeX)), y: bottomY));
                    gridPath.addLine(to: CGPoint(x: min(startX, (contentSizeX)), y: 0));
                    startX += data.gridXspan;
                }
            }
            //横向
            if data.drawXGrid {
                var startY:CGFloat = bottomY-data.gridYspan;
                while startY > topY {
                    gridPath.move(to: CGPoint(x: 0, y: max(startY, topY)));
                    gridPath.addLine(to: CGPoint(x: contentSizeX, y: max(startY, topY)));
                    startY -= data.gridYspan;
                }
            }
            //边缘线
            gridPath.move(to: CGPoint(x: data.margins.left, y: 0));
            gridPath.addLine(to: CGPoint(x: contentSizeX, y: 0));
            gridPath.move(to: CGPoint(x: contentSizeX, y: 0));
            gridPath.addLine(to: CGPoint(x: contentSizeX, y: bottomY));
            gridLayer.path = gridPath;
        }
    }
    
    
    ///绘制主体
    private func drawLine(){
        //绘制线和点
        let path = CGMutablePath();
        let circlePath = CGMutablePath();
        let shadowPath = CGMutablePath();
        
        shadowPath.move(to: CGPoint(x: 0, y: data.showRect.height - data.margins.bottom));
        let bottomY:CGFloat = data.showRect.height - data.margins.bottom;
        
        for (i,entry) in data.dataSet.enumerated() {
            let range:CGFloat = (entry.value - minValue) * rate;
            let y:CGFloat = bottomY - range;
            let pos:CGPoint = CGPoint(x: CGFloat(i) * data.xSpan, y: y);
            if i == 0 {
                path.move(to: pos);
            }else{
                path.addLine(to: pos);
            }
            shadowPath.addLine(to: pos);
            if i == data.dataSet.count - 1 {
                shadowPath.addLine(to: CGPoint(x: pos.x, y: data.showRect.height - data.margins.bottom));
                shadowPath.addLine(to: CGPoint(x: 0, y: data.showRect.height - data.margins.bottom));
            }
            circlePath.move(to: pos);
            circlePath.addArc(center: pos, radius: data.circleRadius, startAngle: 0, endAngle: 6.3, clockwise: true);
        }
        lineLayer.path = path;
        circleLayer.path = circlePath;
        //绘制阴影
        drawShadow(path: shadowPath);
        
        showLayerV.frame = CGRect(x: 0, y: data.margins.top, width: contentSizeX, height: data.showRect.height - data.margins.top - data.margins.bottom);
        scrollV.contentSize = CGSize(width: contentSizeX, height: 0);
    }
    
    
    private func drawShadow(path:CGMutablePath){
        let shape = CAShapeLayer();
        shape.path = path;
        
        
//        shadowLayer.frame = CGRect(x: 0, y: 0, width: contentSizeX, height: data.showRect.height - data.margins.bottom - data.margins.top);
        shadowLayer.mask = shape;
        
        let ani = CABasicAnimation.init(keyPath: "colors");
        ani.duration = 5;
        ani.fromValue = 0;
        ani.toValue = 1;
        ani.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        ani.isRemovedOnCompletion = true;
        shadowLayer.add(ani, forKey: "c");
    }
    
    
    ///配置视图
    private func configLayers(){
        //初始化视图
        self.initSubViews();
        //配置视图
        scrollV.frame = CGRect(x: data.margins.left, y: 0,
                               width: (data.showRect.width - data.margins.left - data.margins.right),
                               height: data.showRect.height);
        
        
    }
    
    
    private func initSubViews(){
        if scrollV == nil {
            scrollV = UIScrollView();
            scrollV.backgroundColor = UIColor.clear;
            scrollV.bounces = false;
            scrollV.showsHorizontalScrollIndicator = false
            self.addSubview(scrollV);
        }
        if showLayerV == nil {
            showLayerV = UIView();
            scrollV.addSubview(showLayerV);
        }
        
        if gridLayer == nil {
            gridLayer = CAShapeLayer();
            gridLayer.strokeColor = data.gridColor.cgColor;
            gridLayer.fillColor = UIColor.clear.cgColor;
            gridLayer.lineWidth = data.gridLineWidth;
            gridLayer.lineDashPattern = data.lineDash;
            showLayerV.layer.addSublayer(gridLayer);
        }
        if yAxisLayer == nil {
            yAxisLayer = CAShapeLayer();
            yAxisLayer.strokeColor = data.xyAxisLineColor.cgColor;
            yAxisLayer.fillColor = UIColor.clear.cgColor;
            yAxisLayer.lineWidth = data.xyAxisLineWidth;
            self.layer.addSublayer(yAxisLayer);
        }
        if xAxisLayer == nil {
            xAxisLayer = CAShapeLayer();
            xAxisLayer.strokeColor = data.xyAxisLineColor.cgColor;
            xAxisLayer.fillColor = UIColor.clear.cgColor;
            xAxisLayer.lineWidth = data.xyAxisLineWidth;
            showLayerV.layer.addSublayer(xAxisLayer);
        }
        if shadowLayer == nil {
            shadowLayer = CAGradientLayer();
            shadowLayer.startPoint = CGPoint(x: 0.5, y: 0);
            shadowLayer.endPoint = CGPoint(x: 0.5, y: 1);
            shadowLayer.locations = data.shadowLocations;
            shadowLayer.colors = data.shadowColor;
            showLayerV.layer.addSublayer(shadowLayer);
        }
        if lineLayer == nil {
            lineLayer = CAShapeLayer();
            lineLayer.lineWidth = data.lineWidth;
            lineLayer.strokeColor = data.lineColor.cgColor;
            lineLayer.fillColor = UIColor.clear.cgColor;
            lineLayer.lineJoin = kCALineCapRound;
            showLayerV.layer.addSublayer(lineLayer);
        }
        if circleLayer == nil {
            circleLayer = CAShapeLayer();
            circleLayer.lineWidth = 1;
            circleLayer.strokeColor = data.circleColor.cgColor;
            circleLayer.fillColor = data.circleColor.cgColor;
            showLayerV.layer.addSublayer(circleLayer);
        }
    }
    


    
}



///折线图数据
public class LineChartData:NSObject{
    ///数据
    public private (set) var dataSet:[LineData] = []//数据
    //UI配置
    public var margins:UIEdgeInsets = UIEdgeInsets(top: 24, left: 32, bottom: 40, right: 32)//间距
    public var lineTop:CGFloat = 30
    public var showRect:CGRect = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 300)
    public var backColor:UIColor = UIColor.white//背景色
    //动画
    public var animate:Bool = true              //是否动画
    public var animateDuration:TimeInterval = 2 //动画时长
    //线
    public var lineWidth:CGFloat = 1            //线宽
         
    public var lineColor:UIColor = UIColor.randomColor()//线颜色
    public var xSpan:CGFloat = 20
    //圆圈
    public var drawCircle:Bool = true           //是否画圈
    public var circleColor:UIColor = UIColor.randomColor()//圆圈的颜色
    public var circleRadius:CGFloat = 2
    public var fillCircle:Bool = true
    //Y轴
    public var drawYaxis:Bool = true            //绘制Y轴
    public var drawYaxisValues:Bool = true      //绘制Y轴数据
    public var yAxisDecimalCount:UInt = 0       //Y轴值的小数位数
    public var yAxisValueColor:UIColor = .black
    public var yAxisValueFontSize:CGFloat = 8
    public var yAxisValueTailSpan:CGFloat = 6
    //X轴
    public var drawXaxisValues:Bool = true
    public var xyAxisLineWidth:CGFloat = 1      //坐标轴线宽
    public var xyAxisLineColor:UIColor = .black
    public var xAxisValueHorizon = true         //X轴文字是否水平
    public var xAxisValueFontSize:CGFloat = 12
    public var xAxisValueColor:UIColor = .black
    //值
    public var drawValues:Bool = true           //画值
    public var valueFont:UIFont = .systemFont(ofSize: 12)
    public var valuefontColor:UIColor = .black
    //网格
    public var drawYGrid:Bool = true            //绘制Y方向网格
    public var drawXGrid:Bool = true            //绘制X方向网格
    public var gridYspan:CGFloat = 30           //网格Y间距
    public var gridXspan:CGFloat = 30           //网格X间距
    public var gridColor:UIColor = UIColor.colorHexValue("F0F0F0")//网格颜色
    public var gridLineWidth:CGFloat = 1        //线宽
    public var lineDash:[NSNumber] = [2,10]     //虚线样式
    //阴影
    public var drawShadow:Bool = true           //绘制阴影
    public var shadowColor:[CGColor] = []       //阴影颜色组
    public var shadowLocations:[NSNumber] = [0.1,0.3,0.5,0.7,0.9]

    
    
    
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
    
    
    ///点数据
    public class LineData:NSObject{
        public var value:CGFloat = 0           //纵坐标数据
        public var axisDesc:String = ""        //横坐标数据
    }
    
    
}
