//
//  ScanAnimateLayer.swift
//  SHKit
//
//  Created by hsh on 2019/12/31.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//动画效果
public enum AnimationStyle {
    case Move,Grid,Wave,None        //向下单线移动，向下网格,上下往返，无动画
}


//四个角与边框的位置关系
public enum AngleStyle {
    case Inner,Outer,On,None       //靠内,靠外,在上,没有边角
}



//做动画的视图
public class ScanAnimateLayer:UIView{
    public var animaStyle:AnimationStyle = .Grid                //默认网格样式
    public var angleStyle:AngleStyle = .Outer                   //默认四个角在外
    public var speed:CGFloat = 3                                //扫描动画速度
    
    public var size:CGSize = CGSize(width: 260, height: 260)    //扫描框大小
    public var boardWidth:CGFloat = 2                           //边框宽度
    public var gridW:CGFloat = 5                                //网格宽高
    public var animateWidth:CGFloat = 1                         //动画线宽度
    public var angleWidth:CGFloat = 7                           //边角宽度
    public var angleLength:CGFloat = 30                         //边角长度
    
    public var boardColor = UIColor.white                       //边框颜色
    public var angleColor = UIColor.colorHexValue("1AB1F4")     //边角颜色
    public var waveColor = UIColor.colorHexValue("3994FD")      //动画颜色
    public var maskColor = UIColor.colorHexValue("000000", alpha: 0.3)//遮罩颜色
    //Private
    private var animateV:AnimateWaveV!                          //动画线图层
    private var maskLayer:CAShapeLayer!                         //遮罩层
    

    
    //绘制动画类
    class AnimateWaveV: UIView,DisplayDelegate {
        //public
        public weak var superV:ScanAnimateLayer!                //父视图-用于获取对应属性
        //Private
        private var animateY:CGFloat = 0                        //动画的Y值
        
        
        //启动动画
        public func startAnimate(){
            HeatBeatTimer.shared.addDisplayTask(self);
        }
        
        //停止动画
        public func stopAnimate(){
            HeatBeatTimer.shared.cancelDisplayTask(self);
            //回归初始状态
            animateY = -superV.speed;
            self.setNeedsDisplay();
        }
        
        
        override func draw(_ rect: CGRect) {
            
            let ctx = UIGraphicsGetCurrentContext();
            ctx?.setStrokeColor(superV.waveColor.cgColor);
            ctx?.setFillColor(UIColor.clear.cgColor);
            ctx?.setLineWidth(superV.animateWidth);
            //根据样式
            if superV.animaStyle == .Move {
                let speed = superV.speed;
                animateY += speed;
                if animateY > self.height {
                    superV.speed = -speed;
                }else if animateY < 0{
                    superV.speed = -speed;
                }
                if animateY > 0 {
                    ctx?.move(to: CGPoint(x: 0, y: animateY));
                    ctx?.addLine(to: CGPoint(x: self.width, y: animateY));
                }
                ctx?.strokePath();
            }else if superV.animaStyle == .Wave{
                //从上往下循环运动
                animateY += superV.speed;
                if animateY >= self.height {
                    animateY = 0;
                }
                if animateY > 0 {
                    ctx?.move(to: CGPoint(x: 0, y: animateY));
                    ctx?.addLine(to: CGPoint(x: self.width, y: animateY));
                }
                ctx?.strokePath();
            }else if superV.animaStyle == .Grid{
                var stepSpeed = superV.speed;
                //绘制线
                var startY:CGFloat = 0;
                while (startY < animateY && animateY > 0) {
                    //颜色的比例
                    var rate:CGFloat = startY/self.height/2.0;
                    //先绘制竖线
                    var startX:CGFloat = 0;
                    while startX < self.width {
                        ctx?.move(to: CGPoint(x: startX, y: startY-superV.gridW));
                        ctx?.addLine(to: CGPoint(x: startX, y: startY));
                        startX += superV.gridW;
                    }
                    ctx?.strokePath();
                    //横线最后三行有变化
                    if startY >= animateY - superV.gridW * 3 {
                        if startY >= animateY - superV.gridW {
                            rate *= 2.2;
                        }else{
                            rate *= 1.5;
                        }
                        ctx?.setFillColor(superV.waveColor.withAlphaComponent(rate).cgColor);
                    }else{
                        ctx?.setFillColor(UIColor.clear.cgColor);
                    }
                    ctx?.fillPath();
                    //绘制横线
                    ctx?.setStrokeColor(superV.waveColor.withAlphaComponent(rate).cgColor)
                    ctx?.move(to: CGPoint(x: 0, y: startY));
                    ctx?.addLine(to: CGPoint(x: self.width, y: startY));
                    ctx?.strokePath();
                    
                    startY += superV.gridW;
                }
                //减速
                if animateY > self.height/3 {
                    let sub:CGFloat = self.height - animateY;
                    let rate:CGFloat = sub / self.height;
                    stepSpeed *= max(0.5,rate*2);
                }
                //自增
                animateY += stepSpeed;
                //重置
                if animateY > self.height + 10 {
                    animateY = -60;
                }
            }
            
        }
        
        
        //CADisplay调用
        func displayCalled() {
            self.setNeedsDisplay();
        }
        
        
    }

    
    //启动动画
    public func startAnimate(){
        if animaStyle != .None {
            if animateV == nil {
                animateV = AnimateWaveV()
                animateV.backgroundColor = .clear;
                animateV.superV = self;
                self.addSubview(animateV);
                animateV.mas_makeConstraints { (make) in
                    make?.center.mas_equalTo()(self);
                    make?.width.mas_equalTo()(size.width-boardWidth);
                    make?.height.mas_equalTo()(size.height-boardWidth);
                }
            }
            animateV.startAnimate();
        }
    }
    
    
    //停止动画
    public func stopAnimate(){
        animateV.stopAnimate();
    }
    
     
    //画边框
    public override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext();
        //画边框
        if angleStyle != .None {
            //中心点
            let center = self.center;
            //起点
            let start = CGPoint(x: center.x-size.width/2.0, y: center.y-size.height/2.0)
            //边框在起点沿两边变宽
            let halfBoard = boardWidth/2.0;
            //绘制遮罩
            if maskLayer == nil {
                maskLayer = CAShapeLayer()
                maskLayer.fillColor = maskColor.cgColor;
                maskLayer.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height);
                self.layer.addSublayer(maskLayer);
            }
            let path = CGMutablePath()
            //最外圈
            path.addRect(CGRect(x: 0, y: 0, width: self.width, height: self.height));
            //里圈
            if (angleStyle == .Inner || angleStyle == .On) {
                path.addRect(CGRect(x: start.x-halfBoard, y: start.y-halfBoard,
                                    width: size.width+boardWidth, height: size.height+boardWidth));
            }else if (angleStyle == .Outer){
                //能够全包围的最小内圈
                path.addRect(CGRect(x: start.x-angleWidth-halfBoard, y: start.y-angleWidth-halfBoard,
                                    width: size.width+angleWidth*2+boardWidth, height: size.height+angleWidth*2+boardWidth));
                //包不到的四个空隙
                path.addRect(CGRect(x: start.x+angleLength, y: start.y-angleWidth-halfBoard,
                                    width: size.width-angleLength*2, height: angleWidth));
                path.addRect(CGRect(x: start.x+size.width+halfBoard, y: start.y+angleLength,
                                    width: angleWidth, height: size.height-angleLength*2));
                path.addRect(CGRect(x: start.x+angleLength, y: start.y+size.height+halfBoard,
                                    width: size.width-angleLength*2, height: angleWidth));
                path.addRect(CGRect(x: start.x-angleWidth-halfBoard, y: start.y+angleLength,
                                    width: angleWidth, height: size.height-2*angleLength));
            }
            //填充规则
            maskLayer.fillRule = kCAFillRuleEvenOdd;
            maskLayer.path = path;
            
            //添加边框
            ctx?.setStrokeColor(boardColor.cgColor);
            ctx?.setLineWidth(boardWidth);
            ctx?.addRect(CGRect(x: start.x, y: start.y, width: size.width, height: size.height));
            ctx?.strokePath();
            
            //添加边角
            ctx?.setStrokeColor(angleColor.cgColor);
            ctx?.setLineWidth(angleWidth);
            if angleStyle == .Outer {
                //左上角
                let width = angleWidth/2.0+halfBoard;
                ctx?.move(to: CGPoint(x: start.x-width, y: start.y+angleLength));
                ctx?.addLine(to: CGPoint(x: start.x-width, y: start.y-width));
                ctx?.addLine(to: CGPoint(x: start.x+angleLength, y: start.y-width))
                //右上角
                ctx?.move(to: CGPoint(x: start.x+size.width-angleLength, y: start.y-width));
                ctx?.addLine(to: CGPoint(x: start.x+size.width+width, y: start.y-width));
                ctx?.addLine(to: CGPoint(x: start.x+size.width+width, y: start.y+angleLength));
                //右下角
                ctx?.move(to: CGPoint(x: start.x+size.width+width, y: start.y+size.height-angleLength));
                ctx?.addLine(to: CGPoint(x: start.x+size.width+width, y: start.y+size.height+width));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-angleLength, y: start.y+size.height+width))
                //左下角
                ctx?.move(to: CGPoint(x: start.x+angleLength, y: start.y+size.height+width));
                ctx?.addLine(to: CGPoint(x: start.x-width, y: start.y+size.height+width))
                ctx?.addLine(to: CGPoint(x: start.x-width, y: start.y+size.height-angleLength));
                ctx?.strokePath();
            }else if angleStyle == .On{
                //左上角
                let halfAngle = angleWidth/2.0-halfBoard;
                ctx?.move(to: CGPoint(x: start.x+halfAngle, y: start.y+angleLength+halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+halfAngle, y: start.y+halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+angleLength+halfAngle, y: start.y+halfAngle))
                //右上角
                ctx?.move(to: CGPoint(x: start.x+size.width-angleLength-halfAngle, y: start.y+halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-halfAngle, y: start.y+halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-halfAngle, y: start.y+angleLength+halfAngle));
                //右下角
                ctx?.move(to: CGPoint(x: start.x+size.width-halfAngle, y: start.y+size.height-angleLength-halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-halfAngle, y: start.y+size.height-halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-angleLength-halfAngle, y: start.y+size.height-halfAngle))
                //左下角
                ctx?.move(to: CGPoint(x: start.x+angleLength+halfAngle, y: start.y+size.height-halfAngle));
                ctx?.addLine(to: CGPoint(x: start.x+halfAngle, y: start.y+size.height-halfAngle))
                ctx?.addLine(to: CGPoint(x: start.x+halfAngle, y: start.y+size.height-angleLength-halfAngle));
                ctx?.strokePath();
            }else if angleStyle == .Inner{
                //左上角
                let width = angleWidth/2.0+halfBoard;
                ctx?.move(to: CGPoint(x: start.x+width,y: start.y+angleLength+width));
                ctx?.addLine(to: CGPoint(x: start.x+width,y: start.y+width));
                ctx?.addLine(to: CGPoint(x: start.x+angleLength+width, y: start.y+width))
                //右上角
                ctx?.move(to: CGPoint(x: start.x+size.width-angleLength-width, y: start.y+width));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-width, y: start.y+width));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-width,y: start.y+angleLength+width));
                //右下角
                ctx?.move(to: CGPoint(x: start.x+size.width-width,y: start.y+size.height-width-angleLength));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-width,y: start.y+size.height-width));
                ctx?.addLine(to: CGPoint(x: start.x+size.width-angleLength-width,y: start.y+size.height-width))
                //左下角
                ctx?.move(to: CGPoint(x: start.x+angleLength+width, y: start.y+size.height-width));
                ctx?.addLine(to: CGPoint(x: start.x+width, y: start.y+size.height-width))
                ctx?.addLine(to: CGPoint(x: start.x+width, y: start.y+size.height-width-angleLength));
                ctx?.strokePath();
            }
        }
    }
    
    
}



