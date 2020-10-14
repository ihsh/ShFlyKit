//
//  LockPathLayer.swift
//  SHKit
//
//  Created by hsh on 2018/10/24.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


//画路径类
class LockPathLayer: CALayer {
    //Variable
    public var passwordView:LockPasswordView!       //密码视图
    public var showPath:Bool = true                 //是否显示路径
    public var isError:Bool = false
    
    //绘制
    override func draw(in ctx: CGContext) {
        //当前没有在跟踪就不执行
        if (self.passwordView.isTracking == false || showPath == false) {
            return
        }
        let rectPath = UIBezierPath(rect: self.bounds)
        ctx.addPath(rectPath.cgPath)
        //画圆圈
        let circleIds = self.passwordView.trackingIds;
        for (_,value) in circleIds.enumerated() {
            let circleId:NSInteger = value as! NSInteger
            let point:CGPoint = self.getPointWithId(circleId: circleId)
            let radius = self.passwordView.kCircleRadius - 1.0;
            let circleFrame = CGRect(x: point.x-radius, y: point.y-radius, width: radius*2, height: radius*2)
            ctx.addEllipse(in: circleFrame)
        }
        ctx.clip()
        //准备画线
        ctx.setLineWidth(self.passwordView.kPathWidth/UIScreen.main.scale)
        ctx.setLineJoin(CGLineJoin.round)
        ctx.setStrokeColor(isError ? self.passwordView.errorColor?.cgColor ?? UIColor.red.cgColor : self.passwordView.highlightedColor.cgColor);
        
        ctx.beginPath()
        for (index,value) in circleIds.enumerated() {
            let circleId:NSInteger = value as! NSInteger
            let point = self.getPointWithId(circleId: circleId)
            if index == 0{
                ctx.move(to: point);
            }else{
                ctx.addLine(to: point)
            }
        }
        if self.passwordView.previousTouchPoint != nil{
            let prePonit:CGPoint = self.passwordView.previousTouchPoint
            ctx.addLine(to: prePonit)
        }
        ctx.drawPath(using: CGPathDrawingMode.stroke)
    }
    
    
    ///获取对应ID所在的点
    private func getPointWithId(circleId:NSInteger)->CGPoint{
        let radius = passwordView.kCircleRadius
        let margin = passwordView.kCircleBetweenMargin
        let leftMargin = (self.bounds.size.width - (6*radius + 2*margin))/2
        let x = leftMargin + radius + (CGFloat(circleId % 3) * (radius*2 + margin))
        let y = 10 + radius + (CGFloat(circleId / 3) * (radius*2 + margin))
        let point = CGPoint(x: x, y: y)
        return point
    }
    
    

}
