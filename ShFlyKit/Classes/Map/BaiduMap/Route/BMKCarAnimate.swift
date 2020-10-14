//
//  BMKCarAnimate.swift
//  SHKit
//
//  Created by hsh on 2019/1/18.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///小车动画代理
protocol BMKCarAnimateDelegate:NSObjectProtocol {
    //小车标注已经设置好了
    func carAnnoViewHasSet()
}


///小车动画类
class BMKCarAnimate: NSObject {
    ///MARK
    public weak var delegate:BMKCarAnimateDelegate?
    
    //私有
    private var mapView:BMKMapView!
    private var carAnnoView:BMKAnnotationView?      //小车标注
    private var selectLine:BMKTrafficPolyline!      //选中的路线
    private var step:NSInteger = 0                   //步数
    private var lastAngle:CGFloat = 0
   
    
    ///MARK-Interface
    public func setCarAnnoView(_ annoView:BMKAnnotationView?,mapView:BMKMapView)->Void{
        self.carAnnoView = annoView;
        self.mapView = mapView;
        delegate?.carAnnoViewHasSet()
    }
    
    
    //开始某条路线的小车动画
    public func setAnimateForLine(_ line:BMKTrafficPolyline)->Void{
        self.selectLine = line;
    }
    
    
    //修改动画
    public func changeTraceIndex()->Void{
        let index = self.step;
        if carAnnoView != nil {
            let line:BMKTrafficPolyline = self.selectLine;
            if index < line.pointNum - 2 {
                let point = line.savePoint[index];
                let next = line.savePoint[index + 1];
                
                self.addMoveAnnimation([point,next], duration: 1) { (index) in

                }
//                let annotion:[BMKPointAnnotation] = self.mapView!.annotations as! [BMKPointAnnotation];
//                for an in annotion{
//                    if an.title() == "car"{
//                        self.mapView.removeAnnotation(an);
//                        let carAnno = BMKPointAnnotation()
//                        carAnno.title = "car";
//                        carAnno.coordinate = BMKCoordinateForMapPoint(point);
//                        self.mapView.addAnnotation(carAnno);
//                    }
//                }
            }
            self.step += 1; //步数加1
        }
    }
    
    
    //添加动画
    private func addMoveAnnimation(_ coordinates:[BMKMapPoint],duration:CGFloat,step:(_ passedPointCount:NSInteger)->Void)->Void{
        if coordinates.count<2 {
            return;
        }
        //位置移动的动画
        let keyAni:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position");
        keyAni.duration = CFTimeInterval(duration);
        keyAni.isRemovedOnCompletion = false;
        keyAni.fillMode = kCAFillModeForwards;
        keyAni.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        var values:[NSValue] = [];
        for point in coordinates {
            let coor:CLLocationCoordinate2D = BMKCoordinateForMapPoint(point);
            let pt:CGPoint = self.mapView.convert(coor, toPointTo: self.mapView);
            let value:NSValue = NSValue.init(cgPoint: pt);
            values.append(value);
        }
        keyAni.values = values;
        //旋转动画
        let rotateAni:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z");
        rotateAni.duration = CFTimeInterval(duration);
        rotateAni.isRemovedOnCompletion = false;
        rotateAni.fillMode = kCAFillModeForwards;
        rotateAni.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        
        var angles:[NSValue] = [];
        angles.append(lastAngle as NSValue);
        for index in 0..<coordinates.count - 1 {
            let point1 = coordinates[index];
            let coor1:CLLocationCoordinate2D = BMKCoordinateForMapPoint(point1);
            let pt1:CGPoint = self.mapView.convert(coor1, toPointTo: self.mapView);
            let point2 = coordinates[index + 1];
            let coor2:CLLocationCoordinate2D = BMKCoordinateForMapPoint(point2);
            let pt2:CGPoint = self.mapView.convert(coor2, toPointTo: self.mapView);
            
            let angle = angleForPoints(pt1, end: pt2);
            angles.append(angle as NSValue)
            lastAngle = angle;
        }
        rotateAni.values = angles;
        
        //动画组
        let group:CAAnimationGroup = CAAnimationGroup()
        group.animations = [keyAni,rotateAni];
        group.duration = CFTimeInterval(duration);
        group.fillMode = kCAFillModeForwards;
        group.isRemovedOnCompletion = false;
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        self.carAnnoView!.layer.add(group, forKey: "group");
    }
    
    
    private func angleForPoints(_ start:CGPoint,end:CGPoint)->CGFloat{
        let BC:CGFloat = fabs(end.y - start.y);
        let AC:CGFloat = fabs(end.x - start.x);
        
        let tans = BC/AC;
        var angle = atan(tans);
        if AC == 0 {
            angle = 90;
        }
        if BC == 0 {
            angle = 180;
        }
        if start.x < end.x && start.y > end.y {//0-90度
            return angle;
        }else if (start.x > end.x && start.y > end.y){//90-180度
            return 180 - angle;
        }else if (start.x > end.x && start.y < end.y){//180-270度
            return 180 + angle;
        }else if (start.x < end.x && start.y < end.y){
            return 360 - angle;
        }
        return 0;
    }
    
}
