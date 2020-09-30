//
//  MapControlView.swift
//  SHKit
//
//  Created by hsh on 2018/10/30.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import Masonry

///地图上控制层，处理空白与按钮的点击

class MapControlView: UIView {
    // MARK: - 属性
    public var bottomBar:UIView!              //底部视图
    public var topBar:UIView!                 //顶部视图
    public var rightBar:UIView!               //右侧视图
    
    
    // MARK: - 事件处理
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //自己不能接收事件
        if (self.isUserInteractionEnabled == false ||
            self.isHidden == true ||
            self.alpha <= 0.01) {
            self.endEditing(true);
            return nil;
        }
        //判断点在不在当前控件上
        if (self.point(inside: point, with: event) == false){
            self.endEditing(true);
            return nil;
        }
        //遍历子控件
        for view in self.subviews{
            let poi = self.convert(point, to: view);
            let fitView = view.hitTest(poi, with: event);
            if fitView != nil{
                if fitView?.backgroundColor == UIColor.clear || fitView?.isOpaque == true{
                    self.endEditing(true);
                    return nil;
                }else{
                    return fitView;
                }
            }
        }
        self.endEditing(true);
        return nil;
    }
    
    
    
    // MARK: - Interface
    ///控制操作视图显示和隐藏
    public func controlViewShow(show:Bool)->Void{
        if show == true {
            UIView.animate(withDuration: 0.3) {
                self.topBar.transform = CGAffineTransform.identity;
                self.rightBar.transform = CGAffineTransform.identity;
                self.bottomBar.transform = CGAffineTransform.identity;
            };
        }else{
            let transformHead = CGAffineTransform.init(translationX: 0, y: -topBar.height);
            let transformBottom = CGAffineTransform.init(translationX: 0, y: bottomBar.height);
            let transformRight = CGAffineTransform.init(translationX: rightBar.width, y: 0);
            UIView.animate(withDuration: 0.3) {
                self.topBar.transform = transformHead;
                self.rightBar.transform = transformRight;
                self.bottomBar.transform = transformBottom;
            };
        }
    }
    
    
    
    ///初始化三个视图
    public func initDefaultControl(topHeight:CGFloat,bottomHeight:CGFloat,rightWidth:CGFloat)->Void{
        //顶部栏
        self.topBar = UIView();
        self.addSubview(topBar);
        self.topBar.backgroundColor = UIColor.clear
        topBar.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(topHeight);
        }
        //底部栏
        self.bottomBar = UIView();
        self.addSubview(bottomBar);
        self.bottomBar.backgroundColor = UIColor.clear
        bottomBar.mas_makeConstraints { (maker) in
            maker?.left.right()?.bottom()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(bottomHeight);
        }
        //右侧栏目
        self.rightBar = UIView();
        self.addSubview(rightBar);
        self.rightBar.backgroundColor = UIColor.clear
        rightBar.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(self);
            maker?.width.mas_equalTo()(rightWidth);
            maker?.top.mas_equalTo()(topBar.mas_bottom);
            maker?.bottom.mas_equalTo()(bottomBar.mas_top);
        }
    }
 
    
    
    
}
