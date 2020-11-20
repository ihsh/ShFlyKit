//
//  ChartZoomView.swift
//  ShFlyKit
//
//  Created by mac on 2020/11/19.
//

import UIKit


//滚动视图
public class ChartZoomView: UIView ,UIScrollViewDelegate,UIGestureRecognizerDelegate{
    //Variable
    public var minRate:CGFloat = 1          //最小比例
    public var maxRate:CGFloat = 10         //最大比例
    public var zoomV:UIView?                //放大的视图
    public var enaleRotate:Bool = true      //是否允许旋转
    
    private var scrollV:UIScrollView!
    private var netRotation:CGFloat = 0
    
    
    //Interface
    public func setZoomView(_ view:UIView){
        zoomV = view;//赋值
        //滚动视图初始化
        scrollV = UIScrollView();
        scrollV.delegate = self;
        scrollV.minimumZoomScale = minRate;
        scrollV.maximumZoomScale = maxRate;
        scrollV.showsVerticalScrollIndicator = false;
        scrollV.showsHorizontalScrollIndicator = false;
        scrollV.bouncesZoom = true;
        self.addSubview(scrollV);
        scrollV.mas_makeConstraints { (make) in
            make?.top.left()?.right()?.bottom()?.mas_equalTo()(self);
        }
        scrollV.addSubview(view);
        //旋转手势
        if enaleRotate {
            let ges = UIRotationGestureRecognizer.init(target: self, action: #selector(rotate(sender:)));
            ges.delegate = self;
            self.addGestureRecognizer(ges);
        }
    }
    

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomV;
    }
    
    
    @objc private func rotate(sender:UIRotationGestureRecognizer){
        //浮点类型，得到sender的旋转度数
        var rotation : CGFloat = sender.rotation
        //旋转角度CGAffineTransformMakeRotation,改变图像角度
        scrollV!.transform = CGAffineTransform(rotationAngle: rotation+netRotation)
        //状态结束，保存数据
        if sender.state == UIGestureRecognizerState.ended{
            netRotation += rotation
        }
    }
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
