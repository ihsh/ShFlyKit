//
//  StarView.swift
//  ShFlyKit
//
//  Created by mac on 2021/1/13.
//

import UIKit


///普通的星级图
public class StarView: UIView {
    //Private
    private var strokeLayer:CAShapeLayer!   //空壳层
    private var fillLayer:CAShapeLayer!     //填充层
    
    
    ///绘制星
    public func showStars(_ points:[CGPoint],color:UIColor,total:Double,current:Double,radius:CGFloat,innerRadius:CGFloat){
        //初始化
        if strokeLayer == nil {
            strokeLayer = CAShapeLayer();
            strokeLayer.fillColor = UIColor.clear.cgColor;
            self.layer.addSublayer(strokeLayer);
            
            fillLayer = CAShapeLayer();
            self.layer.addSublayer(fillLayer);
        }
        //绘制空壳
        strokeLayer.strokeColor = color.cgColor;
        let strokepath = CGMutablePath();
        for pos in points {
            StarPath.drawStarPath(strokepath, center: pos, bigRadius: radius, smallRadius: innerRadius);
        }
        strokeLayer.path = strokepath;
        //绘制填充色
        fillLayer.fillColor = color.cgColor;
        let fillPath = CGMutablePath();
        //校验
        if (points.count == 0 || total < 0 || current < 0 || radius <= 0 || innerRadius <= 0) {return}
        let cur = min(current, total);
        //计算比例
        let segment:Double = total/Double(points.count);
        let integer:Int = Int(floor(cur/segment));
        let left:Double = cur - Double(integer) * segment;
        //计算最后一个展示方式
        var lastType:Int = 0  //0不绘制 1绘制一半 2全部绘制
        if left < segment/4.0 {
            lastType = 0;
        }else if (left < segment - segment/10.0){
            lastType = 1;
        }else{
            lastType = 2;
        }
        //绘制
        for (i,pos) in points.enumerated() {
            if i < integer {
                StarPath.drawStarPath(fillPath, center: pos, bigRadius: radius, smallRadius: innerRadius);
            }else{
                if lastType == 1 {
                    StarPath.drawHalfStarPath(fillPath, center: pos, bigRadius: radius, smallRadius: innerRadius);
                }else if (lastType == 2){
                    StarPath.drawStarPath(fillPath, center: pos, bigRadius: radius, smallRadius: innerRadius);
                }
            }
        }
        fillLayer.path = fillPath
    }

}



///星级分布
public class StarDistributionV:UIView{
    //public
    public var yMargin:CGFloat = 15         //垂直方向上星和线的间距
    public var xMargin:CGFloat = 10         //水平方向上星的间距
    public var starRadius:CGFloat = 4       //外半径
    public var starInnerRadius:CGFloat = 2  //内半径
    
    public var lineLength:CGFloat = 80      //线的长度
    public var lineHeight:CGFloat = 3       //线的高度
    public var lineLeftMargin:CGFloat = 15  //线距左星星的间距
    
    public var fillColor:UIColor = .black   //填充色
    public var strokeColor:UIColor = .colorHexValue("F0F0F0")//
    public var startPos:CGPoint = CGPoint(x: 16, y: 16) //绘制起点,左上角第一个星星
    //private
    private var strokeLayer:CAShapeLayer!
    private var fillLayer:CAShapeLayer!
    
    
    ///绘制分布图
    public func drawDistribution(rates:[Double]){
        if strokeLayer == nil {
            strokeLayer = CAShapeLayer();
            strokeLayer.fillColor = strokeColor.cgColor;
            self.layer.addSublayer(strokeLayer);
            fillLayer = CAShapeLayer();
            fillLayer.fillColor = fillColor.cgColor;
            self.layer.addSublayer(fillLayer);
        }
        //根据rate的数量绘制
        if rates.count > 2 {
            let strokePath = CGMutablePath();
            let fillPath = CGMutablePath();
            //计算最大值
            var maxValue:Double = 0;
            for value in rates {
                maxValue = max(maxValue, value);
            }
            //设置起点
            var startX:CGFloat = startPos.x;
            var startY:CGFloat = startPos.y;
            let count:Int = rates.count - 1;
            //绘制星星
            for i in 0...count {
                let fillStep:Int = count - i;
                for j in 0...count {
                    //星星的center位置
                    let pos = CGPoint(x: startX + xMargin * CGFloat(j),y: startY + yMargin * CGFloat(i));
                    //空星星路径
                    StarPath.drawStarPath(strokePath, center: pos, bigRadius: starRadius, smallRadius: starInnerRadius);
                    //计算填充星星路径
                    if fillStep >= j {
                        StarPath.drawStarPath(fillPath, center: pos, bigRadius: starRadius, smallRadius: starInnerRadius);
                    }
                }
            }
            //绘制条形
            let lineX:CGFloat = startX + xMargin * CGFloat(count) + lineLeftMargin;
            
            for i in 0...count {
                let y:CGFloat = startY + yMargin * CGFloat(i) - lineHeight/2.0;
                let rate:CGFloat = CGFloat(rates[i] / maxValue);
                //空的路径
                strokePath.move(to: CGPoint(x: lineX, y: y));
                strokePath.addLine(to: CGPoint(x: lineX + lineLength, y: y));
                strokePath.addLine(to: CGPoint(x: lineX + lineLength, y: y + lineHeight));
                strokePath.addLine(to: CGPoint(x: lineX, y: y + lineHeight));
                strokePath.addLine(to: CGPoint(x: lineX, y: y));
                //填充的路径
                fillPath.move(to: CGPoint(x: lineX, y: y));
                fillPath.addLine(to: CGPoint(x: lineX + lineLength * rate, y: y));
                fillPath.addLine(to: CGPoint(x: lineX + lineLength * rate, y: y + lineHeight));
                fillPath.addLine(to: CGPoint(x: lineX, y: y + lineHeight));
                fillPath.addLine(to: CGPoint(x: lineX, y: y));
            }
            strokeLayer.path = strokePath;
            fillLayer.path = fillPath;
        }
        
    }
    
    
}



///生成星星的路径
public class StarPath:NSObject{
    static let divide:CGFloat = (2*CGFloat(M_PI))/10.0
    
    ///绘制一个星星的路径
    class public func drawStarPath(_ path:CGMutablePath, center:CGPoint,bigRadius:CGFloat,smallRadius:CGFloat){
        for i in 0...10 {
            let endAngle:CGFloat = divide * CGFloat(i) - divide/2.0;
            let radius:CGFloat = (i % 2 == 0) ? bigRadius : smallRadius;
            let x:CGFloat = radius * cos(endAngle);
            let y:CGFloat = radius * sin(endAngle);
            let newPos:CGPoint = CGPoint(x: center.x + x, y: center.y + y);
            if i == 0 {
                path.move(to: newPos);
            }else{
                path.addLine(to: newPos);
            }
        }
    }
    
    
    ///绘制左半边
    class public func drawHalfStarPath(_ path:CGMutablePath, center:CGPoint,bigRadius:CGFloat,smallRadius:CGFloat){
        for i in 0...10 {
            let endAngle:CGFloat = divide * CGFloat(i) - divide/2.0;
            let radius:CGFloat = (i % 2 == 0) ? bigRadius : smallRadius;
            let x:CGFloat = radius * cos(endAngle);
            let y:CGFloat = radius * sin(endAngle);
            let newPos:CGPoint = CGPoint(x: center.x + x, y: center.y + y);
            if i == 3 {
                path.move(to: newPos);
            }else if (i > 3 && i < 8){
                path.addLine(to: newPos);
            }else if (i == 8){
                path.addLine(to: newPos);
                path.closeSubpath();
            }
        }
    }
    
    
}
