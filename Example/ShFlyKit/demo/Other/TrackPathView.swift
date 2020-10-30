//
//  TrackPathView.swift
//  SHKit
//
//  Created by 黄少辉 on 2020/5/28.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//路径动画
class TrackPathView: UIView , DisplayDelegate ,CAAnimationDelegate {
    //Variable
    public var patternLayer1:CAShapeLayer!  //灰色底部线
    public var patternLayer2:CAShapeLayer!  //灰色M
    public var trackLayer1:CAShapeLayer!    //黑色轨迹
    public var trackLayer2:CAShapeLayer!    //黄色轨迹
    
    public var anchorX:CGFloat = 70         //锚点X
    public var anchorY:CGFloat = 100        //锚点Y
    
    
    //绘制路径图案
    public func drawPattern(){
        //绘制M的图案-底部一痕
        let path1 = CGMutablePath();
        path1.move(to: CGPoint(x: anchorX, y: anchorY));
        path1.addQuadCurve(to: CGPoint(x: anchorX + 60, y: anchorY), control: CGPoint(x: anchorX + 30, y: anchorY+10));
        
        patternLayer1 = CAShapeLayer()
        patternLayer1.strokeColor = UIColor.lightGray.cgColor;
        patternLayer1.fillColor = UIColor.clear.cgColor;
        patternLayer1.lineWidth = 3;
        patternLayer1.lineCap = kCALineCapRound;
        patternLayer1.lineJoin = kCALineJoinRound;
        self.layer.addSublayer(patternLayer1);
        patternLayer1.path = path1;
        
        //M的上边路径
        let path2 = CGMutablePath();
        path2.move(to: CGPoint(x: anchorX-2, y: anchorY-10));
        path2.addLine(to: CGPoint(x: anchorX-2, y: anchorY-50));
        path2.addQuadCurve(to: CGPoint(x: anchorX+5, y: anchorY-50), control: CGPoint(x: anchorX, y: anchorY-55));
        path2.addLine(to: CGPoint(x: anchorX+25, y: anchorY-35));
        path2.addQuadCurve(to: CGPoint(x: anchorX+35, y: anchorY-35), control: CGPoint(x: anchorX+30, y: anchorY-30));
        path2.addLine(to: CGPoint(x: anchorX+55, y: anchorY-50));
        path2.addQuadCurve(to: CGPoint(x: anchorX+62, y: anchorY-50), control: CGPoint(x: anchorX+62, y: anchorY-55));
        path2.addLine(to: CGPoint(x: anchorX+62, y: anchorY-10));
        
        patternLayer2 = CAShapeLayer()
        patternLayer2.strokeColor = UIColor.lightGray.cgColor;
        patternLayer2.fillColor = UIColor.clear.cgColor;
        patternLayer2.lineWidth = 3;
        patternLayer2.lineCap = kCALineCapRound;
        patternLayer2.lineJoin = kCALineJoinRound;
        self.layer.addSublayer(patternLayer2);
        patternLayer2.path = path2;
        
        //黑色线
        trackLayer1 = CAShapeLayer()
        trackLayer1.strokeColor = UIColor.black.cgColor;
        trackLayer1.fillColor = UIColor.clear.cgColor;
        trackLayer1.lineWidth = 3;
        trackLayer1.lineCap = kCALineCapRound;
        trackLayer1.lineJoin = kCALineJoinRound;
        self.layer.addSublayer(trackLayer1);
        //黄色线
        trackLayer2 = CAShapeLayer()
        trackLayer2.strokeColor = UIColor.colorRGB(red: 255, green: 199, blue: 75).cgColor;
        trackLayer2.fillColor = UIColor.clear.cgColor;
        trackLayer2.lineWidth = 3;
        trackLayer2.lineCap = kCALineCapRound;
        trackLayer2.lineJoin = kCALineJoinRound;
        self.layer.addSublayer(trackLayer2);

        //添加路径动画
        self.displayCalled();
    }
    
    
    //路径动画展示
    func displayCalled() {
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: anchorX + 60, y: anchorY));
        path.addQuadCurve(to: CGPoint(x: anchorX, y: anchorY), control: CGPoint(x: anchorX+30, y: anchorY+10));
        path.addQuadCurve(to: CGPoint(x: anchorX-20, y: anchorY-25), control: CGPoint(x: anchorX-20, y: anchorY-15));
        path.addArc(center: CGPoint(x: anchorX+30, y: anchorY-25), radius: 50, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi*5-1.8), clockwise: false);
        path.addQuadCurve(to: CGPoint(x: anchorX-2, y: anchorY), control: CGPoint(x: anchorX+5, y: anchorY+20));
        path.addLine(to: CGPoint(x: anchorX-2, y: anchorY-50));
        path.addQuadCurve(to: CGPoint(x: anchorX+5, y: anchorY-50), control: CGPoint(x: anchorX, y: anchorY-55));
        path.addLine(to: CGPoint(x: anchorX+25, y: anchorY-35));
        path.addQuadCurve(to: CGPoint(x: anchorX+35, y: anchorY-35), control: CGPoint(x: anchorX+30, y: anchorY-30));
        path.addLine(to: CGPoint(x: anchorX+55, y: anchorY-50));
        path.addQuadCurve(to: CGPoint(x: anchorX+62, y: anchorY-50), control: CGPoint(x: anchorX+62, y: anchorY-55));
        path.addLine(to: CGPoint(x: anchorX+62, y: anchorY-10));
        path.addQuadCurve(to: CGPoint(x: anchorX+60, y: anchorY), control: CGPoint(x: anchorX+62, y: anchorY));
        path.addQuadCurve(to: CGPoint(x: anchorX, y: anchorY), control: CGPoint(x: anchorX+30, y: anchorY+10));
        
        trackLayer1.path = path;
        trackLayer2.path = path;
        
        //添加动画
        addAnimations();
    }
    
    
    //添加动画
    func addAnimations(){
        
        patternLayer1.strokeColor = UIColor.lightGray.cgColor;
        patternLayer2.strokeColor = UIColor.lightGray.cgColor;
        trackLayer1.strokeColor = UIColor.black.cgColor;
        trackLayer2.strokeColor = UIColor.colorRGB(red: 255, green: 199, blue: 75).cgColor;
        
        let anima = CABasicAnimation.init(keyPath: "strokeEnd");
        anima.duration = CFTimeInterval(3);
        anima.fromValue = 0;
        anima.toValue = 1.0;
        anima.setValue("blackEnd", forKey: "keypath");
        anima.repeatCount = 1;

        let anima2 = CABasicAnimation.init(keyPath: "strokeStart");
        anima2.duration = CFTimeInterval(3);
        anima2.fromValue = -0.1;
        anima2.toValue = 0.9;
        anima2.delegate = self;
        anima2.repeatCount = 1;
        anima2.setValue("blackStart", forKey: "keypath");

        trackLayer1.add(anima, forKey: nil);
        trackLayer1.add(anima2, forKey: nil);
        
        let anima3 = CABasicAnimation.init(keyPath: "strokeEnd");
        anima3.duration = CFTimeInterval(3);
        anima3.fromValue = 0.05;
        anima3.toValue = 1.05;
        anima3.setValue("yellowEnd", forKey: "keypath");
        anima3.repeatCount = 1;
        anima3.delegate = self;

        let anima4 = CABasicAnimation.init(keyPath: "strokeStart");
        anima4.duration = CFTimeInterval(3);
        anima4.fromValue = 0;
        anima4.toValue = 1.0;
        anima4.setValue("yellowStart", forKey: "keypath");
        anima4.delegate = self;
        anima4.repeatCount = 1;

        trackLayer2.add(anima3, forKey: nil);
        trackLayer2.add(anima4, forKey: nil);
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
            self.trackLayer1.strokeColor = UIColor.clear.cgColor;
            self.trackLayer2.strokeColor = UIColor.clear.cgColor;
            self.patternLayer1.strokeColor = UIColor.colorRGB(red: 255, green: 199, blue: 75).cgColor;
            self.patternLayer2.strokeColor = UIColor.black.cgColor;
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.addAnimations();
            }
        };
        
    }
    
    
}






