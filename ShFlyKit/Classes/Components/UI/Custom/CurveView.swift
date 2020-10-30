

//
//  CurveView.swift
//  SHKit
//
//  Created by hsh on 2019/6/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

//弯曲的边-上边还是下边
public enum CurveFloor{
    case Up,Down
}

//内弯的方向，是向上还是向下
public enum CurveInnerDirection{
    case Up,Down
}


//画弧线的UIView,只在水平方向,上边或者下边
public class CurveView: UIView {
    //Variable
    public var offset:CGFloat = 30                      //偏移的距离--0的话就没有变化
    public var fillColor:UIColor = UIColor.white        //填充的颜色
    public var floor:CurveFloor = .Up                   //偏移的位置
    public var direction:CurveInnerDirection = .Up;     //偏移的方向
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //清空背景色
        self.backgroundColor = UIColor.clear;
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public override func draw(_ rect: CGRect) {
        let x = rect.origin.x;
        let y = rect.origin.y;
        let width = rect.size.width;
        let height = rect.size.height;
        let context = UIGraphicsGetCurrentContext();
        //画笔线的颜色
        context?.setStrokeColor(red: 1, green: 0, blue: 0, alpha: 0);
        //线的宽度
        context?.setLineWidth(1);
        //填充颜色
        context?.setFillColor(fillColor.cgColor);
        
        //绘制路径--左上角，左下角，边，右下角，右上角，边，左上角
        if floor == .Up {
            if direction == .Up{
                context?.move(to: CGPoint(x: x, y: y+offset));
                context?.addLine(to: CGPoint(x: x, y: height));
                context?.addLine(to: CGPoint(x: width, y: height));
                context?.addLine(to: CGPoint(x: width, y: y+offset));
                context?.addArc(tangent1End: CGPoint(x: width/2.0, y: y), tangent2End: CGPoint(x: x, y: y+offset), radius: width*2)
                context?.addLine(to: CGPoint(x: x, y: y+offset));
            }else{
                context?.move(to: CGPoint(x: x, y: y));
                context?.addLine(to: CGPoint(x: x, y: height));
                context?.addLine(to: CGPoint(x: width, y: height));
                context?.addLine(to: CGPoint(x: width, y: y));
                context?.addArc(tangent1End: CGPoint(x: width/2.0, y: offset), tangent2End: CGPoint(x: x, y: y), radius: width*2)
                context?.addLine(to: CGPoint(x: x, y: y));
            }
        }else{
            if direction == .Up{
                context?.move(to: CGPoint(x: x, y: y));
                context?.addLine(to: CGPoint(x: x, y: height));
                context?.addArc(tangent1End: CGPoint(x: width/2.0, y: height-offset), tangent2End: CGPoint(x: width, y: height), radius: width*2)
                context?.addLine(to: CGPoint(x: width, y: height));
                context?.addLine(to: CGPoint(x: width, y: y));
                context?.addLine(to: CGPoint(x: x, y: y));
            }else{
                context?.move(to: CGPoint(x: x, y: y));
                context?.addLine(to: CGPoint(x: x, y: height-offset));
                context?.addArc(tangent1End: CGPoint(x: width/2.0, y: height), tangent2End: CGPoint(x: width, y: height-offset), radius: width*2)
                context?.addLine(to: CGPoint(x: width, y: height-offset));
                context?.addLine(to: CGPoint(x: width, y: y));
                context?.addLine(to: CGPoint(x: x, y: y));
            }
        }
        context?.drawPath(using: .fillStroke);
    }
    
    
    //重新绘制
    public func reDraw(){
        self.setNeedsDisplay();
    }
    
    
}
