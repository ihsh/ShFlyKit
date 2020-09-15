//
//  TimeScrollBar.swift
//  SHKit
//
//  Created by hsh on 2020/2/27.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


@objc protocol TimeScrollBarDelegate:NSObjectProtocol {
    //选择时间戳
    func scrollSelectTime(time:TimeInterval);
    //更改刻度视图的属性,在创建后-如果实现，可以修改对应的属性
    @objc optional func modifyTimeScaleConfig(_ view:TimeSpanView);
}


///时间轴选择器
class TimeScrollBar: UIView ,UIScrollViewDelegate{
    //Variable
    public weak var delegate:TimeScrollBarDelegate?
    public var dayTabHet:CGFloat = 40               //日期按钮一栏高度
    public var dayMargin:CGFloat = 10               //日期按钮之间的间距
    public var dayBtnHet:CGFloat = 20               //日期按钮的高度
    public var dayBtnWid:CGFloat = 45               //日期按钮的宽度
    public var leftRigBtnWid:CGFloat = 30           //左右按钮宽度
    public var scaleSpan:CGFloat = 10               //刻度线横向间距
    public var lineColor:UIColor = UIColor.colorHexValue("F2F2F2", alpha: 0.2)//上下线颜色
    public var btnSelectColor:UIColor = UIColor.colorHexValue("F16622");      //按钮选中的时候颜色
    public private(set) var spanViews:[TimeSpanView] = []                     //刻度线视图
    //Private
    private var dayScroll:UIScrollView!             //日期滚动选择
    private var timeScroll:UIScrollView!            //时间滚动选择
    private var indicaterV:UIView!                  //指示条
    //数据
    private var btns:[UIButton] = []                //日期按钮组
    private var datas:[TimeModel] = []              //所有数据
    private var isScroll:Bool = false               //当前是否在滚动
    
    
    //Load
    public func loadData(data:[TimeModel]){
        self.datas = data;
        
        var days:[String] = [];
        for time in data {
            days.append(time.day ?? "");
        }
        //设置日期
        self.setDays(days: days);
        //加载图层
        self.setTimesSpans(spans:self.datas);
        //选中最后一个
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.hightLightBtn(index: data.count - 1);
        }
    }
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //日期滚动条
        dayScroll = UIScrollView();
        self.addSubview(dayScroll);
        dayScroll.mas_makeConstraints { (make) in
            make?.left.right()?.top()?.mas_equalTo()(self);
            make?.height.mas_equalTo()(dayTabHet);
        }
        //时间滚动条
        timeScroll = UIScrollView()
        self.addSubview(timeScroll);
        timeScroll.delegate = self;
        timeScroll.bounces = false;
        timeScroll.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self)?.offset()(leftRigBtnWid);
            make?.right.mas_equalTo()(self)?.offset()(-leftRigBtnWid);
            make?.bottom.mas_equalTo()(self)?.offset()(1);
            make?.top.mas_equalTo()(dayScroll.mas_bottom)?.offset()(-1);
        }
        //上下两条线
        let lineUp:UIView = UIView()
        let lineDown:UIView = UIView();
        lineUp.backgroundColor = lineColor;
        lineDown.backgroundColor = lineColor;
        self.addSubview(lineUp);
        self.addSubview(lineDown);
        lineUp.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(self);
            make?.height.mas_equalTo()(0.5);
            make?.bottom.mas_equalTo()(timeScroll.mas_top);
        }
        lineDown.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(self);
            make?.height.mas_equalTo()(0.5);
            make?.top.mas_equalTo()(timeScroll.mas_bottom);
        }
        //左右点击按钮
        let leftBtn = UIButton()
        leftBtn.layer.addSublayer(self.drawBtnPath(size: CGSize(width: leftRigBtnWid, height: dayTabHet), left: true));
        self.addSubview(leftBtn);
        leftBtn.tag = 0;
        leftBtn.addTarget(self, action: #selector(leftRightBtnClick(_:)), for: .touchUpInside);
        leftBtn.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self);
            make?.centerY.mas_equalTo()(timeScroll);
            make?.width.mas_equalTo()(leftRigBtnWid);
        }
        let rightBtn = UIButton();
        rightBtn.layer.addSublayer(self.drawBtnPath(size: CGSize(width: leftRigBtnWid, height: dayTabHet), left: false));
        self.addSubview(rightBtn);
        rightBtn.tag = 1;
        rightBtn.addTarget(self, action: #selector(leftRightBtnClick(_:)), for: .touchUpInside);
        rightBtn.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(self);
            make?.centerY.mas_equalTo()(timeScroll);
            make?.width.mas_equalTo()(leftRigBtnWid);
        }
        //指示条
        indicaterV = UIView()
        indicaterV.backgroundColor = UIColor.clear;
        self.addSubview(indicaterV);
        indicaterV.mas_makeConstraints { (make) in
            make?.centerX.top()?.bottom().mas_equalTo()(timeScroll);
            make?.width.mas_equalTo()(20);
        }
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.colorHexValue("F16622").cgColor;
        let path = CGMutablePath();
        path.move(to: CGPoint(x: 9, y: 0));
        path.addLine(to: CGPoint(x: 9, y: 90-6));
        path.addLine(to: CGPoint(x: 4, y: 90));
        path.addLine(to: CGPoint(x: 16, y: 90));
        path.addLine(to: CGPoint(x: 11, y: 90-6));
        path.addLine(to: CGPoint(x: 11, y: 0));
        path.addLine(to: CGPoint(x: 9, y: 0));
        shape.path = path;
        shape.frame = CGRect(x: 0, y: 0, width: 20, height: 90);
        indicaterV.layer.addSublayer(shape);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //绘制按钮的路径
    private func drawBtnPath(size:CGSize,left:Bool)->CAShapeLayer{
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.white.cgColor;
        shape.lineWidth = 1;
        shape.lineCap = kCALineCapRound;
        let path = CGMutablePath();
        path.move(to: CGPoint(x: size.width/2.0, y: size.height/2.0-10));
        path.addLine(to: CGPoint(x: size.width/2.0+(left ? -8 : 8), y: size.height/2.0));
        path.addLine(to: CGPoint(x: size.width/2.0, y: size.height/2.0+10));
        shape.path = path;
        return shape;
    }
    
    
    //设置日期
    private func setDays(days:[String]){
        for sub in btns {
            sub.removeFromSuperview()
        }
        btns.removeAll();
        var contentWidth:CGFloat = 0;
        let width:CGFloat = dayBtnWid;
        let height:CGFloat = dayBtnHet;
        let span:CGFloat = dayMargin;
        for (index,str) in days.enumerated() {
            let rect = CGRect(x: span + (width + span) * CGFloat(index),
                              y: (dayTabHet-height)/2.0,
                              width: width, height: height);
            let btn = UIButton.initTitle(str, textColor: .white, back: .clear, font: kFont(12), super: dayScroll);
            btn.addTarget(self, action: #selector(daysBtnClick(sender:)), for:.touchUpInside);
            btn.frame = rect;
            btn.tag = index;
            contentWidth = span + (width + span) * CGFloat(index+1);
            btns.append(btn);
        }
        dayScroll.contentSize = CGSize(width: contentWidth, height: 0);
    }
    
    
    //显示刻度
    private func setTimesSpans(spans:[TimeModel]){
        for sub in spanViews {
            sub.removeFromSuperview();
        }
        var x:CGFloat = 0;
        for (i,model) in spans.enumerated() {
            let spanV = TimeSpanView()
            delegate?.modifyTimeScaleConfig?(spanV);
            spanV.refreshUI();
            spanV.drawLayer(model: model);
            spanV.frame = CGRect(x: x, y: 0, width: spanV.contentWidth, height: spanV.drawHeight);
            timeScroll.addSubview(spanV);
            model.scrollOffsetX = x;
            if i < spans.count - 1 {
                x += spanV.contentWidth;
            }else{
                var last:CGFloat = 0
                for times in model.times{
                    last = max(last,times.endX);
                }
                x += (last + timeScroll.width/2.0);
            }
            spanViews.append(spanV);
        }
        x += (ScreenSize().width-leftRigBtnWid*2)/2.0;
        //实际可滚动距离
        timeScroll.contentSize = CGSize(width: x, height: 0);
    }
    
    
    //日期按钮点击
    @objc private func daysBtnClick(sender:UIButton){
        let index = sender.tag;
        hightLightBtn(index: index);
    
    }
    
    
    //高亮按钮
    private func hightLightBtn(index:Int,scroll:Bool = true){
        for (i,btn) in btns.enumerated() {
            if index == i{
                btn.backgroundColor = btnSelectColor;
                btn.layer.cornerRadius = dayBtnHet/2.0;
                btn.layer.masksToBounds = true;
                btn.isSelected = true;
            }else{
                btn.isSelected = false;
                btn.backgroundColor = .clear;
            }
        }
        if self.datas.count > 0 && scroll {
            let model:TimeModel = self.datas[index];
            self.timeScroll.setContentOffset(CGPoint(x: max(model.scrollOffsetX,35), y: 0), animated: false);
            endScroll(self.timeScroll);
        }
    }
    
    
    //左右按钮点击
    @objc private func leftRightBtnClick(_ sender:UIButton){
        var index:Int = -1;
        for (i,btn) in self.btns.enumerated() {
            if btn.isSelected {
                if sender.tag > 0 {
                    if i < self.btns.count - 1 {
                        index = i + 1;
                    }
                }else{
                    if i > 0 {
                        index = i - 1;
                    }
                }
                break;
            }
        }
        if index >= 0 {
            self.hightLightBtn(index: index);
        }
    }
    
    
    //视图滚动
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.endScroll(scrollView);
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScroll = false;
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            if self.isScroll == false{
                self.endScroll(scrollView);
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScroll = true;
    }
    
    
    //结束滚动的调用方法
    private func endScroll(_ scrollView:UIScrollView){
        //已经调用过就把更改标志位
        isScroll = true;
        //当前游标所在的X
        let half = scrollView.width/2.0;
        let originOffsetX = scrollView.contentOffset.x;
        let offsetX = originOffsetX+half;
        //找出对应的模型
        for (i,data) in self.datas.enumerated() {
            //找到对应模型
            if offsetX >= data.scrollOffsetX && offsetX < (data.scrollOffsetX+data.contentWid) {
                //日期选择
                self.hightLightBtn(index: i,scroll: false);
                //显示出第一天的日期的时候不滚动
                if originOffsetX < 30 {
                    return;
                }
                //找到最近的坐标区间
                var inSpan:Bool = false;
                //从区间中查找,是否在区间中,在就不需要滚动
                for span in data.times{
                    if offsetX >= (span.beginX + data.scrollOffsetX) && offsetX < (span.endX + data.scrollOffsetX) {
                        inSpan = true;
                        delegateChooseSpan(span, distance: offsetX - (span.beginX + data.scrollOffsetX));
                        break;
                    }
                }
                //找不到区间的，找最近的
                if inSpan == false {
                    var distance:CGFloat = data.contentWid;
                    //能进入循环一定有最近的一个的
                    var targetSpan:TimeModel.TimeSpan!
                    for span in data.times{
                        let start:CGFloat = data.scrollOffsetX + span.beginX;
                        let end:CGFloat = data.scrollOffsetX + span.endX;
                        let sub1 = fabs(offsetX - start);
                        let sub2 = fabs(offsetX - end+10);//离尾巴稍微远一点
                        //最短距离
                        let minimum = min(sub1,sub2);
                        if minimum < distance {
                            targetSpan = span;
                            distance = minimum;
                        }
                    }
                    //滚动到该区域的起点
                    let targetOffsetX:CGFloat = (data.scrollOffsetX + targetSpan.beginX) - half;
                    self.timeScroll.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true);
                    delegateChooseSpan(targetSpan, distance: 0);
                }
            }
        }
    }
    
    
    //当前选中时间范围
    private func delegateChooseSpan(_ span:TimeModel.TimeSpan,distance:CGFloat){
        let sub:CGFloat = span.endX - span.beginX;
        let timeSub:TimeInterval = span.end - span.start;
        let rate:CGFloat = distance/sub;
        let curTime:TimeInterval = timeSub * TimeInterval(rate) + span.start;
        let final = TimeInterval(Int(curTime));
        delegate?.scrollSelectTime(time: final);
    }
    
    
}













//加载日期刻度的视图
class TimeSpanView: UIView {
    //variable
    public var scaleColor:UIColor = UIColor.colorHexValue("FFFFFF", alpha: 0.3)         //刻度线颜色
    public var spanColor:UIColor = UIColor.colorHexValue("F16622", alpha: 0.3)          //范围颜色
    public var hitColor:UIColor = UIColor.colorHexValue("F16622", alpha: 0.6)           //高亮颜色
    public var floorLineColor:UIColor = UIColor.colorHexValue("F16622", alpha: 0.1)     //底部线颜色
    
    public var textFont:CGFloat = 12                        //字号
    public var drawHeight:CGFloat = 90                      //绘制的高度
    public var spanY:CGFloat = 10                           //刻度线Y起点
    public var scaleSpan:CGFloat = 10                       //刻度线横向间距
    public var shortHeight:CGFloat = 40                     //刻度线最短高度
    public private(set) var contentWidth:CGFloat = 0        //视图初始化后的宽度
    //private
    private var scalelayer:CAShapeLayer!                    //刻度图层
    private var spanLayer:CAShapeLayer!                     //时间范围图层
    private var hitLayer:CAShapeLayer!                      //高亮图层
    private var dayTextLayer:CATextLayer!                   //当天的文本
    private var mi:CGFloat = 0                              //最小范围值
    private var ma:CGFloat = 0                              //最大范围值
    

    //Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        scalelayer = CAShapeLayer()
        self.layer.addSublayer(scalelayer);
        //范围图层
        spanLayer = CAShapeLayer();
        self.layer.addSublayer(spanLayer);
        //高亮图层
        hitLayer = CAShapeLayer();
        self.layer.addSublayer(hitLayer);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //创建UI
    public func refreshUI(){
        contentWidth = 0;
        //画刻度线图层
        for sub in scalelayer.sublayers ?? [] {
            sub.removeFromSuperlayer();
        }
        scalelayer.strokeColor = scaleColor.cgColor;
        scalelayer.lineWidth = 1;
        //创建时间图层
        let path = CGMutablePath();
        var count:Int = 0;//整点计数
        //需要多少个刻度
        for i in 0...(12*24-1) {
            //每半小时一个长刻度
            if i%6 == 0 {
                //添加时间文本
                let textLayer = drawTextLayer();
                if count % 2 == 0 {
                    textLayer.string = String(format: "%ld:00", count/2);
                }else{
                    textLayer.string = String(format: "%ld:30", Int(floor(Double(count)/2.0)));
                }
                textLayer.frame = CGRect(x:contentWidth+6, y: drawHeight-23, width: 60, height: 15);
                scalelayer.addSublayer(textLayer);
                //当天的文本
                if i == 0 {
                    dayTextLayer = drawTextLayer();
                    dayTextLayer.frame = CGRect(x: contentWidth+6, y: spanY, width: 60, height: 15);
                    scalelayer.addSublayer(dayTextLayer);
                }
                count += 1;
                //刻度
                path.move(to: CGPoint(x: contentWidth, y: spanY));
                path.addLine(to: CGPoint(x: contentWidth, y: drawHeight-spanY));
            }else{
                path.move(to: CGPoint(x: contentWidth, y: (drawHeight-shortHeight)/2.0));
                path.addLine(to: CGPoint(x: contentWidth, y: (drawHeight-shortHeight)/2.0+shortHeight));
            }
            contentWidth += scaleSpan;
        }
        scalelayer.path = path;
        scalelayer.frame = CGRect(x: 0, y: 0, width: contentWidth, height: drawHeight);
        //范围图层
        spanLayer.frame = CGRect(x: 0, y: 0, width: contentWidth, height: drawHeight);
        spanLayer.fillColor = spanColor.cgColor;
        spanLayer.lineWidth = 1;
        spanLayer.strokeColor = floorLineColor.cgColor;
        //高亮图层
        hitLayer.frame = CGRect(x: 0, y: 0, width: contentWidth, height: drawHeight);
        hitLayer.fillColor = hitColor.cgColor;
        hitLayer.lineWidth = 1;
        hitLayer.strokeColor = hitColor.cgColor;
    }
    
    
    //画区域
    public func drawLayer(model:TimeModel){
        let date = Date(timeIntervalSince1970: model.dayBegin);
        let format:DateFormatter = DateFormatter();
        format.dateFormat = "MM/dd";
        let str:String = format.string(from: date);
        dayTextLayer.string = str;
        
        let path = CGMutablePath();
        var mi:CGFloat = 0;
        var ma:CGFloat = 0;
        for time in model.times {
            path.move(to: CGPoint(x: time.beginX, y: 0));
            path.addRect(CGRect(x: time.beginX, y: 0, width: (time.endX-time.beginX), height: drawHeight))
            mi = mi == 0 ? time.beginX : min(mi, time.beginX);
            ma = max(ma,time.endX);
        }
        //画底部线
        path.move(to: CGPoint(x: mi, y: drawHeight));
        path.addLine(to: CGPoint(x: ma, y: drawHeight));
        spanLayer.path = path;
        //高亮区域
        let path2 = CGMutablePath();
        for hit in model.hits {
            path2.move(to: CGPoint(x: hit.beginX, y: 0));
            path2.addRect(CGRect(x: hit.beginX, y: 0, width: (hit.endX-hit.beginX), height: drawHeight))
            mi = mi == 0 ? hit.beginX : min(mi, hit.beginX);
            ma = max(ma,hit.endX);
        }
        //画顶部线
        path2.move(to: CGPoint(x: mi, y: 0));
        path2.addLine(to: CGPoint(x: ma, y: 0));
        hitLayer.path = path2;
    }
    
    
    //创建文本图层
    private func drawTextLayer()->CATextLayer{
        let text = CATextLayer()
        text.contentsScale = UIScreen.main.scale;
        text.foregroundColor = scaleColor.cgColor;
        text.fontSize = textFont;
        return text;
    }
    
    
}




//时间模型
class TimeModel:NSObject{
    public var day:String!                                  //日期的文字
    public var dayBegin:TimeInterval = 0                    //日期起点的时刻
    public var contentWid:CGFloat = 0                       //暂存,外部使用4
    public var scrollOffsetX:CGFloat = 0                    //滚动的坐标起点
    public private(set) var times:[TimeSpan] = []           //有录像时间间隔
    public private(set) var hits:[TimeSpan] = []            //有移动的时间间隔-应该包含在times的范围内
    
    
    //获取当前日期的0点时间戳
    private func makeOrigin(time:TimeInterval){
        let calendar:NSCalendar = NSCalendar.current as NSCalendar;
        let date:NSDate = NSDate.init(timeIntervalSince1970: time);
        let components:NSDateComponents = calendar.components([.day,.year,.month], from: date as Date) as NSDateComponents;
        let new:NSDate = calendar.date(from: components as DateComponents)! as NSDate;
        dayBegin = new.timeIntervalSince1970;
    }
    
    
    //添加有录像的时间范围
    public func appendTimeSpan(start:TimeInterval,end:TimeInterval,width:CGFloat){
        if dayBegin == 0 {self.makeOrigin(time: start)}
        self.contentWid = width;
        let span = TimeSpan.initSpan(start: start, end: end, origin: dayBegin,width: width)
        times.append(span);
    }
    
    
    //添加有移动的时间范围-高亮
    public func appendHitSpan(start:TimeInterval,end:TimeInterval,width:CGFloat){
        if dayBegin == 0 {self.makeOrigin(time: start)}
        self.contentWid = width;
        let span = TimeSpan.initSpan(start: start, end: end, origin: dayBegin,width: width)
        hits.append(span);
    }
    
    
    
    //时间模型
    class TimeSpan:NSObject{
        public var start:TimeInterval = 0       //起点时间戳
        public var end:TimeInterval = 0         //终点时间戳
        public var beginX:CGFloat = 0           //起点的坐标X
        public var endX:CGFloat = 0             //终点的坐标X
        
        
        /// 初始化方法
        /// - Parameters:
        ///   - start: 时间段起点时间戳
        ///   - end: 时间段终点时间戳
        ///   - origin: 当天0点时间戳
        ///   - width: 总宽度
        public class func initSpan(start:TimeInterval,end:TimeInterval,origin:TimeInterval,width:CGFloat)->TimeSpan{
            let span = TimeSpan()
            span.start = start;
            span.end = end;
            span.beginX = CGFloat(start-origin)/CGFloat(86400.0)*width;
            span.endX = CGFloat(end-origin)/CGFloat(86400.0)*width;
            return span;
        }
        
    }
    
    
}
