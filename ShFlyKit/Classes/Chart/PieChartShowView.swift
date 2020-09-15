//
//  PieChartShowView.swift
//  SHKit
//
//  Created by hsh on 2019/3/5.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


///饼图-简易绘制
class PieChartShowView: UIView {
    //mark-Variable
    private var radius:CGFloat = 0                  //绘制圆的半径
    private var comonents:[PieComponent] = []       //绘制的数据
    public  var descFont:UIFont = kFont(10)         //绘制的文字大小，默认系统10号字体
    public  var innerRadiusRate:CGFloat = 0.36      //内圆半径所占圆半径的比例
    public  var rotateDegree:CGFloat = -90          //起点与角度0的偏差值
    public  var circleWidth:CGFloat = 8             //内环圆圈宽度
    public  var lineWidth:CGFloat = 1               //连线的宽度
    public  var circleColor:UIColor = UIColor.colorRGB(red: 46, green: 46, blue: 46, alpha: 0.11) //内环颜色
    public  var radiusSub:CGFloat = 8               //高度的一半减去该值得到半径
    public  var labelRadiusAdd:CGFloat = 20         //文本半径在圆的半径上加多少
    
    
    ///load
    override func layoutSubviews() {
        super.layoutSubviews();
        if radius == 0 {
             radius = self.height / 2 - radiusSub;
        }
        self.backgroundColor = UIColor.white;
    }
    
    
    ///MARK-Interface
    public func showChart(_ pies:[PieComponent])->Void{
        self.comonents = pies;
        self.setNeedsDisplay()
    }
    
    
    //绘制
    override func draw(_ rect: CGRect) {
        //累加和
        var sum:CGFloat = 0;
        for component in comonents {
            sum += component.value;
        }
        //累加和为0(没有数据)返回
        if (sum == 0) {return}
        
        //左右两部分的数据容器，分开存储
        var leftComponents:[PieComponent] = [];
        var rightComponents:[PieComponent] = [];
        //中心点的坐标值
        let centerX = rect.midX;
        let centerY = rect.midY;
        //垂直最多可容纳字的个数
        let descMaxCount:NSInteger = Int(rect.height/descFont.pointSize);
        //获取图形上下文
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        //起始角度值
        var startDegree:CGFloat = 0;
        
        //绘制饼图部分
        for (_,item) in comonents.enumerated(){
            //所占比例
            let percentage:CGFloat = item.value / sum;
            //对应的结束角度
            let endDegree:CGFloat = startDegree + percentage * 360;

            //绘制圆弧
            context.setFillColor(item.color.cgColor);                   //设置填充色
            context.move(to: CGPoint(x: centerX, y: centerY));          //移动到中心点
            //逆时针旋转90度画弧
            context.addArc(center: CGPoint(x: centerX, y: centerY),
                           radius: radius,
                           startAngle: (startDegree+rotateDegree)*CGFloat(Double.pi)/180.0,
                           endAngle: (endDegree+rotateDegree)*CGFloat(Double.pi)/180.0,
                           clockwise: false);
            context.closePath();
            context.fillPath();
            //赋值角度
            item.startDegree = startDegree;
            item.endDegree = endDegree;
            //判断，添加数据
            let middle:CGFloat = (startDegree+endDegree)/2.0;
            if (middle < 180) {
                if (rightComponents.count < descMaxCount){
                    rightComponents.append(item);
                }
            }else{
                if (leftComponents.count < descMaxCount){
                    leftComponents.append(item);
                }
            }
            //上一次的终点，下一次的起点
            startDegree = endDegree;
        }
        
        //画饼图中心外一层圈圆
        context.setFillColor(circleColor.cgColor);
        context.addArc(center: CGPoint(x: centerX, y: centerY),
                       radius: radius * innerRadiusRate + circleWidth,
                       startAngle: 0,
                       endAngle: 2*CGFloat(Double.pi),
                       clockwise: false);
        context.drawPath(using: .fill);
        //画饼图中心内一层圈圆
        context.setFillColor(UIColor.white.cgColor);
        context.addArc(center: CGPoint(x: centerX, y: centerY),
                       radius: radius * innerRadiusRate,
                       startAngle: 0,
                       endAngle: 2*CGFloat(Double.pi),
                       clockwise: false);
        context.drawPath(using: .fill);
        
        //绘制饼图外右边的文本
        var rightDelta = rect.height;
        if rightComponents.count > 0 {
            rightDelta /= CGFloat(rightComponents.count);
        }
        //控制起点
        var rightLabelY = rightDelta/2.0;
        for (_,component) in rightComponents.enumerated() {
            //文本的起点距圆心的距离
            let labelRadius:CGFloat = radius + labelRadiusAdd;
            let deltaY:CGFloat = rightLabelY - centerY;
            //勾股定理 斜边-垂直边-水平边
            let sqrtX:CGFloat = CGFloat(sqrtf(Float(fabs(labelRadius*labelRadius-deltaY*deltaY))));
            let labelX:CGFloat = sqrtX + centerX;
            //文本的绘制区域计算
            let descText:NSString = component.content;
            //文字所需宽高
            let optimumSize:CGSize = descText.size(withAttributes: [NSAttributedStringKey.font : descFont]);
            let descRect = CGRect(x: labelX, y: rightLabelY, width: optimumSize.width, height: optimumSize.height);
            //绘制
            context.setFillColor(component.color.cgColor);
            descText.draw(in: descRect, withAttributes: [NSAttributedStringKey.font:descFont,NSAttributedStringKey.foregroundColor:component.textColor.cgColor]);
            context.setStrokeColor(component.color.cgColor)
            context.setLineWidth(lineWidth/UIScreen.main.scale);
            //移动到控制点，添加线
            let middle = (component.startDegree+component.endDegree)/2.0+rotateDegree;
            let x1:CGFloat = (radius+1)*cos(middle*CGFloat(Double.pi)/180)+centerX;
            let y1:CGFloat = (radius+1)*sin(middle*CGFloat(Double.pi)/180)+centerY;
            context.move(to: CGPoint(x: x1, y: y1));
            //控制点
            let controlPointX:CGFloat = (labelX + x1) / 2.0;
            var controlPointY:CGFloat = y1;
            if y1 > rightLabelY && y1 < (rightLabelY + optimumSize.height) {
                controlPointY += optimumSize.height;
            }
            //终点的坐标计算
            var targetY:CGFloat = rightLabelY;
            if y1 > rightLabelY && y1 < rightLabelY + optimumSize.height {
                targetY += optimumSize.height / 2.0;
            }else if y1 > rightLabelY + optimumSize.height {
                targetY += optimumSize.height;
            }
            context.addQuadCurve(to: CGPoint(x: labelX, y: targetY), control: CGPoint(x: controlPointX, y: controlPointY));
            context.strokePath();
            
            rightLabelY += rightDelta;
        }
        
        //绘制饼图外左边的文本
        let height:CGFloat = rect.height;
        var leftDelta:CGFloat = height;
        if leftComponents.count > 0 {
            leftDelta /= CGFloat(leftComponents.count);
        }
        var leftLabelY:CGFloat = height - leftDelta/2.0;
        for (_,component) in leftComponents.enumerated() {
            //绘制区域
            let descText:NSString = component.content;
            //文本所需宽高
            let optimumSize:CGSize = descText.size(withAttributes: [NSAttributedStringKey.font : descFont]);
            let labelRadius = radius + labelRadiusAdd;
            let deltaY:CGFloat = leftLabelY - centerY;
            let sqrtX:CGFloat = CGFloat(sqrtf(Float(fabs(labelRadius*labelRadius-deltaY*deltaY))));
            let labelX = centerX - sqrtX - optimumSize.width;
            let descRect = CGRect(x: labelX, y: leftLabelY, width: optimumSize.width, height: optimumSize.height);
            //绘制
            context.setFillColor(component.color.cgColor);
            descText.draw(in: descRect, withAttributes: [NSAttributedStringKey.font:descFont,NSAttributedStringKey.foregroundColor:component.textColor.cgColor]);
            context.setStrokeColor(component.color.cgColor);
            context.setLineWidth(lineWidth/UIScreen.main.scale);
            //起点
            let middle:CGFloat = (component.startDegree+component.endDegree)/2.0 + rotateDegree;
            let x1:CGFloat = (radius + 1) * cos(middle*CGFloat(Double.pi)/180.0) + centerX;
            let y1:CGFloat = (radius + 1) * sin(middle*CGFloat(Double.pi)/180.0) + centerY;
            //移动到控制点
            context.move(to: CGPoint(x: x1, y: y1));
            //计算终点
            let controlPointX:CGFloat = (labelX + x1) / 2.0;
            var controlPointY:CGFloat = y1;
            if y1 > leftLabelY && y1 < (leftLabelY + optimumSize.height) {
                controlPointY += optimumSize.height;
            }
            //目标的Y坐标
            var targetY:CGFloat = leftLabelY;
            if y1 > leftLabelY {
                targetY += optimumSize.height;
            }
            //当切点在文字的最大X坐标的右边
            var targetX:CGFloat = labelX;
            if x1 > labelX && x1 < labelX + optimumSize.width {
                targetX = labelX+optimumSize.width/2.0;
            }else if x1 > labelX+optimumSize.width {
                targetX = labelX+optimumSize.width;
            }
            context.addQuadCurve(to: CGPoint(x: targetX, y: targetY), control: CGPoint(x: controlPointX, y: controlPointY));
            context.strokePath();
            leftLabelY -= leftDelta;
        }
    }
}





///图表的数据模型
class PieComponent: NSObject {
    public var value:CGFloat = 0            //数值
    public var color:UIColor!               //对应部分饼图的颜色
    public var content:NSString!            //饼图对应的文字
    public var textColor:UIColor!           //饼图对应的文字的颜色
    
    public var startDegree:CGFloat = 0      //起点的角度值
    public var endDegree:CGFloat = 0        //终点的角度值

    
    //初始化方法
    class public func initValue(_ value:CGFloat,color:UIColor,content:NSString,textColor:UIColor?)->PieComponent{
        let component = PieComponent()
        component.value = value;
        component.color = color;
        component.content = content;
        component.textColor = textColor ?? color;
        return component;
    }
    
}
