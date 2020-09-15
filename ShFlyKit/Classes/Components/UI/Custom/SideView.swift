//
//  SideView.swift
//  SHKit
//
//  Created by hsh on 2019/12/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///侧边栏视图控制
class SideViewManager: UIView {
    //Variable
    static let shared = SideViewManager()
    private var sideView:UIView?                                        //侧边视图
    
    public var sideMargin:CGFloat = ScreenSize().width/4.0*3            //侧边展开时的宽度
    public var backColor = UIColor.colorHexValue("000000", alpha: 0.5)  //侧边展开时的背景颜色
    
    
    
    //添加侧边视图
    public func setSideView(_ view:UIView){
        self.sideView = view;
        self.sideView?.removeFromSuperview();
        //将当前添加到最上层
        if self.superview == nil {
            let keyWindow:UIWindow = UIApplication.shared.delegate!.window!!;
            self.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
            self.backgroundColor = backColor;
            keyWindow.addSubview(self);
            self.alpha = 0;
        }
        //添加侧边栏
        sideView?.frame = CGRect(x: -sideMargin, y: 0, width: sideMargin, height: ScreenSize().height);
        self.addSubview(sideView!);
    }
    
    
    //显示侧边栏
    public func showSide(){
        UIView.animate(withDuration: 0.3) {
            self.sideView?.frame = CGRect(x: 0, y: 0, width: self.sideMargin, height: ScreenSize().height);
            self.alpha = 1;
        };
    }
    
    
    //隐藏侧边栏
    public func hideSide(){
        UIView.animate(withDuration: 0.3) {
            self.sideView?.frame = CGRect(x: -self.sideMargin, y: 0, width: self.sideMargin, height: ScreenSize().height);
            self.alpha = 0;
        };
    }
   
    
    //点击收回
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        if point.x > sideMargin {
            self.hideSide();
        }
    }

    
}
