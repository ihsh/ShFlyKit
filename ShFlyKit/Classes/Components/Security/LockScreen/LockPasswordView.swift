//
//  LockPasswordView.swift
//  SHKit
//
//  Created by hsh on 2018/10/24.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


//选择的密码
protocol PassWordDeleagate:NSObjectProtocol {
    func passWordDidEndInput(pwd:String)            //密码输入完成
    func passWordDidChange(pwd:String)              //密码改变中
    func passWordDidChangeIndex(index:Int,select:Bool)
}


///圈选密码类
class LockPasswordView: UIView {
    // MARK
    public weak var delegate:PassWordDeleagate?
    public var forbid:Bool = false                          //禁止操作
    
    public var kCircleRadius:CGFloat = 30.0                 //圈的大小
    public var kCircleBetweenMargin:CGFloat = 40.0          //圈之间间距
    public var kPathWidth:CGFloat = 10.0                    //连线的宽度
    public var kMinPasswordLength:NSInteger = 4             //密码的长度
    public var showPath:Bool = true                         //路径是否可见
    
    public var normalColor:UIColor = UIColor.colorRGB(red: 102, green: 109, blue: 112)                  //正常的颜色
    public var highlightedColor:UIColor = UIColor.colorRGB(red: 59, green: 112, blue: 175)                //高亮的颜色
    public var errorColor:UIColor?                          //错误的颜色
    
    //私有变量
    public var isTracking:Bool = false                      //是否正在画轨迹
    public var trackingIds = NSMutableArray(capacity: 9)    //轨迹的ID
    public var previousTouchPoint:CGPoint!                  //上一个点
    
    private var circleLayers = NSMutableArray(capacity: 9)  //保存9个孔的图层
    private var pathLayer:LockPathLayer!                    //路径图层
    private var impact:UIImpactFeedbackGenerator!           //振动器
    
    
    
    ///Mark Interface
    //外部检查的结果回传
    public func checkResult(isError:Bool){
        var circleLayer:LockCircleLayer
        for i in 0 ... 2 {
            for j in 0 ... 2{
                circleLayer = self.circleLayers.object(at: i*3+j) as! LockCircleLayer
                circleLayer.isError = isError;
                circleLayer.setNeedsDisplay()
            }
        }
        self.pathLayer.isError = isError;
        self.pathLayer.setNeedsDisplay()
    }
    
    
    //重置跟踪点状态
    public func resetTrackingState()->Void{
        self.isTracking = false
        var circleLayer:LockCircleLayer!
        for i in 0...8{
            circleLayer = self.circleLayers.object(at: i) as? LockCircleLayer
            circleLayer.highlighted = false
            circleLayer.isError = false;
            circleLayer.setNeedsDisplay()
        }
        self.trackingIds.removeAllObjects()
        self.pathLayer.isError = false;
        self.pathLayer.setNeedsDisplay()
    }
    
    
    //Load
    ///初始化
    private func commonInit()->Void{
        //路径
        self.pathLayer = LockPathLayer()
        self.pathLayer.contentsScale = UIScreen.main.scale
        self.pathLayer.passwordView = self
        self.layer.addSublayer(self.pathLayer)
        self.backgroundColor = UIColor.clear;
        impact = UIImpactFeedbackGenerator.init(style: .light);
        //添加9个圈
        var circleLayer:LockCircleLayer
        for _ in 0 ... 2 {
            for _ in 0 ... 2{
                circleLayer = LockCircleLayer()
                circleLayer.contentsScale = UIScreen.main.scale
                circleLayer.passwordView = self
                self.circleLayers .add(circleLayer)
                self.layer .addSublayer(circleLayer)
            }
        }
        self.setLayerFrames()
    }
 
    
    //绘制初始位置
    private func setLayerFrames()->Void{
        let leftMargin = (self.bounds.size.width - (6*kCircleRadius + 2*kCircleBetweenMargin))/2
        var circleLayer:LockCircleLayer
        for i in 0 ... 2 {
            for j in 0 ... 2{
                let x = leftMargin + CGFloat(j) * (kCircleRadius * 2 + kCircleBetweenMargin)
                let y = 10 + CGFloat(i) * (kCircleRadius * 2 + kCircleBetweenMargin)
                circleLayer = self.circleLayers.object(at: i*3+j) as! LockCircleLayer
                circleLayer.frame = CGRect(x: x, y: y, width: kCircleRadius*2, height: kCircleRadius*2)
                circleLayer.setNeedsDisplay()
            }
        }
        self.pathLayer.frame = self.bounds
        self.pathLayer.setNeedsDisplay()
    }
    
    
    
    ///Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if forbid {
            return;
        }
        self.pathLayer.showPath = showPath;
        self.isTracking = false
        //清空轨迹
        self.resetTrackingState()
        //收集第一个点
        let touch = ((touches as NSSet).anyObject() as AnyObject)
        self.previousTouchPoint = touch.location(in: self)
        
        var circleLayer:LockCircleLayer!
        for i in 0...8{
            circleLayer = self.circleLayers.object(at: i) as? LockCircleLayer
            circleLayer.showPath = showPath;
            if (self.containPointInCircle(point: previousTouchPoint, rect: circleLayer.frame)){
                circleLayer.highlighted = true
                circleLayer.setNeedsDisplay()
                self.isTracking = true
                self.trackingIds.add(NSNumber.init(value: i))
                let pwd = self.generatePassword(array: self.trackingIds)
                delegate?.passWordDidChange(pwd: pwd);
                delegate?.passWordDidChangeIndex(index: i,select: true);
                impact.impactOccurred();
            }
        }
        self.pathLayer.setNeedsDisplay()
    }
    
    
    //移动过程中
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if forbid {
            return;
        }
        if (self.isTracking) {
            let touch = ((touches as NSSet).anyObject() as AnyObject)
            //更新当前点
            self.previousTouchPoint = touch.location(in: self)
            var circleLayer:LockCircleLayer!
            for i in 0...8{
                circleLayer = self.circleLayers.object(at: i) as? LockCircleLayer
                if (self.containPointInCircle(point: previousTouchPoint, rect: circleLayer.frame)){
                    if (self.hasVistedCircle(circleId: i)==false){
                        circleLayer.highlighted = true
                        circleLayer.setNeedsDisplay()
                        self.trackingIds.add(NSNumber.init(value: i))
                        impact.impactOccurred();
                        let pwd = self.generatePassword(array: self.trackingIds)
                        delegate?.passWordDidChange(pwd: pwd);
                        delegate?.passWordDidChangeIndex(index: i,select: true);
                        break;
                    }
                }
            }
            self.pathLayer.setNeedsDisplay()
        }
    }
    
    
    //触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if forbid {
            return;
        }
        self.previousTouchPoint = nil;
        self.pathLayer.setNeedsDisplay()
        //获取密码
        let pwd = self.generatePassword(array: self.trackingIds)
        if pwd.count >= kMinPasswordLength {
            self.delegate?.passWordDidEndInput(pwd: pwd);
        }else{
            //警告密码长度不够
            self.checkResult(isError: true);
        }
    }
    
    
    //触摸取消
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        //清空轨迹
        self.resetTrackingState()
    }
    
    
    //该点是否已经连过
    private func hasVistedCircle(circleId:NSInteger)->Bool{
        var hasVisit = false
        for num in self.trackingIds{
            let number:NSNumber = num as! NSNumber
            if (number.intValue == circleId) {
                hasVisit = true
                break
            }
        }
        return hasVisit
    }
    
    
    //判断是否点在圈内
    private func containPointInCircle(point:CGPoint,rect:CGRect)->Bool{
        let center:CGPoint = CGPoint(x: rect.origin.x+rect.size.width/2, y: rect.origin.y+rect.size.height/2)
        let isContain = ((center.x-point.x)*(center.x-point.x)+(center.y-point.y)*(center.y-point.y) - kCircleRadius*kCircleRadius) < 0
        return isContain
    }
    
    
    //生成密码字符串
    private func generatePassword(array:NSArray)->String{
        let pwd:NSMutableString = NSMutableString()
        for (_,value) in array.enumerated(){
            let number = value as! NSNumber
            pwd.appendFormat("%d", number.intValue)
        }
        return pwd as String
    }
    
    
    
    ///初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setLayerFrames()
    }
    
    
    deinit {
        self.circleLayers.removeAllObjects()
        self.trackingIds.removeAllObjects()
        self.pathLayer = nil
    }
    
    
}
