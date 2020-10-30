//
//  ViewTransfer.swift
//  SHKit
//
//  Created by hsh on 2018/10/31.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


//用于在这个界面上加载一个蒙层并使目标视图做指向运行的视图加载器


//动画方向
public enum TransDirection{
    case Top,Left,Bottom,Right,Center,FromPoint
}


public class ViewTransfer: UIView {
    // MARK: - 属性
    private var direction:TransDirection!  //运动的方向
    private var originRect:CGRect!         //添加前的位置
    private var animated:Bool = true;      //全局是否做动画
    private var trasnView:UIView!          //做动画的视图
    
    
    // MARK: - 做动画
    class public func transfer(direction:TransDirection,transView:UIView,blur:Bool = false,animated:Bool = true,backColor:UIColor = UIColor.colorHexValue("000000",alpha: 0.5))->Void{
        
        let instance = ViewTransfer();
        instance.direction = direction;
        instance.animated = animated;
        instance.trasnView = transView;
        
        let window = UIApplication.shared.keyWindow;
        //添加遮罩
        window?.addSubview(instance);
        instance.backgroundColor = backColor;
        //使用模糊蒙层
        if blur == true {
            instance.backgroundColor = .clear;
            let blurV = BlurEffect.blurEffect(effect: .light, view: instance);
            blurV.mas_makeConstraints { (make) in
                make?.left.top()?.right()?.bottom()?.mas_equalTo()(instance);
            }
        }
        instance.mas_makeConstraints { (maker) in
            maker?.top.left()?.bottom()?.right()?.mas_equalTo()(window);
        }
        //动画
        let width = transView.width;
        let height = transView.height;
        let x = (ScreenSize().width-transView.width)/2.0;
        let y = (ScreenSize().height-transView.height)/2.0;
        var targetRect:CGRect!
        switch direction {
        case .Top:
            instance.originRect = CGRect(x: x, y: -height, width: width, height: height);
            targetRect = CGRect(x: x, y: 0, width: width, height: height);
        case .Left:
            instance.originRect = CGRect(x: -width, y: y, width: width, height: height);
            targetRect = CGRect(x: 0, y: y, width: width, height: height);
        case .Bottom:
            instance.originRect = CGRect(x: x, y: ScreenSize().height, width: width, height: height);
            targetRect = CGRect(x: x, y: ScreenSize().height-height, width: width, height: height);
        case .Right:
            instance.originRect = CGRect(x: ScreenSize().width, y: y, width: width, height: height);
            targetRect = CGRect(x: ScreenSize().width-width, y: y, width: width, height: height);
        case .Center:
            instance.originRect = CGRect(x: ScreenSize().width/2, y: ScreenSize().height/2, width: 0, height: 0);
            instance.center = CGPoint(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height/2.0);
            targetRect = CGRect(x: ScreenSize().width/2-width/2.0, y:ScreenSize().height/2 - height/2.0, width: width, height: height);
        case .FromPoint:
            //判断X坐标和宽度
            var finalX:CGFloat = transView.x;
            var width = transView.width;
            if transView.x < ScreenSize().width/2.0{
                if width > ScreenSize().width-transView.x{
                    width = min(ScreenSize().width-transView.x,ScreenSize().width);//不超过屏幕右边界
                    finalX = ScreenSize().width-width;
                }
            }else{
                width = min(transView.width,transView.x);//不超过屏幕左边界
                finalX = transView.x-width;
            }
            //纵坐标
            var finalY:CGFloat = transView.y;
            var height = transView.height;
            if transView.y + transView.height > ScreenSize().height{
                height = min(transView.height, ScreenSize().height);
                finalY = ScreenSize().height - height;
            }
            instance.originRect = CGRect(x: transView.x, y: transView.y, width: 0, height: 0);
            targetRect = CGRect(x: finalX, y: finalY, width: width, height: transView.height);
        }
        instance.addSubview(transView);
        transView.frame = instance.originRect;
        //是否做动画
        if animated == true {
            UIView.animate(withDuration: 0.3) {
                transView.frame = targetRect;
            }
        }else{
            transView.frame = targetRect;
        }
    }
    
    
    // MARK: - Private Method
    @objc private func tapForDismiss()->Void{
        if animated == true{
            UIView.animate(withDuration: 0.3, animations: {
                self.trasnView.frame = self.originRect;
            }) { (result) in
                self.trasnView.removeFromSuperview();
                self.removeFromSuperview();
            }
        }else{
            trasnView.frame = originRect;
            trasnView.removeFromSuperview();
            self.removeFromSuperview();
        }
    }

    
    //点击去除视图
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        let rect = trasnView.frame;
        let contains = rect.contains(point);
        if  contains == false {
            self.tapForDismiss()
        }
    }
    
}
