//
//  LockDotThumbV.swift
//  SHKit
//
//  Created by hsh on 2019/8/14.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//设置图案解锁时的
public class LockDotThumbV: UIView {
    ///Variable
    public var dotRadius:CGFloat = 4;
    public var norColor:UIColor!
    public var hightColor:UIColor!
    
    private let dotCount:Int = 9            //点的数量
    private var indexs:[Bool] = []     //选中的情况
    
    
    ///Draw
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        let size = self.bounds.size;
        for i in 0...dotCount-1 {
            let cx = (size.width / 3) * CGFloat(0.5 + Double(i % 3));
            let cy = (size.height / 3) * CGFloat(0.5 + Double(i / 3));
            context?.addArc(center: CGPoint(x: cx, y: cy), radius: dotRadius, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true);
            if indexs[i] == true{
                context?.setFillColor(hightColor.cgColor);
            }else{
                context?.setFillColor(norColor.cgColor);
            }
            context?.drawPath(using: .fill);
        }
    }
    
    
    ///Interface
    //重置所有的点
    public func resetIndex(){
        indexs.removeAll();
        while (indexs.count < dotCount) {
            indexs.append(false);
        }
        self.setNeedsDisplay();
    }
    
    
    //设置某个点点亮
    public func setIndexes(index:Int,select:Bool){
        if index >= 0 && index < dotCount {
            indexs[index] = select;
        }
        self.setNeedsDisplay();
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.resetIndex();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
