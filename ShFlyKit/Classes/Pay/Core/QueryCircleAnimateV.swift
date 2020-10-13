//
//  QueryCircleAnimateV.swift
//  SHKit
//
//  Created by hsh on 2019/8/1.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit
import Masonry

///查询支付结果的转圈圈及结果动画--支付宝支付后的转圈圈效果
class QueryCircleAnimateV: UIView,CAAnimationDelegate,DisplayDelegate{
    //Variable
    public var lineColor:UIColor?               //线条颜色
    public var backColor:UIColor = UIColor.white//背景颜色
    public var centerImage:UIImage?             //转圈中间的图片
    
    public var lineWidth:CGFloat = 3            //线条宽度
    public var boundWidth:CGFloat = 60          //显示宽高-显示的区域是正方形
    
    public var circleDuration:CGFloat = 0.5     //转一圈的动画时间
    public var checkDuration:CGFloat = 0.3      //结果的动画时间
    
    //Private
    private var cirView:UIView?                 //显示图片的图层
    //动画
    private var animationLayer:CAShapeLayer!    //转圈的显示图层
    private var showLayer:CALayer?              //结果的显示图层
    
    private var startAngle:CGFloat = 0          //起始角度
    private var endAngle:CGFloat = 0            //结束调度
    private var progress:CGFloat = 0            //当前动画进度
    
    
    
    ///Interface
    //启动转圈动画
    public func startLoadingAnimate(){
        self.stopAnimate();
        self.loadAnimateBuild();
        HeatBeatTimer.shared.addDisplayTask(self);
    }
    
    
    //结束转圈动画
    public func stopLoadingAnimate(){
        HeatBeatTimer.shared.cancelDisplayTask(self);
        progress = 0;
        cirView?.isHidden = true;
        animationLayer?.isHidden = true;
        self.stopAnimate();
    }
    
    
    //移除动画图层
    public func stopAnimate(){
        animationLayer?.removeFromSuperlayer();
        showLayer?.removeFromSuperlayer();
    }
    
    
    //显示完成的动画
    public func showSuccessAnimate(){
        stopLoadingAnimate();
        //转一圈
        circleAnimation();
        //然后打钩动画
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.8 * Double(circleDuration))) { [unowned self]  in
            self.checkAnimation();
        };
    }
    
    
    //显示失败的动画
    public func showFailAnimate(){
        stopLoadingAnimate();
        //转一圈
        circleAnimation();
        //然后失败动画
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.8 * Double(circleDuration))) { [unowned self]  in
            self.failAnimation();
        };
    }
    
    
    ///DisplayDelegate
    //更新进度--定时器调用
    func displayCalled() {
        var step:CGFloat = 2/60.0;
        if endAngle > CGFloat(Double.pi) {
            step = 0.3/60.0;
        }
        progress += step;
        if progress >= 1 {
            progress = 0;
        }
        self.updateAnimationLayer();
    }
    
    
    
    ///Private
    //更新转圈进度
    private func updateAnimationLayer(){
        startAngle = -CGFloat(Double.pi/2);
        endAngle = -CGFloat(Double.pi/2) + progress * CGFloat(Double.pi) * 2;
        if endAngle > CGFloat(Double.pi){
            let tmp:CGFloat = 1 - (1 - progress) / 0.25;
            startAngle = -CGFloat(Double.pi/2) + tmp * CGFloat(Double.pi) * 2;
        }
        let radius:CGFloat = animationLayer.bounds.size.width/2.0 - lineWidth / 2.0;
        let centerX = animationLayer.bounds.size.width/2.0;
        let centerY = animationLayer.bounds.size.height/2.0;
        let path:UIBezierPath = UIBezierPath.init(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true);
        animationLayer.path = path.cgPath;
    }
    
    
    //转一个圈
    private func circleAnimation(){
        showLayer = CALayer()
        showLayer?.bounds = CGRect(x: 0, y: 0, width: boundWidth, height: boundWidth);
        showLayer?.position = CGPoint(x: boundWidth/2, y: boundWidth/2);
        self.layer.addSublayer(showLayer!);
        
        let circleLayer = CAShapeLayer()
        circleLayer.frame = showLayer!.bounds;
        showLayer!.addSublayer(circleLayer);
        circleLayer.fillColor = UIColor.clear.cgColor;
        circleLayer.strokeColor = lineColor != nil ? lineColor?.cgColor : UIColor.colorHexValue("424456").cgColor;
        circleLayer.lineWidth = lineWidth;
        circleLayer.lineCap = kCALineCapRound;
        
        let radius:CGFloat = showLayer!.bounds.size.width/2.0 - lineWidth/2.0;
        let path = UIBezierPath.init(arcCenter: circleLayer.position, radius: radius, startAngle: CGFloat(-Double.pi/2.0), endAngle: CGFloat(Double.pi*3/2.0), clockwise: true);
        circleLayer.path = path.cgPath;
        
        let anim = CABasicAnimation.init(keyPath: "strokeEnd");
        anim.duration = CFTimeInterval(circleDuration);
        anim.fromValue = 0;
        anim.toValue = 1.0;
        anim.delegate = self;
        anim.setValue("circleAnimation", forKey: "animationName");
        circleLayer.add(anim, forKey: nil);
    }
    
    
    //成功动画
    private func checkAnimation(){
        let a = showLayer!.bounds.size.width;
        let path = UIBezierPath()
        path.move(to: CGPoint(x: a*2.7/10, y: a*5.4/10));
        path.addLine(to: CGPoint(x: a*4.5/10, y: a*7/10));
        path.addLine(to: CGPoint(x: a*7.8/10, y: a*3.8/10));
        
        let aniLayer = CAShapeLayer()
        aniLayer.path = path.cgPath;
        aniLayer.fillColor = UIColor.clear.cgColor;
        aniLayer.strokeColor = lineColor != nil ? lineColor?.cgColor : UIColor.colorHexValue("424456").cgColor;
        aniLayer.lineWidth = lineWidth;
        aniLayer.lineCap = kCALineCapRound;
        aniLayer.lineJoin = kCALineJoinRound;
        showLayer!.addSublayer(aniLayer);
        
        let anima = CABasicAnimation.init(keyPath: "strokeEnd");
        anima.duration = CFTimeInterval(checkDuration);
        anima.fromValue = 0;
        anima.toValue = 1.0;
        anima.delegate = self;
        anima.setValue("checkAnimation", forKey: "animationName");
        aniLayer.add(anima, forKey: nil);
    }
    
    
    
    //失败动画
    private func failAnimation(){
        let a = showLayer!.bounds.size.width;
        let path = UIBezierPath()
        path.move(to: CGPoint(x: a*2.7/10, y: a*2.7/10));
        path.addLine(to: CGPoint(x: a*7.3/10, y: a*7.3/10));
        path.move(to: CGPoint(x: a*7.3/10, y: a*2.7/10));
        path.addLine(to: CGPoint(x: a*2.7/10, y:a*7.3/10));
        
        let aniLayer = CAShapeLayer()
        aniLayer.path = path.cgPath;
        aniLayer.fillColor = UIColor.clear.cgColor;
        aniLayer.strokeColor = lineColor != nil ? lineColor?.cgColor : UIColor.colorHexValue("424456").cgColor;
        aniLayer.lineWidth = lineWidth;
        aniLayer.lineCap = kCALineCapRound;
        aniLayer.lineJoin = kCALineJoinRound;
        showLayer!.addSublayer(aniLayer);
        
        let anima = CABasicAnimation.init(keyPath: "strokeEnd");
        anima.duration = CFTimeInterval(checkDuration);
        anima.fromValue = 0;
        anima.toValue = 1.0;
        anima.delegate = self;
        anima.setValue("checkAnimation", forKey: "animationName");
        aniLayer.add(anima, forKey: nil);
    }


    
    //构建转圈动画图层
    private func loadAnimateBuild(){
        self.backgroundColor = backColor;
        let bounds = CGRect(x: 0, y: 0, width: boundWidth, height: boundWidth);
        let radius = boundWidth / 2.0;
        let position = CGPoint(x: boundWidth/2.0, y: boundWidth/2.0);
        //绘制中间图片
        if (centerImage != nil && cirView == nil) {
            cirView = UIView();
            cirView?.backgroundColor = backColor;
            cirView?.frame = CGRect(x: 0, y: 0, width: boundWidth - lineWidth, height: boundWidth - lineWidth);
            cirView?.layer.cornerRadius = (radius - lineWidth);
            cirView?.layer.masksToBounds = true;
            cirView?.center = position;
            self.addSubview(cirView!);
            
            let imageV = UIImageView()
            imageV.image = centerImage;
            cirView?.addSubview(imageV);
            imageV .mas_makeConstraints { (maker) in
                maker?.center.mas_equalTo()(cirView);
            }
        }
        animationLayer = CAShapeLayer()
        animationLayer.bounds = bounds;
        animationLayer.position = position;
        animationLayer.fillColor = UIColor.clear.cgColor;
        animationLayer.strokeColor = lineColor != nil ? lineColor?.cgColor : UIColor.colorHexValue("424456").cgColor;
        animationLayer.lineWidth = lineWidth;
        animationLayer.lineCap = kCALineCapRound;
        self.layer.addSublayer(animationLayer);
    }
    
    
    
}
