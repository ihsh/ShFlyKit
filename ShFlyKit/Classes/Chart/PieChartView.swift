//
//  PieChartView.swift
//  ShFlyKit
//
//  Created by mac on 2020/11/23.
//


import UIKit


///通用饼图
public class PieChartView: UIView  {
    //外界可获取判断类型进行修改
    public private(set) var textLayers:[CATextLayer] = []   //文字图层
    public private(set) var otherLayer:[CALayer] = []       //其他附属图层-分割线,线，两个中心图层
    public private(set) var centerLayer:CAShapeLayer!       //中心图层
    //private
    private var layers:[CAShapeLayer] = []          //饼图图层
    private var data:PieData!                       //数据
    private var bgCirCleLayer:CAShapeLayer!         //动画遮罩层
    private var spanLayer:CAShapeLayer!             //分割线图层
    private var lineLayer:CAShapeLayer!             //描绘线图层
    private var startAngle:CGFloat = 0              //起始偏移角度-会累积
    private var addAngle:CGFloat = 0                //新起的角度差
    
    
    //Interface
    ///绘制饼图
    public func showPie(_ data:PieData){
        self.data = data;
        //计算数据
        self.calculData(self.data);
        //绘制添加图层
        self.drawLayers();
        //动画
        if data.animateEnable {
            self.animate();
        }
    }
   
    
    //计算
    private func calculData(_ data:PieData){
        var total:Double = 0;
        for entry in data.dataSet {
            total += entry.value;
        }
        //排序
        if data.sortEnable {
            data.dataSet.sort { (entry1, entry2) -> Bool in
                return entry1.value > entry2.value;
            }
        }
        //计算角度
        var start:CGFloat = 0;
        for entry in data.dataSet {
            let rate:CGFloat = CGFloat(entry.value / total);//百分比
            entry.start = start;
            entry.angle = rate;
            start += rate;
        }
    }
    
    
    //绘制图层
    private func drawLayers(){
        let center = data.center;
        //动画
        if data.animateEnable {
            let maskPath = CGMutablePath();
            var startAngle:CGFloat = data.animateStartAngle;
            if startAngle != 0 {
                startAngle = min(startAngle, 1);
                startAngle = max(-1, startAngle);
                startAngle = (startAngle * 6.3);
            }
            maskPath.addArc(center: center, radius: data.radius, startAngle: startAngle, endAngle: 6.3, clockwise: false);
            
            bgCirCleLayer = CAShapeLayer();
            bgCirCleLayer.fillColor = UIColor.clear.cgColor;
            bgCirCleLayer.strokeColor = UIColor.white.cgColor;
            bgCirCleLayer.lineWidth = data.radius*2;
            bgCirCleLayer.zPosition = 1;
            bgCirCleLayer.path = maskPath;
            self.layer.mask = bgCirCleLayer;
        }
        //清除图层
        for layer in self.layers {
            layer.removeFromSuperlayer();
        }
        for layer in self.otherLayer {
            layer.removeFromSuperlayer();
        }
        for layer in self.textLayers {
            layer.removeFromSuperlayer();
        }
        self.layers.removeAll();
        self.otherLayer.removeAll();
        self.textLayers.removeAll();
        
        //添加各个饼图
        let extAngle:CGFloat = startAngle;
        for (i,entry) in data.dataSet.enumerated() {
            if i < data.dataSet.count {
                let path = CGMutablePath();
                path.move(to: center);
                path.addArc(center: center, radius: data.radius,
                            startAngle: (entry.start)*2*CGFloat(M_PI)+extAngle,
                            endAngle: (entry.start+entry.angle)*2*CGFloat(M_PI)+extAngle, clockwise: false);
                entry.path = path;
                
                let pie = CAShapeLayer();
                pie.fillColor = entry.color.cgColor;
                pie.strokeColor = UIColor.clear.cgColor
                pie.zPosition = 1;
                pie.path = path;
                self.layer.addSublayer(pie);
                self.layers.append(pie);
            }
        }
        //画白色分割线
        if data.sliceEnable {
            let path = CGMutablePath();
            for (i,entry) in data.dataSet.enumerated() {
                path.move(to: center);
                let endAngle:CGFloat = (entry.start+entry.angle)*2*CGFloat(M_PI);
                let radius:CGFloat = data.zoomEnable ? (data.radius + data.zoomRadius) : data.radius;
                let x:CGFloat = radius * cos(endAngle);
                let y:CGFloat = radius * sin(endAngle);
                let newPos:CGPoint = CGPoint(x: center.x + x, y: center.y + y);
                path.addLine(to: newPos);
            }
            let spanLayer = CAShapeLayer();
            spanLayer.fillColor = UIColor.clear.cgColor;
            spanLayer.strokeColor = UIColor.white.cgColor
            spanLayer.lineWidth = data.sliceSpan;
            spanLayer.zPosition = 1;
            spanLayer.path = path;
            self.spanLayer = spanLayer;
            self.otherLayer.append(spanLayer);
            self.layer.addSublayer(spanLayer);
        }
        //画圈
        if (data.style == .Hole || data.style == .Circle){
            let path = CGMutablePath();
            path.move(to: center);
            path.addArc(center: center, radius: data.holeRadius, startAngle: 0, endAngle: 6.3, clockwise: false);
            
            centerLayer = CAShapeLayer();
            centerLayer.fillColor = UIColor.white.withAlphaComponent((data.style == .Hole ? 1 : data.circleHoldAlpha)).cgColor;
            centerLayer.strokeColor = UIColor.clear.cgColor;
            centerLayer.zPosition = 2;
            centerLayer.path = path;
            
            if data.style == .Hole {
                self.layer.addSublayer(centerLayer);
                self.otherLayer.append(centerLayer);
            }else{
                //添加更大一圈
                let pathLarge = CGMutablePath();
                pathLarge.move(to: center);
                pathLarge.addArc(center: center, radius: data.holeRadius+data.circleExpand, startAngle: 0, endAngle: 6.3, clockwise: false);
                let layerLarge = CAShapeLayer();
                layerLarge.fillColor = UIColor.white.withAlphaComponent(data.circleLargeAlpha).cgColor;
                layerLarge.strokeColor = UIColor.clear.cgColor;
                layerLarge.zPosition = 2;
                layerLarge.path = pathLarge;
                
                self.layer.addSublayer(layerLarge);
                self.otherLayer.append(layerLarge);
                
                self.layer.addSublayer(centerLayer);
                self.otherLayer.append(centerLayer);
            }
        }
        //点击
        if data.zoomEnable {
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick(tap:)));
            self.addGestureRecognizer(tap);
        }
        //绘制线和值
        if data.drawlineAndDescEnable {
            lineLayer = CAShapeLayer();
            lineLayer.fillColor = UIColor.clear.cgColor;
            lineLayer.strokeColor = data.lineColor.cgColor;
            lineLayer.lineWidth = 1;
            lineLayer.zPosition = 1;
            self.layer.addSublayer(lineLayer);
            self.otherLayer.append(lineLayer);
            //第一次赋值
            lineLayer.path = rotationLinesPath();
        }
    }
    
    
    //动画
    private func animate(){
        let ani = CABasicAnimation.init(keyPath: "strokeEnd");
        ani.duration = data.duration;
        ani.fromValue = 0;
        ani.toValue = 1;
        ani.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        ani.isRemovedOnCompletion = true;
        bgCirCleLayer.add(ani, forKey: "circleAnimation");
    }
    
    
    ///点击放大
    @objc private func tapClick(tap:UITapGestureRecognizer){
        let pos = tap.location(in: self);
        let extAngle = startAngle + addAngle;
        for (i,entry) in data.dataSet.enumerated(){
            if entry.path != nil {
                if entry.path!.contains(pos) {
                    let path = CGMutablePath();
                    path.move(to:data.center );
                    path.addArc(center: data.center, radius: (data.radius + data.zoomRadius),
                                startAngle: (entry.start)*2*CGFloat(M_PI)+extAngle,
                                endAngle: (entry.start+entry.angle)*2*CGFloat(M_PI)+extAngle,
                                clockwise: false);
                    let layer = self.layers[i];
                    layer.path = path;
                }else{
                    let layer = self.layers[i];
                    layer.path = entry.path;
                }
            }
        }
    }
    
    
    //旋转
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if data.rotationEnable {
            let touch = ((touches as NSSet).anyObject() as AnyObject)
            //两个点
            let pos = touch.location(in: self);
            let center:CGPoint = data.center;//中心
            //求反正弦
            let ab:CGFloat = pos.x - center.x;
            let bc:CGFloat = pos.y - center.y;
            let angle = atan2(bc, ab);
            //新的一次触摸操作
            if addAngle == 0 {
                addAngle = (startAngle - angle);
            }
            startAngle = angle;
            //旋转
            self.rotation();
        }
    }
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //将之前的差值合并
        startAngle = (startAngle + addAngle);
        addAngle = 0;
    }

    
    //旋转
    private func rotation(){
        //添加各个饼图
        let center:CGPoint = data.center;
        let extAngle = startAngle + addAngle;
        //饼图
        for (i,entry) in data.dataSet.enumerated() {
            if i < data.dataSet.count {
                let path = CGMutablePath();
                path.move(to: center);
                path.addArc(center: center, radius: data.radius,
                            startAngle: (entry.start)*2*CGFloat(M_PI)+extAngle,
                            endAngle: (entry.start+entry.angle)*2*CGFloat(M_PI)+extAngle,
                            clockwise: false);
                entry.path = path;
                
                let pie = self.layers[i];
                pie.path = path;
            }
        }
        //分割线跟着旋转
        if spanLayer != nil {
            let path = CGMutablePath();
            for (i,entry) in data.dataSet.enumerated() {
                path.move(to: center);
                let endAngle:CGFloat = (entry.start+entry.angle)*2*CGFloat(M_PI)+extAngle;
                let radius:CGFloat = data.zoomEnable ? (data.radius + data.zoomRadius) : data.radius;
                let x:CGFloat = radius * cos(endAngle);
                let y:CGFloat = radius * sin(endAngle);
                let newPos:CGPoint = CGPoint(x: center.x + x, y: center.y + y);
                path.addLine(to: newPos);
            }
            spanLayer.path = path;
        }
        //描述线
        if lineLayer != nil {
            lineLayer.path = rotationLinesPath();
        }
        
    }
    
    
    //生成分割线的路径
    private func rotationLinesPath()->CGMutablePath{
        let center = data.center;
        //根据中心、半径、角度生成新点
        func generatePos(radius:CGFloat,angle:CGFloat)->CGPoint{
            let x:CGFloat = radius * cos(angle);
            let y:CGFloat = radius * sin(angle);
            let newPos:CGPoint = CGPoint(x: center.x + x, y: center.y + y);
            return newPos;
        }
        //计算描述线横折后的终点
        func sidePos(pos:CGPoint,engle:CGFloat)->CGPoint{
            let rate:CGFloat = (fabs(pos.y - center.y)/data.radius);                //计算离中心Y的距离比例
            let length:CGFloat = data.lineLength * rate + data.drawLineInnerEnd;    //越靠近中心线越短
            let new:CGPoint = CGPoint(x: pos.x + ((pos.x < center.x) ? -length : length), y: pos.y);
            return new;
        }
        //绘制线条
        var tmpPos:[CGPoint] = [];
        let extAngle = startAngle + addAngle;
        let path = CGMutablePath();
        for (i,entry) in data.dataSet.enumerated() {
            let endAngle:CGFloat = (entry.start+entry.angle/2.0)*2*CGFloat(M_PI) + extAngle;          //线的终点
            let pos1 = generatePos(radius: data.radius - data.drawLineInnerStart, angle: endAngle);   //起点
            let pos2 = generatePos(radius: data.radius - data.drawLineInnerEnd, angle: endAngle);     //转折点
            let pos3 = sidePos(pos: pos2, engle: endAngle);
            
            if entry.desc.count > 0 {
                path.move(to: pos1);
                path.addLine(to: pos2);
                path.addLine(to: pos3);
            }
            tmpPos.append(pos3);
        }
        //添加动画，加快文字的跟随
        func addPositionAnimate(layer:CATextLayer,pos:CGPoint){
            let ani = CABasicAnimation.init(keyPath: "position");
            ani.duration = 0.1; //再小没效果
            let rect = layer.frame;
            ani.fromValue = CGPoint(x: (rect.origin.x + rect.size.width/2.0), y: (rect.origin.y + rect.size.height/2.0));
            ani.toValue = pos;
            ani.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            ani.isRemovedOnCompletion = true;
            layer.add(ani, forKey: "postion");
        }
        //计算文字的坐标
        func makeFrame(first:Bool){
            
            for (i,entry) in data.dataSet.enumerated() {
                if entry.desc.count > 0 {
                    //计算文字宽高
                    let str:NSString = entry.desc as! NSString;
                    if entry.width == 0 {
                        entry.width = str.width(with: UIFont.systemFont(ofSize: data.descFontSize));
                        entry.height = str.height(forWidth:CGFloat(MAXFLOAT), font: UIFont.systemFont(ofSize: data.descFontSize));
                    }
                    let pos:CGPoint = tmpPos[i];//取线的终点
                    let rect:CGRect = CGRect(x: pos.x + ((pos.x < center.x) ? -(entry.width + data.drawLineAndDescSpan) : data.drawLineAndDescSpan),
                                             y: pos.y - entry.height/2.0, width: entry.width, height: entry.height);
                    let layer:CATextLayer = textLayers[i];
                    if first {
                        layer.frame = rect;
                    }else{
                        layer.frame = rect;
                        addPositionAnimate(layer: layer, pos: CGPoint(x: rect.origin.x + rect.size.width/2.0, y: rect.origin.y + rect.size.height/2.0));
                    }
                }
            }
        }
        //添加文字图层
        if data.drawlineAndDescEnable {
            if self.textLayers.count == 0 {
                for (i,entry) in data.dataSet.enumerated() {
                    let layer = CATextLayer();
                    layer.contentsScale = UIScreen.main.scale;
                    layer.fontSize = data.descFontSize;
                    layer.string = entry.desc;
                    layer.foregroundColor = data.descColor.cgColor;
                    textLayers.append(layer);
                    lineLayer.addSublayer(layer);
                }
                makeFrame(first: true);
            }else{
                makeFrame(first: false);
            }
        }
        return path;
    }
    
}




///饼图数据
public class PieData:NSObject{
    ///重要数据
    public var style:PieCenterType = .Hole          //样式
    public var dataSet:[Entry] = []                 //数据
    public var sortEnable:Bool = true               //数据是否从大到小排序
    ///重要UI配置
    public var center = CGPoint(x: 200, y: 300)     //中心坐标
    public var radius:CGFloat = 130                 //圆半径
    public var holeRadius:CGFloat = 40              //中心圆半径
    public var circleExpand:CGFloat = 6             //中心大圆比中心圆多加的半径
    public var circleHoldAlpha:CGFloat = 0.9        //中心圆的透明度
    public var circleLargeAlpha:CGFloat = 0.8       //中心大圆的透明度
    ///动画
    public var animateEnable:Bool = true            //动画展开
    public var animateStartAngle:CGFloat = 0        //展开角度
    public var duration:TimeInterval = 1            //动画时长
    ///分割样式
    public var sliceEnable:Bool = false             //是否分割线
    public var sliceSpan:CGFloat = 3                //分割线距离
    ///放大
    public var zoomEnable:Bool = true               //是否可点击放大
    public var zoomRadius:CGFloat = 15              //放大时多的半径
    ///旋转
    public var rotationEnable:Bool = true           //是否可以旋转
    public var startAngleRate:CGFloat = 0           //起始角度 0-1
    ///线和文字
    public var drawlineAndDescEnable:Bool = true    //是否绘制线和文字
    public var descFontSize:CGFloat = 10            //文字的字号
    public var descColor:UIColor = .randomColor()   //文字的颜色
    public var lineColor:UIColor = .black           //线条的颜色
    public var lineLength:CGFloat = 30              //线从圆边缘向外辐射的半径
    public var drawLineInnerStart:CGFloat = 15      //线第一个起点距圆的距离
    public var drawLineInnerEnd:CGFloat = 5         //线第二个点-即转折点,距圆的距离
    public var drawLineAndDescSpan:CGFloat = 5      //线与文字的间距
    
    
    
    public enum PieCenterType {
        case None,Hole,Circle //无，挖孔，中间圆
    }
    
    
    //实体数据
    public class Entry:NSObject{
        public var value:Double = 0         //值
        public var desc:String = ""         //描述
        public var color:UIColor = .randomColor()//饼图块颜色
        //自动计算
        public var angle:CGFloat = 0        //角度大小
        public var start:CGFloat = 0        //角度起点
        public var path:CGMutablePath?      //饼图的初始path
        public var width:CGFloat = 0        //文字宽度
        public var height:CGFloat = 0       //文字高度
       
        
        public class func inits(value:Double,desc:String = "",color:UIColor = .randomColor())->Entry{
            let entry = Entry();
            entry.value = value;entry.desc = desc;entry.color = color;
            entry.desc = desc;
            return entry;
        }
        
    }
    
    
}
