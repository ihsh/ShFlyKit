//
//  LineChartView.swift
//  SHKit
//
//  Created by mac on 2020/9/9.
//  Copyright © 2020 hsh. All rights reserved.
//


import UIKit


///折线图
public class LineChartView: UIView ,CAAnimationDelegate{
    //public
    public var showRect:CGRect = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 300)
    public private(set) var data:LineChartData!                 //数据
    public private(set) var showLayerV:UIView!                  //展示视图
    
    //Private
    private var scrollV:UIScrollView!                           //滚动视图
    //图层
    private var lineLayer:CAShapeLayer!                         //线条
    private var circleLayer:CAShapeLayer!                       //圆圈
    private var shadowLayer:CAGradientLayer!                    //阴影
    
    private var gridLayer:CAShapeLayer!                         //网格
    private var yAxisLayer:CAShapeLayer!                        //Y轴
    private var xAxisLayer:CAShapeLayer!                        //X轴
    //图层管理
    private var yAxisValueLayers:[CATextLayer] = []             //Y轴字符
    private var xAxisValueLayers:[CATextLayer] = []             //X轴字符
    private var valueLayers:[CATextLayer] = []                  //值字符
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
        //绘制网格图，阴影，值
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
        let yRange:CGFloat = showRect.height - data.margins.top - data.margins.bottom - data.lineTop;
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
                                  y: showRect.height - data.margins.bottom));
            path.addLine(to: CGPoint(x: data.margins.left - data.xyAxisLineWidth, y: data.margins.top));
            yAxisLayer.path = path;
        }
        //绘制轴线上的文字
        if data.drawYaxisValues {
            let yRange:CGFloat = showRect.height - data.margins.top - data.margins.bottom - data.lineTop;
            let count:Int = Int(ceil(yRange/data.gridYspan));
            let bottomY:CGFloat = showRect.height - data.margins.bottom;
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
                yAxisValueLayers.append(layer);
            }
        }
    }
    
    
    ///绘制X轴
    private func drawXaxis(){
        
        let xPath = CGMutablePath();
        let y:CGFloat = showRect.height - data.margins.bottom - data.margins.top;
        xPath.move(to: CGPoint(x: 0, y: y));
        xPath.addLine(to: CGPoint(x: contentSizeX, y: y));
        xAxisLayer.path = xPath;
        //绘制X轴文字
        if data.drawXaxisValues {
            //添加文本视图
            func addTextLayer(rect:CGRect,desc:String){
                let layer = CATextLayer();
                layer.contentsScale = UIScreen.main.scale;
                layer.fontSize = data.xAxisValueFontSize;
                layer.string = desc;
                layer.frame = rect;
                layer.foregroundColor = data.xAxisValueColor.cgColor;
                xAxisLayer.addSublayer(layer);
                xAxisValueLayers.append(layer);
            }
            
            let startY = showRect.height - data.margins.bottom - data.margins.top + data.xAxisValueTopSpan;
            for (i,entry) in data.dataSet.enumerated() {
                let nsStr = NSString(string: entry.axisDesc);
                let font = UIFont.systemFont(ofSize: data.xAxisValueFontSize);
                let height:CGFloat = nsStr.height(forWidth: 100,font: font);

                if data.xAxisValueHorizon {
                    let width:CGFloat = nsStr.width(with: font);
                    let startX = CGFloat(i) * data.xSpan - width/2.0 + data.xAxisXoffset;
                    let rect = CGRect(x: startX, y: startY, width:width, height: height);
                    addTextLayer(rect: rect, desc: entry.axisDesc);
                }else{
                    let width:CGFloat = "单".width(with: font);
                    let startX = CGFloat(i) * data.xSpan - width/2.0 + data.xAxisXoffset;
                    var y:CGFloat = startY;
                    for char in entry.axisDesc.characters {
                        let rect = CGRect(x: startX, y: y, width:width, height: height);
                        addTextLayer(rect: rect, desc: String(char));
                        y += height;
                    }
                }
            }
        }
    }
    
    
    ///绘制网格
    private func drawGrid(){
        
        if data.drawYGrid || data.drawXGrid {
            let gridPath = CGMutablePath();
            let topY:CGFloat = data.margins.top;
            let bottomY:CGFloat = showRect.height - data.margins.bottom - data.xyAxisLineWidth - data.margins.top;
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
        //生成中间点
        func calculTmpPos(pos1:CGPoint,pos2:CGPoint,x:CGFloat)->CGPoint{
            let xRange:CGFloat = fabs(pos2.x-pos1.x);
            let xdiv:CGFloat = fabs(x-pos1.x);
            var rate:CGFloat = xdiv/xRange;
            rate = min(1, rate);
            //Y相关
            let yRange:CGFloat = pos2.y-pos1.y;
            let ydiv:CGFloat = rate * yRange;
            let newY:CGFloat = pos1.y + ydiv;
            return CGPoint(x: x, y: newY);
        }
        ///添加值
        func addTextLayer(pos:CGPoint,desc:String,index:Int){
            if index > valueLayers.count {
                let layer = CATextLayer();
                layer.contentsScale = UIScreen.main.scale;
                layer.fontSize = data.valueFontSize;
                layer.string = desc;
                let nsStr = NSString(string: desc);
                let width = nsStr.width(with: UIFont.systemFont(ofSize: data.valueFontSize));
                let height = nsStr.height(forWidth: 100, font: UIFont.systemFont(ofSize: data.valueFontSize));
                layer.frame = CGRect(x: pos.x-width/2.0, y: pos.y-height-data.valueBottomSpan, width: width, height: height);
                layer.foregroundColor = data.xAxisValueColor.cgColor;
                lineLayer.addSublayer(layer);
                valueLayers.append(layer);
            }
        }
        
        //根据X动态变化
        func animateForX(x:CGFloat){
            //至少从起点开始
            if x > data.xAxisXoffset {
                
                //绘制线和点
                let path = CGMutablePath();
                let shadowPath = CGMutablePath();
                let circlePath = CGMutablePath();
                
                shadowPath.move(to: CGPoint(x: data.xAxisXoffset, y: showRect.height - data.margins.bottom));
                let bottomY:CGFloat = showRect.height - data.margins.bottom;
                
                //一次循环同时创建线，圆，阴影的路径
                for (i,entry) in data.dataSet.enumerated() {
                    //后一个点
                    let range1:CGFloat = (entry.value - minValue) * rate;
                    let y1:CGFloat = bottomY - range1;
                    let pos:CGPoint = CGPoint(x: CGFloat(i) * data.xSpan + data.xAxisXoffset, y: y1);
                    
                    //实际的终点
                    var end:Bool = false;
                    var endPos:CGPoint = pos;
                    if x < pos.x {
                        //到达终点，使用生成点
                        end = true;
                        //前一点
                        let entry2 = data.dataSet[max(0,i-1)];
                        let range2:CGFloat = (entry2.value - minValue) * rate;
                        let y2:CGFloat = bottomY - range2;
                        let prePos:CGPoint = CGPoint(x: CGFloat(max(0,i-1)) * data.xSpan + data.xAxisXoffset, y: y2);
                        //当前点
                        endPos = calculTmpPos(pos1: prePos, pos2: pos, x: x);
                    }
                    //连线
                    if i == 0 {
                        path.move(to: endPos);
                    }else{
                        path.addLine(to: endPos);
                        //线走过了再添加圆圈和值
                        if end == false {
                            //添加圆点
                            circlePath.move(to: pos);
                            circlePath.addArc(center: pos, radius: data.circleRadius, startAngle: 0, endAngle: 6.3, clockwise: true);
                            //添加值-重复不添加
                            addTextLayer(pos: pos, desc: String.formatLu(value: entry.value, decimal: data.valueDecimalCount),index: i);
                        }
                    }
                    //阴影部分
                    shadowPath.addLine(to: endPos);
                    //阴影添加尾部
                    if (i == data.dataSet.count - 1 || end) {
                        shadowPath.addLine(to: CGPoint(x: endPos.x, y: showRect.height - data.margins.bottom));
                        shadowPath.addLine(to: CGPoint(x: 0, y: showRect.height - data.margins.bottom));
                    }
                    //终结此次循环
                    if end {
                        break;
                    }
                }
                //直接绘制线，圆
                lineLayer.path = path;
                circleLayer.path = circlePath;
                //绘制阴影
                drawShadow(path: shadowPath);
            }
        }
        
        //递归调用
        var tmpX:CGFloat = data.animate ? 0 : contentSizeX;
        //动画间隔
        let span:TimeInterval = (data.animateDuration / Double(contentSizeX));
        
        func recursiveAnimate(){
            animateForX(x: tmpX);
            tmpX += 1;
            //结束动画
            if tmpX <= contentSizeX {
                DispatchQueue.main.asyncAfter(deadline: .now()+span) {
                    recursiveAnimate();
                }
            }
        }
        //开始递归
        recursiveAnimate();

        //展示视图的宽度确定
        showLayerV.frame = CGRect(x: 0, y: data.margins.top, width: contentSizeX, height: showRect.height - data.margins.top - data.margins.bottom);
        //滚动视图的滚动范围
        scrollV.contentSize = CGSize(width: contentSizeX, height: 0);
    }
    
    
    ///添加阴影todo
    private func drawShadow(path:CGMutablePath){
        //遮罩
        let shape = CAShapeLayer();
        shape.path = path;
        shadowLayer.frame = CGRect(x: 0, y: 0,
                                   width: contentSizeX,
                                   height: showRect.height-data.margins.bottom-data.margins.top);
        shadowLayer.mask = shape;
    }
    
    
    ///配置视图
    private func configLayers(){
        //初始化视图
        self.initSubViews();
        //更新滚动视图坐标
        scrollV.frame = CGRect(x: data.margins.left, y: 0,
                               width: (showRect.width - data.margins.left - data.margins.right),
                               height: showRect.height);
        //移除旧视图
        for layer in xAxisValueLayers {
            layer.removeFromSuperlayer();
        }
        for layer in yAxisValueLayers {
            layer.removeFromSuperlayer();
        }
        for layer in valueLayers {
            layer.removeFromSuperlayer();
        }
        xAxisValueLayers.removeAll();
        yAxisValueLayers.removeAll();
        valueLayers.removeAll();
    }
    
    
    
    ///配置子视图、图层
    private func initSubViews(){
        //滚动视图
        if scrollV == nil {
            scrollV = UIScrollView();
            scrollV.backgroundColor = UIColor.clear;
            scrollV.bounces = false;
            scrollV.clipsToBounds = true;
            scrollV.showsHorizontalScrollIndicator = false
            self.addSubview(scrollV);
        }
        //展示的视图
        if showLayerV == nil {
            showLayerV = UIView();
            scrollV.addSubview(showLayerV);
        }
        //网格线
        if gridLayer == nil {
            gridLayer = CAShapeLayer();
            gridLayer.fillColor = UIColor.clear.cgColor;
            showLayerV.layer.addSublayer(gridLayer);
        }
        gridLayer.strokeColor = data.gridColor.cgColor;
        gridLayer.lineWidth = data.gridLineWidth;
        gridLayer.lineDashPattern = data.lineDash;
        //Y轴
        if yAxisLayer == nil {
            yAxisLayer = CAShapeLayer();
            yAxisLayer.fillColor = UIColor.clear.cgColor;
            self.layer.addSublayer(yAxisLayer);
        }
        yAxisLayer.lineWidth = data.xyAxisLineWidth;
        yAxisLayer.strokeColor = data.xyAxisLineColor.cgColor;
        //X轴
        if xAxisLayer == nil {
            xAxisLayer = CAShapeLayer();
            xAxisLayer.fillColor = UIColor.clear.cgColor;
            showLayerV.layer.addSublayer(xAxisLayer);
        }
        xAxisLayer.lineWidth = data.xyAxisLineWidth;
        xAxisLayer.strokeColor = data.xyAxisLineColor.cgColor;
        //阴影
        if shadowLayer == nil {
            shadowLayer = CAGradientLayer();
            shadowLayer.startPoint = CGPoint(x: 0.5, y: 0);
            shadowLayer.endPoint = CGPoint(x: 0.5, y: 1);
            showLayerV.layer.addSublayer(shadowLayer);
        }
        shadowLayer.locations = data.shadowLocations;
        shadowLayer.colors = data.shadowColor;
        //线条
        if lineLayer == nil {
            lineLayer = CAShapeLayer();
            lineLayer.fillColor = UIColor.clear.cgColor;
            lineLayer.lineJoin = kCALineCapRound;
            showLayerV.layer.addSublayer(lineLayer);
        }
        lineLayer.lineWidth = data.lineWidth;
        lineLayer.strokeColor = data.lineColor.cgColor;
        //圆圈
        if circleLayer == nil {
            circleLayer = CAShapeLayer();
            circleLayer.strokeColor = data.circleColor.cgColor;
            showLayerV.layer.addSublayer(circleLayer);
        }
        circleLayer.lineWidth = min(data.ciecleLineWidth, data.circleRadius);
        circleLayer.fillColor = data.fillCircle ? data.circleColor.cgColor : UIColor.clear.cgColor;
    }

    
}








///折线图数据
public class LineChartData:NSObject{
    ///数据
    public private (set) var dataSet:[LineData] = []//数据
    //UI配置
    public var margins:UIEdgeInsets = UIEdgeInsets(top: 24, left: 32, bottom: 60, right: 32)//间距
    public var backColor:UIColor = UIColor.white//背景色
    //动画
    public var animate:Bool = true              //是否动画
    public var animateDuration:TimeInterval = 2 //动画时长
    //线
    public var lineWidth:CGFloat = 1            //线宽
    public var lineTop:CGFloat = 30             //线最高点距离绘制区域的上边距离
    public var lineColor:UIColor = UIColor.randomColor()//线颜色
    public var xSpan:CGFloat = 20               //X方向的间距
    //圆圈
    public var drawCircle:Bool = true           //是否画圈
    public var circleColor:UIColor = UIColor.randomColor()//圆圈的颜色
    public var ciecleLineWidth:CGFloat = 1      //线宽
    public var circleRadius:CGFloat = 2         //圆半径
    public var fillCircle:Bool = true           //是否填充圆
    //Y轴
    public var drawYaxis:Bool = true            //绘制Y轴
    public var drawYaxisValues:Bool = true      //绘制Y轴数据
    public var yAxisDecimalCount:UInt = 0       //Y轴值的小数位数
    public var yAxisValueColor:UIColor = .black
    public var yAxisValueFontSize:CGFloat = 8
    public var yAxisValueTailSpan:CGFloat = 6   //Y轴文本距离坐标轴的尾部的间距
    //X轴
    public var drawXaxisValues:Bool = true
    public var xyAxisLineWidth:CGFloat = 1      //坐标轴线宽
    public var xyAxisLineColor:UIColor = .black
    public var xAxisValueHorizon = false        //X轴文字是否水平
    public var xAxisValueTopSpan:CGFloat = 6    //X轴文字距离X轴距离
    public var xAxisXoffset:CGFloat = 0         //内容在X轴的偏移
    public var xAxisValueFontSize:CGFloat = 12
    public var xAxisValueColor:UIColor = .black
    //值
    public var drawValues:Bool = true           //画值
    public var valueFontSize:CGFloat = 12
    public var valueBottomSpan:CGFloat = 6      //值底部与点间距
    public var valueDecimalCount:UInt = 0       //小数点数量
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
    public var shadowLocations:[NSNumber] = [0.1,0.3,0.5,0.7,0.9]//阴影的分布

    
    
    
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
