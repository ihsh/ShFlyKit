//
//  BarChart.swift
//  ShFlyKit
//
//  Created by mac on 2020/11/23.
//

import UIKit


///条形图
public class BarChart: UIView {
    //private
    private var scrollV:UIScrollView!
    private var yAxisLayer:CAShapeLayer!
    private var xAxisLayer:CAShapeLayer!
    private var gridLayer:CAShapeLayer!
    private var showLayerV:UIView!
    private var yAxis:[CATextLayer] = []
    private var xAxis:[CATextLayer] = []
    private var lineLayers:[CAShapeLayer] = []
  
    
    ///Interface
    public func showBar(data:BarChartData){
        //配置视图
        self.configSubLayers(data: data);
        
        
    }
    
    
    ///配置视图属性
    private func configSubLayers(data:BarChartData){
        self.backgroundColor = data.backColor;
        //滚动视图
        if scrollV == nil {
            scrollV == UIScrollView()
            scrollV.backgroundColor = UIColor.clear;
            self.addSubview(scrollV);
            scrollV.mas_makeConstraints { (make) in
                make?.left.mas_equalTo()(data.margins.left);
                make?.top.bottom()?.mas_equalTo()(self);
                make?.right.mas_equalTo()(data.margins.right);
            }
        }
        //Y坐标轴
        if yAxisLayer == nil {
            yAxisLayer = CAShapeLayer()
            self.layer.addSublayer(yAxisLayer);
        }
        yAxisLayer.strokeColor = data.XYAxisColor.cgColor;
        yAxisLayer.lineWidth = data.XYAxisLineWidth;
        yAxisLayer.fillColor = UIColor.clear.cgColor;
        //X坐标轴
        if xAxisLayer == nil {
            xAxisLayer = CAShapeLayer()
            self.layer.addSublayer(xAxisLayer);
        }
        xAxisLayer.strokeColor = data.XYAxisColor.cgColor;
        xAxisLayer.lineWidth = data.XYAxisLineWidth;
        xAxisLayer.fillColor = UIColor.clear.cgColor;
        //网格
        if gridLayer == nil {
            gridLayer = CAShapeLayer()
            self.layer.addSublayer(gridLayer);
        }
        gridLayer.strokeColor = data.gridColor.cgColor;
        gridLayer.lineWidth = data.gridLineWidth;
        gridLayer.lineJoin = kCALineJoinRound;
        gridLayer.lineDashPattern = data.lineDash;
        //显示图层
        if showLayerV == nil {
            showLayerV = UIView()
            scrollV.addSubview(showLayerV);
        }
        
    }
    
    

    
    
}



///条形图数据
public class BarChartData:NSObject{
    public var dataSets:[BarEntrySet] = []
    public var backColor:UIColor = .white
    public var valueSpan:CGFloat = 1
    public var valueWidth:CGFloat = 10
    
    public var drawXAxis:Bool = true
    public var drawYAxis:Bool = true
    public var XYAxisLineWidth:CGFloat = 1
    public var XYAxisColor:UIColor = .black
    public var XYAxisDescColor:UIColor = .black
    
    public var drawGridX:Bool = false
    public var drawGridY:Bool = true
    public var gridColor:UIColor = .lightGray
    public var gridLineWidth:CGFloat = 1
    public var lineDash:[NSNumber] = [3,3]
    
    public var drawGradient:Bool = false
    public var gradientColors:[UIColor] = []
    public var lineValueMid:Bool = false
    
    public var margins:UIEdgeInsets = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
    
    
    ///条形图单个横向数据，可以有多个条形
    public class BarEntrySet:NSObject{
        public var xDesc:String = ""
        public var entrys:[BarEntry] = []
        
        public class func initEntrySet(values:[Double],descs:[String],colors:[UIColor],Xdesc:String)->BarEntrySet{
            let set = BarEntrySet();
            set.xDesc = Xdesc;
            for (i,value) in values.enumerated() {
                let desc = i < descs.count ? descs[i] : "";
                let color = i < colors.count ? colors[i] : .randomColor();
                let entry = BarEntry.initEntry(value: value, desc: desc, color: color);
                set.entrys.append(entry);
            }
            return set;
        }
    }
    
    
    ///条形图单条数据
    public class BarEntry:NSObject{
        public var value:Double = 0
        public var desc:String = ""
        public var color:UIColor = .randomColor()
        
        public class func initEntry(value:Double,desc:String,color:UIColor = .randomColor())->BarEntry{
            let entry = BarEntry();
            entry.value = value;
            entry.desc = desc;
            entry.color = color;
            return entry;
        }
    }
    
    
}
