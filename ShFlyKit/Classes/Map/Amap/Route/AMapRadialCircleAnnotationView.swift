//
//  RadialCircleAnnotationView.swift
//  SHKit
//
//  Created by hsh on 2019/1/2.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit

///脉冲动画渐变图层，水波扩散

public class AMapRadialCircleAnnotationView: MAAnnotationView {
    //MARK-Varibale
    public var pulseCount = 4                //脉冲圈个数
    public var animationDuration = 8.0       //单个脉冲圈动画时长
    public var baseDiameter = 8.0            //单个脉冲圈起始直径
    public var scale = 30.0                  //单个脉冲圈缩放比例
    public var fillColor = UIColor.colorRGB(red: 97, green: 171, blue: 248)
    public var strokeColor = UIColor.colorRGB(red: 97, green: 171, blue: 248,alpha: 0.5)
    
    
    //MARK-
    private var fixedLayer = CALayer()
    private var pulseLayers = Array<CALayer>()
    
    
    //MARK-Load
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        buildRadialCircle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    ///MARK-Interface
    ///结束脉冲
    public func stopPulseAnimation() {
        for aLayer in pulseLayers {
            aLayer.removeAllAnimations()
            aLayer.removeFromSuperlayer()
        }
        pulseLayers.removeAll()
    }
    
    
    
    ///开始脉冲
    func startPulseAnimation() {
        if pulseLayers.count > 0 {
            stopPulseAnimation()
        }
        let currentMediaTime = CACurrentMediaTime()
        let timeInterval = Double(animationDuration / Double(pulseCount))
        for i in 0...pulseCount {
            let aLayer = buildPulseLayer(beginTime: currentMediaTime + timeInterval * Double(i))
            pulseLayers.append(aLayer)
            layer.addSublayer(aLayer)
        }
    }
    
    
    
    
    //MARK-Private
    //设置半径圆
    private func buildRadialCircle() {
        let fixedLayerDiameter = 20.0
        layer.bounds = CGRect(x: 0, y: 0, width: fixedLayerDiameter, height: fixedLayerDiameter)
        fixedLayer.bounds = layer.bounds
        fixedLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        fixedLayer.cornerRadius = CGFloat(fixedLayerDiameter / 2.0)
        fixedLayer.backgroundColor = UIColor.blue.cgColor
        fixedLayer.borderColor = UIColor.white.cgColor
        fixedLayer.borderWidth = 4.0
        layer.addSublayer(fixedLayer)
        
        startPulseAnimation()
    }
    
    
    //构建脉冲图层,开启动画
    private func buildPulseLayer(beginTime: CFTimeInterval) -> CALayer {
        let aLayer = CALayer()
        aLayer.bounds = CGRect(x: 0, y: 0, width: baseDiameter, height: baseDiameter)
        aLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        aLayer.cornerRadius = CGFloat(baseDiameter / 2.0)
        aLayer.backgroundColor = fillColor.cgColor
        aLayer.borderColor = strokeColor.cgColor
        aLayer.borderWidth = 2
        aLayer.opacity = 0
        aLayer.zPosition = -100
        
        let pulseAnimation = buildPulseAnimation(diameter: baseDiameter, scale: scale, duration: animationDuration, beginTime: beginTime)
        aLayer.add(pulseAnimation, forKey: "pulseAnimation")
        return aLayer
    }
    
    
    
    //开始脉冲动画
    func buildPulseAnimation(diameter: Double, scale: Double, duration: TimeInterval, beginTime: CFTimeInterval) -> CAAnimation {
        //渐隐动画
        let aniFade = CABasicAnimation(keyPath: "opacity")
        aniFade.fromValue = (0.65)
        aniFade.toValue = (0.0)
        //渐大动画
        let aniScale = CABasicAnimation(keyPath: "bounds")
        aniScale.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        aniScale.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: diameter*scale, height: diameter*scale))
        //圆角动画
        let aniCorner = CABasicAnimation(keyPath: "cornerRadius")
        aniCorner.fromValue = (diameter / 2.0)
        aniCorner.toValue = (diameter * scale / 2.0)
        //创建动画组
        let aniGroup = CAAnimationGroup()
        aniGroup.animations = [aniFade, aniScale, aniCorner]
        aniGroup.isRemovedOnCompletion = false
        aniGroup.duration = duration
        aniGroup.repeatCount = Float.infinity
        aniGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        aniGroup.beginTime = beginTime
        return aniGroup;
    }
    

}
