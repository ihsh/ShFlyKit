//
//  TrainLinesV.swift
//  SHKit
//
//  Created by hsh on 2019/11/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//协议
public protocol TrainLinesVDelegate {
    //选取了起点和终点
    func selectStations(start:String,end:String)
}


///站点路线图
public class TrainLinesV: UIView {
    //Variable
    private var data:TrainStationData!                                                  //数据的引用
    public var delegate:TrainLinesVDelegate?                                            //代理对象
    public var lineWidth:CGFloat = 3                                                    //线宽
    public var lineColor = UIColor.colorRGB(red: 57, green: 115, blue: 211).cgColor     //线的颜色
    public var lineDashPattern:[NSNumber] = [NSNumber.init(value: 8),NSNumber.init(value: 6)]//虚线的样式
    public var arrowLength:CGFloat = 20                                                 //箭头的长度
    public var xSpan:CGFloat = 8                                                        //箭头的X方向的距离
    public var ySpan:CGFloat = 6                                                        //箭头的Y方向的距离，最终是勾股定理x2+y2=z2
    
    
    
    //显示数据
    public func showStations(_ data:TrainStationData){
        //保存对数据的引用
        self.data = data;
        //移除子视图
        for sub in self.subviews {
            sub.removeFromSuperview();
        }
        for sub in self.layer.sublayers ?? [] {
            sub.removeFromSuperlayer();
        }
        //创建CAShapeLayer
        func createLayer()->CAShapeLayer{
            let layer = CAShapeLayer()
            layer.bounds = self.bounds;
            layer.fillColor = UIColor.clear.cgColor;
            layer.strokeColor = lineColor;
            layer.lineWidth = lineWidth;
            layer.lineJoin = kCALineJoinRound;
            return layer;
        }
        //虚线的CAShapeLayer
        let shapeLayer = createLayer();
        shapeLayer.lineDashPattern = lineDashPattern;
        //箭头的CAShapeLayer
        let arrowLayer = createLayer()
        //定义箭头绘制方法
        let arrowPath = CGMutablePath();
        //绘制的起点，水平?,向右?
        func drawArrow(_ start:CGPoint,horizal:Bool,right:Bool){
            if horizal == true {
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x:right ? start.x-arrowLength : start.x+arrowLength, y: start.y));
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x: right ? start.x+1 : start.x-1, y: start.y));
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x:right ? start.x-xSpan : start.x+xSpan, y: start.y-ySpan));
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x:right ? start.x-xSpan : start.x+xSpan, y: start.y+ySpan));
            }else{
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x: start.x, y: start.y-arrowLength));
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x: start.x, y: start.y+2));
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x: start.x-ySpan, y: start.y-xSpan));
                arrowPath.move(to: start);
                arrowPath.addLine(to: CGPoint(x: start.x+ySpan, y: start.y-xSpan));
            }
        }
        //设置路径
        let path = CGMutablePath();
        var last:TrainStationItem!
        
        for (_,item) in data.items.enumerated() {
            //如果没有上一个点
            if last != nil {
                //绘制箭头的起点-顺便计算出来
                var drawPoint:CGPoint!
                //绘制虚线
                if last.isLast == true {
                    path.move(to: CGPoint(x: last.rect.maxX, y: last.rect.midY));
                    if last.isRight {
                        path.addLine(to: CGPoint(x: last.rect.maxX+data.turnSpan, y: last.rect.midY));
                        path.addLine(to: CGPoint(x: last.rect.maxX+data.turnSpan, y: item.rect.midY));
                        path.addLine(to: CGPoint(x: item.rect.maxX, y: item.rect.midY));
                        drawPoint = CGPoint(x: last.rect.maxX+data.turnSpan, y: item.rect.minY);
                    }else{
                        path.addLine(to: CGPoint(x: last.rect.minX-data.turnSpan, y: last.rect.midY));
                        path.addLine(to: CGPoint(x: last.rect.minX-data.turnSpan, y: item.rect.midY));
                        path.addLine(to: CGPoint(x: item.rect.minX, y: item.rect.midY));
                        drawPoint = CGPoint(x: last.rect.minX-data.turnSpan, y: item.rect.minY-5);
                    }
                }else{
                    path.move(to: CGPoint(x: last.rect.maxX, y: last.rect.midY));
                    path.addLine(to: CGPoint(x: item.rect.minX, y: item.rect.midY));
                    if (last.isRight) {
                        drawPoint = CGPoint(x: last.rect.maxX+fabs(item.rect.minX-last.rect.maxX)/4.0*3.0, y: last.rect.midY);
                    }else{
                        drawPoint = CGPoint(x: last.rect.minX-fabs(last.rect.minX-item.rect.maxX)/4.0*3.0 , y: last.rect.midY);
                    }
                }
                //绘制箭头
                drawArrow(drawPoint, horizal: last.isLast == false,right:last.isRight);
            }
            last = item;
        }
        shapeLayer.path = path;
        self.layer .addSublayer(shapeLayer);
        arrowLayer.path = arrowPath;
        self.layer.addSublayer(arrowLayer);
        
        //添加站点
        for (index,item) in data.items.enumerated() {
            let view = UIView()
            view.frame = item.rect;
            view.layer.cornerRadius = 5;
            view.layer.masksToBounds = true;
            view.backgroundColor = data.viewNorColor;
            //赋值引用，后面点击需要改变这个视图的背景色
            item.view = view;
            //标题
            let label = UILabel.initText(item.name, font: data.titleFont, textColor: UIColor.white, alignment: .center, super: view);
            label.adjustsFontSizeToFitWidth = true;
            label.mas_makeConstraints { (make) in
                make?.left.mas_equalTo()(view)?.offset()(3);
                make?.right.mas_equalTo()(view)?.offset()(-3);
                if item.content != nil{
                    make?.bottom.mas_equalTo()(view.mas_centerY)?.offset()(2);
                }else{
                    make?.centerY.mas_equalTo()(view);
                }
            }
            //内容
            if item.content != nil {
                let contentL = UILabel.initText(item.content, font: data.contentFont, textColor: UIColor.white, alignment: .center, super: view);
                contentL.adjustsFontSizeToFitWidth = true;
                contentL.mas_makeConstraints { (make) in
                    make?.left.right()?.mas_equalTo()(view);
                    make?.top.mas_equalTo()(label.mas_bottom);
                }
            }
            //添加按钮
            let btn = UIButton()
            btn.addTarget(self, action: #selector(eventBtnClick(_:)), for: .touchUpInside);
            view.addSubview(btn);
            btn.tag = index;
            btn.mas_makeConstraints { (make) in
                make?.top.right()?.bottom()?.left()?.mas_equalTo()(view);
            }
            self.addSubview(view);
        }
    }
    
    
    
    //点击事件
    @objc private func eventBtnClick(_ sender:UIButton){
        let index = sender.tag;
        //当前已选中的下标
        func indexesOfSelect()->[Int]{
            var tmp:[Int] = [];
            for (i,item) in self.data.items.enumerated() {
                if item.select == true {
                    tmp.append(i);
                }
            }
            return tmp;
        }
        let indexs = indexesOfSelect();
        //处理逻辑
        if indexs.count == 0 {
            //不能点到最后一个
            if index < self.data.items.count - 1 {
               self.data.items[index].select = true;
            }
        }else if indexs.count == 1{
            //选了一个不能再选之前的
            if indexs.last! <= index {
                self.data.items[index].select = !self.data.items[index].select
            }
        }else{
            for item in self.data.items {
                item.select = false;
            }
            if index < self.data.items.count - 1 {
               self.data.items[index].select = true;
            }
        }
        //结果
        let results = indexesOfSelect();
        if results.count == 2 {
            delegate?.selectStations(start: self.data.items[results.first!].name, end: self.data.items[results.last!].name);
        }
        //刷新显示
        for item in self.data.items {
            item.view.backgroundColor = item.select ? data.viewSelectColor : data.viewNorColor;
        }
    }
    
    
    
}




///站点概览信息
public class TrainStationData: NSObject {
    //Variable
    public private(set) var items:[TrainStationItem] = []
    //配置
    public var limitColumn:NSInteger = 3                    //显示的列数
    public var topSpan:CGFloat = 30                         //顶部距离
    public var edgeSpan:CGFloat = 32                        //左右边距
    public var xMargin:CGFloat = 45                         //水平方向山的间距
    public var yMargin:CGFloat = 20                         //垂直方向上的间距
    public var height:CGFloat = 40                          //高度
    public var turnSpan:CGFloat = 10                        //开始拐弯的距离
    public var titleFont:UIFont = kFont(14)                 //标题的字号
    public var contentFont:UIFont = kFont(10)               //小字的字号
    public var viewNorColor:UIColor = UIColor.colorRGB(red: 57, green: 115, blue: 211)
    public var viewSelectColor = UIColor.colorHexValue("F16622")//选中后的背景颜色
    public var useRate:Bool = true                          //UI的距离值使用比例，屏幕宽度与375宽度的比例
    
    
    
    //生成数据-[站点名称]，[附录信息]-例如时间
    public func generate(stations:[String],times:[String]?)->Void{
        //边界限制
        if limitColumn <= 0 {
            limitColumn = 1;
        }else if limitColumn > 4 {
            limitColumn = 4;
        }
        //初始化
        self.items = [];
        //比例
        var rate = ScreenSize().width / 375.0;
        //不使用比例的时候
        if useRate == false {rate = 1}
        //单个宽度
        let width = (ScreenSize().width - edgeSpan * 2 - xMargin * CGFloat(limitColumn - 1)) / CGFloat(limitColumn);
        
        for (i,value) in stations.enumerated(){
            //计算行和列
            let row:CGFloat = CGFloat(i / limitColumn);
            var column:CGFloat = CGFloat(i % limitColumn);
            let item = TrainStationItem();
            //奇数行 0-1-2-3,0算第一行的话
            if ((i/limitColumn) % 2 != 0) {
                column = CGFloat(limitColumn-1) - column;
                item.isRight = false;
            }
            //是否是最后一个
            item.isLast = (i+1)%limitColumn == 0;
            //坐标
            let rect = CGRect(x: edgeSpan * rate + column * (width + xMargin) * rate,
                              y: topSpan * rate + (height + yMargin) * row,
                              width: width * rate,
                              height: height * rate);
            item.rect = rect;
            item.name = value;
            //内容
            if i < times?.count ?? 0 {
                let content = times?[i];
                item.content = content;
            }
            self.items.append(item);
        }
    }
}




///站点信息
public class TrainStationItem: NSObject {
    //Variable
    public var rect:CGRect!                 //显示的坐标
    public var name:String!                 //标题
    public var content:String?              //显示的内容-可选
    public var select:Bool = false          //当前是否被选中
    public var view:UIView!                 //管理的视图
    public var isRight:Bool = true          //是否箭头朝向右边
    public var isLast:Bool = false          //是否是该行最后一个
}
