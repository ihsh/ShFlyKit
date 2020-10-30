//
//  ViewGradientTransfer.swift
//  SHKit
//
//  Created by hsh on 2019/2/28.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit



///视图滑动过程中顶部导航栏变化视图
public class ViewGradientTransfer: UIView {
    ///MARK-Variable
    private var tableview:UITableView!
    private var customNavView:UIView!
    private let navHeight:CGFloat = 44;
    
    
    //设置头部视图
    public func setCustomNav(_ view:UIView,height:CGFloat)->Void{
        customNavView = UIView()
        self.addSubview(customNavView);
        customNavView.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self);
            maker?.top.mas_equalTo()(self)?.offset()(navHeight);
            maker?.height.mas_equalTo()(height);
        }
        customNavView.addSubview(view);
        view.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(customNavView);
        }
    }
    
    
    //设置内容视图
    public func setContentView(_ tab:UITableView)->Void{
        self.tableview = tab;
        self.addSubview(self.tableview);
        self.sendSubview(toBack: self.tableview);
        tableview.mas_makeConstraints { (maker) in
            maker?.left.right()?.bottom()?.mas_equalTo()(self);
            maker?.top.mas_equalTo()(self)?.offset()(-navHeight);
        }
        self.tableview.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil);
    }
    
    
    ///MARK-UIScrollViewDelegate
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let point:CGPoint = self.tableview .value(forKeyPath: "contentOffset") as! CGPoint;
        let base:CGFloat = -navHeight; //基准线

        let contentY:CGFloat = point.y;
        //颜色变化
        if (contentY > -navHeight && contentY <= 60) {
            //高于基准线到0，渐渐变白色
            let sub = contentY - base;
            let alpha:CGFloat = sub / (60+navHeight);
            let color = UIColor.colorHexValue("FFFFFF", alpha: alpha);
            customNavView.alpha = alpha;
            customNavView.backgroundColor = color;
        }else if contentY < -navHeight {
            //小于基准线会慢慢的都隐藏
            let sub = -104 - contentY;
            let div = sub > 0 ? 0 : fabs(sub);
            let alpha:CGFloat = div / 100.0;
            customNavView.alpha = alpha;
        }else if contentY > 60{
            customNavView.alpha = 1;
            customNavView.backgroundColor = UIColor.white;
        }
        //距离变化
        let span = contentY + navHeight;
        if span < 0{
            customNavView.transform = CGAffineTransform.init(translationX: 0, y: -span);
        }else{
            customNavView.transform = CGAffineTransform.init(translationX: 0, y: -min(span,navHeight));
        }
        
    }
    

}
