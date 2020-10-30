//
//  GradientLayerView.swift
//  SHKit
//
//  Created by hsh on 2018/11/21.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit

//创建一个带渐变图层的视图

public class GradientLayerView: UIView {

    
    
    //设置渐变颜色
    public func setGradientColor(colors:[UIColor],
                                 startPonit:CGPoint = CGPoint(x: 0, y: 0),
                                 endPoint:CGPoint = CGPoint(x: 0, y:0))->Void{
        //init
        let gradientLayer = CAGradientLayer();
        gradientLayer.frame = self.bounds;
        self.layer.addSublayer(gradientLayer);
        //颜色
        var tmpsColors = [CGColor]();
        for color in colors {
            tmpsColors.append(color.cgColor);
        }
        gradientLayer.colors = tmpsColors;
        //方向
        gradientLayer.startPoint = startPonit;
        gradientLayer.endPoint = endPoint;
    }
    
    
    
}
