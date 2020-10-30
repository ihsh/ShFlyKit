//
//  WeatherThunder.swift
//  SHKit
//
//  Created by hsh on 2020/1/7.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//闪电图层
public class WeatherThunder: IgnoreTouchView {
    //Variable
    public var config:WeatherConfig.Thunder!            //配置
    private var pointArr:[CGPoint] = []                 //主干路径点
    private var branchStartPoints:[CGPoint] = []        //分支起点
    private var bezierPathArr:[UIBezierPath] = []       //分支路径
    private var stopLighting:Bool = false               //是否停止
    
    
    
    //Interface
    //开始启动动画
    public func startAnimation(){
        stopLighting = false;
        self.flashRandomTimes();
    }
    
    
    //结束动画
    public func stopAnimation(){
        stopLighting = true;
    }
    
    
    ///Private
    private func flashRandomTimes(){
        //删除现有图层
        func deleteLayers(){
            if self.layer.sublayers?.count ?? 0 > 0 {
                for layer in self.layer.sublayers! {
                    if layer.isKind(of: CAShapeLayer.self) {
                        layer.removeFromSuperlayer();
                    }
                }
            }
            bezierPathArr.removeAll();
            branchStartPoints.removeAll();
        }
        //画闪电
        func drawLighting(){
            setUpLightPointArr(start: CGPoint(x: CGFloat(arc4random()%UInt32(ScreenSize().width)),
                                              y: self.config.startY+CGFloat(arc4random()%config.startRange)),
                               end: CGPoint(x: CGFloat(arc4random()%UInt32(ScreenSize().width)),
                                            y: CGFloat(arc4random()%config.endRange)+config.endY), displace: 3);
            setupBranchLightningPoint();
            setupLightningPath();
            setupLightningAnimation();
        }
        //开始闪电
        func startFlash(){
            for _ in 0...arc4random()%config.flashRange {
                drawLighting();
            }
        }
        //============执行==========
        //停止闪电
        if stopLighting == true || config == nil || self.superview == nil {
            return;
        }
        deleteLayers();
        //开始
        startFlash();
        //延后再执行
        let after = arc4random() % config.delayRange;
        DispatchQueue.main.asyncAfter(deadline: .now()+Double(after)) {
            self.flashRandomTimes();
        }
    }
    
    
    //主要路径的点
    private func setUpLightPointArr(start:CGPoint,end:CGPoint,displace:CGFloat){
        var midX = start.x;
        var midY = start.y;
        pointArr.removeAll();
        pointArr.append(start);
        
        while (midY < end.y) {
            if start.x < ScreenSize().width/2.0 {
                midX += (CGFloat(arc4random()%config.xRandomRange)-0.5) * displace;
                midY += (CGFloat(arc4random()%config.YRandomRange)-0.5) * displace;
            }else{
                midX -= (CGFloat(arc4random()%config.xRandomRange)-0.5) * displace;
                midY += (CGFloat(arc4random()%config.YRandomRange)-0.5) * displace;
            }
            pointArr.append(CGPoint(x: midX, y: midY));
        }
    }
    
    
    //分支的起点
    private func setupBranchLightningPoint(){
        let lightNum:Int = Int(arc4random() % config.lightRange) + config.lightBase;
        repeat{
            let tempPoint = pointArr[Int(arc4random())%pointArr.count];
            if branchStartPoints.contains(tempPoint) {
                continue;
            }else{
                branchStartPoints.append(tempPoint);
            }
        }while(branchStartPoints.count < lightNum);
    }
    
    
    //设置路径的点
    private func setupBranchLightningPathPoint(start:CGPoint,end:CGPoint,displace:CGFloat)->[CGPoint]{
        var midX = start.x;
        var midY = start.y;

        var pathPoints:[CGPoint] = [];
        pathPoints.append(start);
        
        let numPathPoint = Int(arc4random()%20) + 50;
        for _ in 0...numPathPoint-1 {
            if (start.x < ScreenSize().width/2.0) {
                midX += (CGFloat(arc4random()%config.xRandomRange)-0.5) * displace;
                midY += (CGFloat(arc4random()%config.YRandomRange)-0.5) * displace;
            }else{
                midX -= (CGFloat(arc4random()%config.xRandomRange)-0.5) * displace;
                midY += (CGFloat(arc4random()%config.YRandomRange)-0.5) * displace;
            }
            pointArr.append(CGPoint(x: midX, y: midY));
        }
        return pathPoints;
    }
    
    
    //设置闪电路径
    private func setupLightningPath(){
        let path = UIBezierPath();
        bezierPathArr.append(path);
        
        var point:CGPoint!
        for i in 0...pointArr.count-1 {
            point = pointArr[i];
            if i == 0 {
                path.move(to: point);
            }else{
                path.addLine(to: point);
            }
            //分支路径
            if (branchStartPoints.contains(point)) {
                let branchPointArr = setupBranchLightningPathPoint(start: point, end: CGPoint(x: point.x + 100, y: point.y + 100), displace: 1);
                let branchPath = UIBezierPath()
                var branchPoint:CGPoint!
                for j in 0...branchPointArr.count-1 {
                    branchPoint = branchPointArr[j];
                    if j == 0 {
                        branchPath.move(to: branchPoint);
                    }else{
                        branchPath.addLine(to: branchPoint);
                    }
                }
                bezierPathArr.append(branchPath);
            }
        }
    }
    
    
    //闪电动画
    private func setupLightningAnimation(){
        //路径变化
        let pathAnim = CABasicAnimation.init(keyPath: "strokeEnd");
        pathAnim.duration = 0.2;
        pathAnim.fromValue = NSNumber.init(value: 0);
        pathAnim.toValue = NSNumber.init(value: 1);
        pathAnim.repeatCount = 1;
        //不透明度变化
        let opacityAnim = CABasicAnimation.init(keyPath: "opacity");
        opacityAnim.fromValue = NSNumber.init(value: 1);
        opacityAnim.toValue = NSNumber.init(value: 0);
        //动画组
        let group = CAAnimationGroup()
        group.duration = 1;
        group.animations = [opacityForeverAnimation(duration: 0.1),pathAnim,opacityAnim];
        group.autoreverses = false;
        group.repeatCount = 1;
        for i in 0...bezierPathArr.count-1 {
            let path = bezierPathArr[i];
            let pathLayer = CAShapeLayer()
            pathLayer.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height);
            pathLayer.path = path.cgPath;
            pathLayer.strokeColor = config.color.cgColor;
            pathLayer.fillColor = nil;
            pathLayer.lineWidth = CGFloat(Double(arc4random()%config.lineRangeW)/10.0)+config.lineBaseW;
            pathLayer.lineJoin = kCALineJoinMiter;
            self.layer.addSublayer(pathLayer);
            pathLayer.add(group, forKey: "FlashAnimation");
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                pathLayer.opacity = 0;
            }, completion: nil);
        }
        
    }
    
    
    //不透明度变化
    private func opacityForeverAnimation(duration:CGFloat)->CABasicAnimation{
        let base = CABasicAnimation.init(keyPath: "opacity");
        base.fromValue = NSNumber.init(value: 1);
        base.toValue = NSNumber.init(value: 0);
        base.autoreverses = true;
        base.duration = CFTimeInterval(duration);
        base.repeatCount = MAXFLOAT;
        base.isRemovedOnCompletion = false;
        base.fillMode = kCAFillModeForwards;
        base.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn);
        return base;
    }
    
    
}
