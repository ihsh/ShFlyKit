//
//  LineWaver.swift
//  SHKit
//
//  Created by hsh on 2019/5/30.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//线状波浪图
public class LineWaver: UIView {
    //Variable
    public var numberOfWaves:NSInteger = 10                             //线条数
    public var waveColors:[UIColor] = [UIColor.randomColor()]           //颜色数组，按顺序取颜色，超出范围取最后一个下标的颜色
    public var lineWidths:[CGFloat] = [1.5,1];                          //线条宽度，按顺序取线宽，超出范围取最后一个下标的线宽
    
    public var idleAmplitude:CGFloat = 0                                //闲置时候的振幅
    public var frequency:CGFloat = 1.2                                  //频率
    public var density:CGFloat = 2                                      //计算点的密度,X相距多少算一次
    public var phaseShift:CGFloat = -0.25
    public var lineWidthdiminishing:Bool = true                         //线条宽度是否递减
    
    private var waves:[CAShapeLayer] = []                               //波纹
    private var phase:CGFloat = 0                                       //阶段?
    private var amplitude:CGFloat = 1                                   //振幅
    
    
    //初始化线条,或重置线条
    public func initConfig(){
        self.waves.removeAll();         //清除已有线条
        for i in 0...numberOfWaves-1 {
            let waveLine = CAShapeLayer()
            waveLine.lineCap = kCALineCapButt;
            waveLine.lineJoin = kCALineJoinRound;
            waveLine.strokeColor = UIColor.clear.cgColor;
            waveLine.fillColor = UIColor.clear.cgColor;
            //设置线宽，如果没有设置默认为1
            var linewidth:CGFloat = 1;
            var color:UIColor = UIColor.clear;
            if (lineWidths.count > 0) {
                for index in 0...lineWidths.count-1{
                    if (index <= i){//先按顺序取，不然就是数组最后一个值
                        linewidth = lineWidths[index];
                    }
                }
            }
            if (waveColors.count > 0){
                for index in 0...waveColors.count-1{
                    if (index <= i){//先按顺序取，不然就是数组最后一个值
                        color = waveColors[index];
                    }
                }
            }
            let part = linewidth / CGFloat(numberOfWaves);
            waveLine.lineWidth = lineWidthdiminishing ? linewidth - part * CGFloat(i) : linewidth;
            let progress:CGFloat = 1.0 - CGFloat(i)/CGFloat(numberOfWaves);
            let multiplier:CGFloat = min(1.0, (progress/3.0*2.0) + (1.0/3.0));
            let lineColor:UIColor = color.withAlphaComponent(i == 0 ? 1.0 : 1 * multiplier * 0.4);
            waveLine.strokeColor = lineColor.cgColor;
            self.layer.addSublayer(waveLine);
            self.waves.append(waveLine);
        }
    }
    
    
    //更新振幅
    public func updateAmplitude(_ value:CGFloat) {
        self.phase += self.phaseShift;
        self.amplitude = fmax(value, self.idleAmplitude);
        self.updateMeters();
    }
    
    

    //更新波纹
    private func updateMeters(){
        let waveHeight:CGFloat = self.height;
        let waveWidth:CGFloat = self.width;
        let waveMid:CGFloat = waveWidth / 2;
        let maxAmplitude:CGFloat = waveHeight - 4;
        
        UIGraphicsBeginImageContext(self.frame.size);
        for i in 0...numberOfWaves-1{
            let path = UIBezierPath()
            let progress:CGFloat = 1.0 - CGFloat(i)/CGFloat(numberOfWaves);//注意类型转换
            let noredAmplitude = (1.5 * progress - 0.5) * self.amplitude;
            
            var offset:CGFloat = 0;
            while(offset < waveWidth + self.density){
                let scaling:CGFloat = -pow(offset/waveMid - 1, 2) + 1;
                let c = sinf(2 * Float(Double.pi) * Float(offset / waveWidth) * Float(self.frequency) + Float(self.phase));
                let y:CGFloat = CGFloat(scaling * maxAmplitude * noredAmplitude * CGFloat(c)) + (waveHeight * 0.5);
                if (offset == 0) {
                    path.move(to: CGPoint(x: offset, y: y));
                }else{
                    path.addLine(to: CGPoint(x: offset, y: y));
                }
                offset += (self.density != 0) ? self.density : 1;
            }
            let waveLine = self.waves[i];
            waveLine.path = path.cgPath;
        }
        UIGraphicsEndImageContext();
    }

    
}
