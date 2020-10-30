//
//  SphereView.swift
//  SHKit
//
//  Created by hsh on 2020/1/3.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


///立体相册
public class SphereView: UIView , UIGestureRecognizerDelegate , DisplayDelegate {
    //Variable
    private var tags:[UIView] = []
    private var coordinate:[SpherePoint] = []
    private var norDirection:SpherePoint!
    private var last:CGPoint!
    private var velocity:CGFloat = 0
    
    
    //设置视图
    public func setViews(array:[UIView]){
        
        self.tags = array;
        for i in 0...tags.count-1 {
            let view = tags[i];
            //控制出现时的动画效果
            view.center = self.center;
        }
        
        let p1:CGFloat = CGFloat.pi * (3-sqrt(5));
        let p2:CGFloat = CGFloat(2)/CGFloat(tags.count);
        coordinate.removeAll();
        for i in 0...tags.count-1 {
            let y:CGFloat = CGFloat(i) * p2 - 1 + p2/2.0;
            let r:CGFloat = sqrt(1 - y * y);
            let p3:CGFloat = CGFloat(i) * p1;
            let x:CGFloat = cos(p3) * r;
            let z:CGFloat = sin(p3) * r;
            
            let point = MakePoint(x, y, z);
            coordinate.append(point);
            
            let time:TimeInterval = (Double(arc4random() % 10) + 10.0) / 20.0;
            UIView.animate(withDuration: time, delay: 0, options: .curveEaseOut, animations: {
                self.setViewOfPoint(point: point, index: i);
            }, completion: nil);
        }
        
        let a:Int = Int(arc4random() % 10) - 5;
        let b:Int = Int(arc4random() % 10) - 5;
        norDirection = MakePoint(CGFloat(a), CGFloat(b), 0);
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(gesture:)));
        self.addGestureRecognizer(gesture);
        HeatBeatTimer.shared.addDisplayTask(self);
    }
    

    public func displayCalled() {
        innerStep();
    }
    
    
    
    private func updateFrameOfPoint(index:Int,direction:SpherePoint,angle:CGFloat){
        let point:SpherePoint = coordinate[index];
        let rPos = PointMakeRotation(point, direction, angle);
        coordinate[index] = rPos;
        self.setViewOfPoint(point: rPos, index: index);
    }
    
    
    private func setViewOfPoint(point:SpherePoint,index:Int){
        let view:UIView = tags[index];
        //控制3D球形的位置
        view.center = CGPoint(x: (point.x + 1) * self.width/2.0 , y: (point.y + 1)*self.width/2.0);
        let tras:CGFloat = (point.z + 2.0) / 3.0;
        view.transform = CGAffineTransform.identity.scaledBy(x: tras, y: tras);
        view.layer.zPosition = tras;
        view.alpha = tras;
        if point.z < 0 {
            view.isUserInteractionEnabled = false;
        }else{
            view.isUserInteractionEnabled = true;
        }
    }
    
    
    private func innerStep(){
        if velocity <= 20 {
            for i in 0...tags.count-1 {
                self.updateFrameOfPoint(index: i, direction: norDirection, angle: 0.01);
            }
        }else{
            velocity -= 20.0;
            let angle:CGFloat = velocity / self.width * 2.0 * 0.02;
            for i in 0...tags.count-1 {
                self.updateFrameOfPoint(index: i, direction: norDirection, angle: angle);
            }
        }
    }
    
    
    //处理手势
    @objc private func handlePanGesture(gesture:UIPanGestureRecognizer){
        if (gesture.state == .began) {
            last = gesture.location(in: self);
            HeatBeatTimer.shared.cancelDisplayTask(self);
        }else if (gesture.state == .changed){
            let current:CGPoint = gesture.location(in: self);
            let direction:SpherePoint = MakePoint(last.y - current.y, current.x - last.x, 0);
            let distance:CGFloat = sqrt(direction.x*direction.x+direction.y*direction.y);
            let angle:CGFloat = distance / self.width / 2.0;
            for i in 0...tags.count-1 {
                self.updateFrameOfPoint(index: i, direction: direction, angle: angle);
            }
            norDirection = direction;
            last = current;
        }else if (gesture.state == .ended){
            let velocityP = gesture.velocity(in: self);
            velocity = sqrt(velocityP.x * velocityP.x + velocityP.y*velocityP.y);
            HeatBeatTimer.shared.addDisplayTask(self);
        }
    }
    
    
}


 
