//
//  BarChart.swift
//  ShFlyKit
//
//  Created by mac on 2020/11/23.
//

import UIKit


///条形图
public class BarChart: UIView {
    //public
    public private(set) var showLayerV:UIView!          //条形图加载图层
    public private(set) var data:BarChartData!
    //private
    private var scrollV:UIScrollView!                   //滚动视图,左右有间距，上下全贴合
    private var yAxisLayer:CAShapeLayer!                //Y轴图层
    private var xAxisLayer:CAShapeLayer!                //X轴图层
    private var gridLayer:CAShapeLayer!                 //网格图层
    
    private var yAxisTextLayers:[CATextLayer] = []      //Y轴的文字图层
    private var xAxisTextLayers:[CATextLayer] = []      //X轴的文字图层
    private var valueTextLayers:[CATextLayer] = []      //条形图值图层
    private var cacheLayers:[CAShapeLayer] = []         //条形码图层
    private var tintLayers:[CALayer] = []               //指示条图层
    private var lastIndex:Int = -1;                     //记录上一次选中的条形码，减少绘制
    
    
    ///Interface
    public func showBar(data:BarChartData){
        self.data = data;
        //绘制
        self.drawLayers();
    }
    
    
    ///绘制
    public func drawLayers(){
        ///配置视图
        self.configSubLayers(data: data);
        ///计算数据
        self.calculData();
        ///绘制Y轴
        drawYAxis()
        ///绘制X轴
        drawXAxis()
        ///画网格
        drawGrid();
        ///绘制横向条形图
        drawBars();
        ///绘制指示条
        drawTint();
    }
    
    
    //绘制Y轴
    private func drawYAxis(){
        //绘制线
        let yPath = CGMutablePath();
        yPath.move(to: CGPoint(x: data.margins.left - data.XYAxisLineWidth,
                               y: data.showRect.height - data.margins.bottom + data.XYAxisLineWidth));
        yPath.addLine(to: CGPoint(x:data.margins.left - data.XYAxisLineWidth , y: data.margins.top));
        yAxisLayer.path = yPath;
        //绘制值
        if data.drawYAxisValues {
            for (index,rect) in data.yAxisValuesRects.enumerated() {
                let str = data.yAxisValues[index];
                let layer = CATextLayer();
                layer.contentsScale = UIScreen.main.scale;
                layer.fontSize = data.yAxisValuesFontSize;
                layer.string = str;
                layer.frame = rect;
                layer.foregroundColor = data.yAxisValueColor.cgColor;
                yAxisTextLayers.append(layer);
                yAxisLayer.addSublayer(layer);
            }
        }
    }
    
    
    //绘制X轴
    private func drawXAxis(){
        //绘制线
        let xPath = CGMutablePath();
        let y:CGFloat = data.showRect.height - data.margins.bottom - data.margins.top;
        xPath.move(to: CGPoint(x: 0, y: y));
        xPath.addLine(to: CGPoint(x: data.contentSizeX + data.valueRightSpan, y: y));
        xAxisLayer.path = xPath;
        //绘制值
        if data.drawXAxisValues {
            var startX:CGFloat = 0
            for set in data.dataSets {
                let width:CGFloat = CGFloat(set.entrys.count) * (data.valueWidth + data.valueSpan); //整个set的条形图宽度
                let nsStr:NSString = NSString(string: set.xDesc);
                let font:UIFont = UIFont.systemFont(ofSize: data.xAxisValueFontSize);
                let textWidth:CGFloat = nsStr.width(with: font);                //文字宽度
                let height:CGFloat = nsStr.height(forWidth: width, font: font);
                let rect = CGRect(x: startX + width/2.0 - textWidth/2.0,
                                  y: y + data.xAxisValueTop,
                                  width: textWidth, height: height);  //文字居中整个set
                let layer = CATextLayer();
                layer.contentsScale = UIScreen.main.scale;
                layer.fontSize = data.xAxisValueFontSize;
                layer.string = set.xDesc;
                layer.frame = rect;
                layer.foregroundColor = data.xAxisValueColor.cgColor;
                xAxisTextLayers.append(layer);
                xAxisLayer.addSublayer(layer);
                startX += width;
                startX += data.setValueSpan;//加上set之间的特定间距
            }
        }
    }
    
    
    ///绘制网格
    private func drawGrid(){
        if data.drawGridX || data.drawGridY {
            let gridPath = CGMutablePath();
            let topY:CGFloat = 0;
            let bottomY:CGFloat = data.showRect.height - data.margins.bottom - data.margins.top - data.XYAxisLineWidth;
            //竖向
            if data.drawGridY {
                var startX:CGFloat = data.gridXspan;
                while startX < (data.contentSizeX + data.valueRightSpan)  {
                    gridPath.move(to: CGPoint(x: min(startX, (data.contentSizeX + data.valueRightSpan)), y: bottomY));
                    gridPath.addLine(to: CGPoint(x: min(startX, (data.contentSizeX + data.valueRightSpan)), y: 0));
                    startX += data.gridXspan;
                }
            }
            //横向
            if data.drawGridX {
                var startY:CGFloat = bottomY-data.gridYspan;
                while startY > topY {
                    gridPath.move(to: CGPoint(x: 0, y: max(startY, topY)));
                    gridPath.addLine(to: CGPoint(x: data.contentSizeX + data.valueRightSpan, y: max(startY, topY)));
                    startY -= data.gridYspan;
                }
            }
            //边缘线
            gridPath.move(to: CGPoint(x: 0, y: 0));
            gridPath.addLine(to: CGPoint(x: data.contentSizeX + data.valueRightSpan, y: 0));
            gridPath.move(to: CGPoint(x: data.contentSizeX + data.valueRightSpan - data.XYAxisLineWidth, y: 0));
            gridPath.addLine(to: CGPoint(x: data.contentSizeX + data.valueRightSpan - data.XYAxisLineWidth, y: bottomY));
            gridLayer.path = gridPath;
        }
    }
    
    
    ///绘制条形图
    private func drawBars(){
        
        //添加图层的子方法
        func addLayer(entry:BarChartData.BarEntry,color:UIColor,rect:CGRect){
            let layer = CAShapeLayer();
            layer.fillColor = UIColor.clear.cgColor;
            layer.strokeColor = color.cgColor;
            layer.lineWidth = rect.width;
            
            let path = CGMutablePath();
            let x = rect.origin.x + rect.width/2.0;
            path.move(to: CGPoint(x: x, y: (rect.origin.y + rect.height)))
            path.addLine(to: CGPoint(x: x, y: rect.origin.y));
            layer.path = path;
            showLayerV.layer.addSublayer(layer);
            cacheLayers.append(layer);
            entry.layers.append(layer);
        }
        //遍历子节点
        for set in self.data.dataSets {
            for entry in set.entrys {
                entry.layers.removeAll();
                //添加多色图层
                if data.drawGradient && data.gradientColors.count > 1 {
                    var start = entry.rect.origin.y + entry.rect.size.height;
                    var endY = entry.rect.origin.y;
                    var index:Int = 0;
                    while start >= endY {
                        let color = data.gradientColors[index%data.gradientColors.count];
                        let end = max(start - data.grddientSpan, endY);
                        addLayer(entry: entry, color: color, rect: CGRect(x: entry.rect.origin.x, y: end, width: entry.rect.size.width, height: (start-end)))
                        start -= data.grddientSpan;
                        index += 1;
                    }
                }else{
                    //单色
                    addLayer(entry: entry, color: entry.color, rect: entry.rect);
                }
                //绘制值
                if data.drawValues {
                    let x = entry.rect.origin.x + entry.rect.size.width/2.0;
                    let nsStr = NSString(string: entry.desc);
                    let font:UIFont = UIFont.systemFont(ofSize: data.valueFontSize);
                    let textWid:CGFloat = nsStr.width(with: font)
                    let height:CGFloat = nsStr.height(forWidth: textWid, font: font);
                    let rect:CGRect = CGRect(x: x - textWid/2.0, y: entry.rect.origin.y - data.valueBottomSpan - height, width: textWid, height: height);
                    let layer = CATextLayer();
                    layer.contentsScale = UIScreen.main.scale;
                    layer.fontSize = 8;
                    layer.string = entry.desc;
                    layer.frame = rect;
                    layer.foregroundColor = data.xAxisValueColor.cgColor;
                    showLayerV.layer.addSublayer(layer);
                }
                
            }
        }
        //设置坐标
        showLayerV.frame = CGRect(x: 0, y: data.margins.top,
                                  width: data.contentSizeX + data.valueRightSpan,
                                  height: (data.showRect.height-data.margins.top-data.margins.bottom));
        //设置滚动范围
        scrollV.contentSize = CGSize(width: data.contentSizeX + data.valueRightSpan, height: 0);
    }
    
    
    
    ///绘制指示条
    private func drawTint(){
        
        if (data.drawTint && (data.tintDescs.count == data.tintColors.count)) {
            let startX:CGFloat = data.margins.left + data.tintMargin.left;
            let startY:CGFloat = data.showRect.height - data.margins.bottom + data.tintMargin.top;
            
            var x = startX;
            var y = startY;
            let maxX:CGFloat = ScreenSize().width - data.tintMargin.right;
            for (i,color) in data.tintColors.enumerated() {
                let desc = data.tintDescs[i];
                let nsStr:NSString = NSString(string: desc);
                let width:CGFloat = nsStr.width(with: UIFont.systemFont(ofSize: 10));
                let height:CGFloat = nsStr.height(forWidth: 100, font: UIFont.systemFont(ofSize: 10));
                if ((x + data.tintSize.width + data.tintColorDescMargin + width) > maxX) {
                    x = startX;
                    y += 20;
                }
                //点
                let dot = UIView();
                dot.backgroundColor = color;
                dot.layer.cornerRadius = data.tintSize.height/2.0;
                dot.frame = CGRect(x: x, y: y, width: data.tintSize.width, height: data.tintSize.height);
                self.addSubview(dot);
                x += (data.tintSize.width + data.tintColorDescMargin);
                //文字
                let label = UILabel();
                label.font = UIFont.systemFont(ofSize: 10);
                label.textColor = .black;
                label.text = desc;
                label.frame = CGRect(x: x, y: y + data.tintSize.height/2.0 - height/2.0, width: width, height: height)
                self.addSubview(label);
                x += (width + data.tintSpan);
            }
            let dot = UIView();
            
        }
    }
    
    
    //计算数据
    private func calculData(){
        //计算最大最小值
        var ma:Double = 0;
        var mi:Double = 0;
        for set in self.data.dataSets {
            for entry in set.entrys {
                ma = max(ma, entry.value);
                mi = min(mi, entry.value);
                if entry.desc.count == 0 {
                    entry.desc = String(format: "%.f", entry.value);
                }
            }
        }
        //计算范围，每个像素对应值的比例
        let yRange:CGFloat = data.showRect.height - data.margins.top - data.margins.bottom - data.valueTopSpan - data.XYAxisLineWidth;
        let range:CGFloat = CGFloat(ma - mi);
        let rate:CGFloat = yRange / range;
        //生成单个条形图的坐标信息
        var startX:CGFloat = 0;
        let startY:CGFloat = (data.showRect.height - data.margins.bottom - data.margins.top);
        for set in self.data.dataSets {
            for entry in set.entrys {
                let height = CGFloat(entry.value)*rate;
                let rect:CGRect = CGRect(x: startX, y: startY-height-data.XYAxisLineWidth, width: data.valueWidth, height: height)
                startX += (data.valueWidth+data.valueSpan);
                entry.rect = rect;
            }
            startX += data.setValueSpan;
        }
        data.contentSizeX = startX;
        //Y轴值的文字和坐标
        if data.drawYAxisValues {
            var tmpY:CGFloat = data.showRect.height - data.margins.bottom;
            var step:Int = 0;
            while tmpY >= data.margins.top {
                let value:Double = mi + Double(data.gridYspan / rate) * Double(step);
                let str:String = String(format: "%.f", value);
                data.yAxisValues.append(str);
                step += 1;
                
                let nsStr = NSString(string: str);
                let width = nsStr.width(with: UIFont.systemFont(ofSize: data.yAxisValuesFontSize));
                let height = nsStr.height(forWidth: data.margins.left, font: UIFont.systemFont(ofSize: data.yAxisValuesFontSize));
                let rect:CGRect = CGRect(x: data.margins.left - data.yAxisValueTailSpan - width, y: tmpY - height/2.0, width: width, height: height);
                data.yAxisValuesRects.append(rect);
                tmpY -= max(data.gridYspan, 1);
            }
        }
        //渐变的间距
        if data.gradientColors.count > 1 {
            data.grddientSpan = CGFloat(ma - mi) / CGFloat(data.gradientColors.count) * rate;
        }
    }
    
    
    
    ///配置视图属性
    private func configSubLayers(data:BarChartData){
        
        self.backgroundColor = data.backColor;
        //滚动视图
        if scrollV == nil {
            scrollV = UIScrollView()
            scrollV.backgroundColor = UIColor.clear;
            scrollV.showsHorizontalScrollIndicator = false;
            scrollV.bounces = false;
            self.addSubview(scrollV);
            scrollV.mas_makeConstraints { (make) in
                make?.left.mas_equalTo()(data.margins.left);
                make?.top.bottom()?.mas_equalTo()(self);
                make?.right.mas_equalTo()(-data.margins.right);
            }
            //触摸手势
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick(tap:)));
            self.addGestureRecognizer(tap);
        }
        //显示图层
        if showLayerV == nil {
            showLayerV = UIView()
            showLayerV.backgroundColor = UIColor.clear;
            scrollV.addSubview(showLayerV);
        }
        //Y坐标轴
        if yAxisLayer == nil {
            yAxisLayer = CAShapeLayer()
            yAxisLayer.fillColor = UIColor.clear.cgColor;
            self.layer.addSublayer(yAxisLayer);
        }
        yAxisLayer.strokeColor = data.XYAxisColor.cgColor;
        yAxisLayer.lineWidth = data.XYAxisLineWidth;
        //X坐标轴
        if xAxisLayer == nil {
            xAxisLayer = CAShapeLayer()
            xAxisLayer.fillColor = UIColor.clear.cgColor;
            self.showLayerV.layer.addSublayer(xAxisLayer);
        }
        xAxisLayer.strokeColor = data.XYAxisColor.cgColor;
        xAxisLayer.lineWidth = data.XYAxisLineWidth;
        //网格
        if gridLayer == nil {
            gridLayer = CAShapeLayer()
            gridLayer.lineJoin = kCALineJoinRound;
            self.showLayerV.layer.addSublayer(gridLayer);
        }
        gridLayer.strokeColor = data.gridColor.cgColor;
        gridLayer.lineWidth = data.gridLineWidth;
        gridLayer.lineDashPattern = data.lineDash;
        //移除旧视图
        removeAllShowLayer()
    }
    
    
    /////移除旧视图
    private func removeAllShowLayer(){
        func removeLayerInArray(arr:[CALayer]){
            for layer in arr {
                layer.removeFromSuperlayer();
            }
        }
        removeLayerInArray(arr: yAxisTextLayers);
        removeLayerInArray(arr: xAxisTextLayers);
        removeLayerInArray(arr: valueTextLayers);
        removeLayerInArray(arr: cacheLayers);
        removeLayerInArray(arr: tintLayers);
        yAxisTextLayers.removeAll();
        xAxisTextLayers.removeAll();
        valueTextLayers.removeAll();
        cacheLayers.removeAll();
        tintLayers.removeAll();
    }
    
    
    ///点击放大
    @objc private func tapClick(tap:UITapGestureRecognizer){
        if data.touchEnable {
            //获取当前点击的位置
            let pos = tap.location(in: self.showLayerV);
            var index:Int = -1;
            for (i,set) in data.dataSets.enumerated() {
                for entry in set.entrys {
                    if entry.rect.contains(pos) {
                        index = i;
                        break;
                    }
                }
                if index >= 0 {break}
            }
            //需要绘制
            if index != lastIndex {
                lastIndex = index;
                for (i,set) in data.dataSets.enumerated() {
                    for entry in set.entrys {
                        for (step,layer) in entry.layers.enumerated() {
                            var color = entry.color;
                            if data.drawGradient && data.gradientColors.count > 1 {
                                color = data.gradientColors[step%data.gradientColors.count];
                            }
                            //当选中的或者全部未选中显示原来的颜色
                            layer.strokeColor = (i == index || index < 0) ? color.cgColor : data.unFocusColor.cgColor;
                        }
                    }
                }
            }
        }
    }
    
    
}



///条形图数据
public class BarChartData:NSObject{
    
    public var dataSets:[BarEntrySet] = []
    ///UI配置
    public var backColor:UIColor = .white               //背景色
    public var valueTopSpan:CGFloat = 20                //条形图最高的距离整个显示区域顶部的间距
    public var valueRightSpan:CGFloat = 20              //整个图表最右多出的剪头间距
    public var showRect:CGRect = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 300)//显示的区域
    public var contentSizeX:CGFloat = 0                 //整个横向内容区域-计算属性
    public var XYAxisLineWidth:CGFloat = 1              //XY轴线宽
    public var XYAxisColor:UIColor = .black             //XY轴线颜色
    public var margins:UIEdgeInsets = UIEdgeInsets.init(top: 30, left: 35, bottom: 30, right: 30)//图形距离屏幕间距
    ///触摸
    public var touchEnable:Bool = true                  //是否可触摸
    public var unFocusColor:UIColor = UIColor.colorHexValue("F0F0F0")//未被选中部分的颜色
    ///绘制值
    public var drawValues:Bool = true                   //是否绘制值文字
    public var valueBottomSpan:CGFloat = 0              //值文字与底下条形图空隙
    public var valueSpan:CGFloat = 1                    //值横向之间的间距
    public var valueWidth:CGFloat = 10                  //单个条形图宽度
    public var setValueSpan:CGFloat = 0                 //组与组的条形图之间的间隙
    public var valueFontSize:CGFloat = 8                //值的字号大小
    ///绘制X轴
    public var drawXAxis:Bool = true                    //是否绘制X轴
    public var drawXAxisValues:Bool = true              //是否绘制X轴文字
    public var xAxisValueColor:UIColor = .black         //X轴颜色
    public var xAxisValueFontSize:CGFloat = 12          //X轴的字号大小
    public var xAxisValueTop:CGFloat = 6                //X轴的文字距离X轴的向上间距
    ///绘制Y轴
    public var drawYAxis:Bool = true                    //是否绘制Y轴
    public var drawYAxisValues:Bool = true              //是否绘制Y轴文字
    public var yAxisValueColor:UIColor = .black         //Y轴文字颜色
    public var yAxisValuesFontSize:CGFloat = 10         //Y轴字号大小
    public var yAxisValueTailSpan:CGFloat = 6           //Y轴文字距离Y轴的向右间距
    ///Y轴计算属性
    public var yAxisValues:[String] = []                //Y轴显示的值
    public var yAxisValuesRects:[CGRect] = []           //Y轴值显示的坐标
    ///网格
    public var drawGridX:Bool = true                    //是否绘制横向网格
    public var drawGridY:Bool = true                    //是否绘制竖向网格
    public var gridColor:UIColor = UIColor.colorHexValue("F0F0F0") //网格颜色
    public var gridXspan:CGFloat = 30                   //网格横向间距
    public var gridYspan:CGFloat = 35                   //网格竖向间距
    public var gridLineWidth:CGFloat = 1                //网格线宽
    public var lineDash:[NSNumber] = [2,10]             //网格虚线样式
    ///绘制渐变
    public var drawGradient:Bool = false                //是否启用渐变
    public var gradientColors:[UIColor] = []            //渐变的颜色组 需要大于一种颜色
    public var grddientSpan:CGFloat = 0                 //渐变间距的计算属性
    ///绘制示例
    public var drawTint:Bool = true
    public var tintSize:CGSize = CGSize(width: 10, height: 10)//示例的颜色块区域大小
    public var tintColorDescMargin:CGFloat = 6                //示例的颜色块与文字间距
    public var tintSpan:CGFloat = 16                          //示例之间的间距
    public var tintDescs:[String] = []                        //示例的描述文案
    public var tintColors:[UIColor] = []                      //示例的颜色
    public var tintMargin:UIEdgeInsets = UIEdgeInsets(top: 30, left: 10, bottom: 0, right: 16)//上左右间距，底部间距不使用
    
    
    ///条形图单个横向数据，可以有多个条形
    public class BarEntrySet:NSObject{
        public var xDesc:String = ""            //X轴的值
        public var entrys:[BarEntry] = []       //单条数据集
        
        public class func initEntrySet(values:[Double],descs:[String],colors:[UIColor],Xdesc:String)->BarEntrySet{
            let set = BarEntrySet();
            set.xDesc = Xdesc;
            for (i,value) in values.enumerated() {
                let desc = i < descs.count ? descs[i] : "";
                let color = i < colors.count ? colors[i] : colors[i%colors.count];
                let entry = BarEntry.initEntry(value: value, desc: desc, color: color);
                set.entrys.append(entry);
            }
            return set;
        }
    }
    
    
    ///条形图单条数据
    public class BarEntry:NSObject{
        public var value:Double = 0                 //值
        public var desc:String = ""                 //描述
        public var color:UIColor = .randomColor()   //颜色
        //计算属性
        public var rect:CGRect!                     //坐标区域
        public var layers:[CAShapeLayer] = []       //所在图层
        
        public class func initEntry(value:Double,desc:String,color:UIColor = .randomColor())->BarEntry{
            let entry = BarEntry();
            entry.value = value;
            entry.desc = desc;
            entry.color = color;
            return entry;
        }
    }
    
    
}
