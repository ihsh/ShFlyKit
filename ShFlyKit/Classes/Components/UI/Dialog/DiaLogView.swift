//
//  DiaLogView.swift
//  SHKit
//
//  Created by hsh on 2020/1/11.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//基类弹窗视图，要自定义继承该视图,重写方法
public class DialogBaseView:UIView,DiaLogConfigDelegate,UIGestureRecognizerDelegate{
    //Variable
    public var config:DiaLogConfig!
    public var containV:UIView!             //容器视图
    public var containSize:CGSize!          //容器视图的尺寸
    
    //DiaLogConfigDelegate
    public func initWithConfig(_ config: DiaLogConfig) {
        self.config = config;
        //设置点击消息
        if config.touchDismiss {
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction));
            tap.delegate = self;
            self.addGestureRecognizer(tap);
        }
    }
    
    public func didAddSubviews(superV: UIView) {}
    
    //Private
    @objc func tapAction(){
        self.removeFromSuperview();
    }
    
    //UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isEqual(self.containV))! {
            return false;
        }
        return true;
    }
    
}



//自定义视图-自定义示例
public class DiaLogView: DialogBaseView {

    
    public override func initWithConfig(_ config: DiaLogConfig) {
        super.initWithConfig(config);
        self.backgroundColor = config.backColor;
        //内容视图
        self.containV = UIView();
        containV.backgroundColor = config.containColor;
        containV.layer.cornerRadius = config.viewCorneradius;
        containV.layer.masksToBounds = true;
        self.addSubview(containV);
        //标题
        var allHeight:CGFloat = 0;
        let width:CGFloat = 280;
        let titleL = UILabel.initText(config.title, font: kFont(16), textColor: .black, alignment: .center, super: containV);
        titleL.mas_makeConstraints { (make) in
            make?.left.top()?.mas_equalTo()(containV)?.offset()(16);
            make?.right.mas_equalTo()(containV)?.offset()(-16);
        }
        allHeight += (16+22);
        if (config.msg != nil) {
            let contentL = UILabel.initText(config.msg, font: kFont(14), textColor: UIColor.colorHexValue("9E9E9E"), alignment: .center, super: self.containV);
            contentL.numberOfLines = 0;
            contentL.mas_makeConstraints { (make) in
                make?.left.right()?.mas_equalTo()(titleL);
                make?.top.mas_equalTo()(titleL.mas_bottom)?.offset()(8);
            }
            let height = (config.msg! as NSString).height(forWidth: CGFloat(width-32), font: kFont(14));
            allHeight += CGFloat(8 + height + 16);
        }
        //按钮
        let cancelBtn = UIButton.initTitle(config.cancelAction.title,
                                           textColor: config.cancelAction.textColor,
                                           back: config.cancelAction.backColor,
                                           font: config.cancelAction.font,
                                           super: self.containV);
        cancelBtn .mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self.containV)?.offset()(24);
            make?.bottom.right().mas_equalTo()(self.containV)?.offset()(-24);
            make?.height.mas_equalTo()(50);
        }
        cancelBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside);
        
        let comfirmBtn = UIButton.initTitle(config.comfirmAction.title,
                                            textColor: config.comfirmAction.textColor,
                                            back: config.comfirmAction.backColor,
                                            font: config.comfirmAction.font,
                                            super: self.containV);
        comfirmBtn .mas_makeConstraints { (make) in
            make?.height.left()?.right()?.mas_equalTo()(cancelBtn);
            make?.bottom.mas_equalTo()(cancelBtn.mas_top)?.offset()(-16);
        }
        comfirmBtn.layer.cornerRadius = config.btnsCorneradius;
        comfirmBtn.layer.masksToBounds = true;
        comfirmBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside);
        allHeight += (24 + 50 * 2 + 16 + 16);
        self.containSize = CGSize(width: width, height: allHeight);
    }
    
    
    public override func didAddSubviews(superV: UIView) {
        self.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(superV);
        }
        self.containV .mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(self);
            make?.size.mas_equalTo()(self.containSize);
        }
    }
    
    
    //Private
    @objc func btnClick(sender:UIButton){
        let text = sender.titleLabel?.text;
        if text == "取消"{
            self.config.cancelAction.action!(text!);
        }else{
            self.config.comfirmAction.action!(text!);
        }
        self.removeFromSuperview();
    }
    
}



//Toust
public class DiaLogToustView:DialogBaseView{
    
    //实现代理方法，初始化视图
    public override func initWithConfig(_ config: DiaLogConfig) {
        super.initWithConfig(config);
        //背景色
        self.backgroundColor = UIColor.colorHexValue("000000", alpha: 0.7);
        self.layer.cornerRadius = config.viewCorneradius;
        //消息文本
        let label = UILabel.initText(config.msg, font: kFont(16), textColor: UIColor.white, alignment: .center, super: self);
        //可换行
        label.numberOfLines = 0;
        label.mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(self);
            make?.left.mas_equalTo()(self)?.offset()(16);
            make?.right.mas_equalTo()(self)?.offset()(-16);
        }
        //计算所需宽高
        var width = NSString(string: config.msg ?? "").width(with: kFont(16)) + 40;
        width = min(width, ScreenSize().width-100);
        let height = NSString(string: config.msg ?? "").height(forWidth: width, font: kFont(16));
        self.containSize = CGSize(width: width+32, height: height+32);
        //延迟消失
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            self.removeFromSuperview();
        }
    }
    
    
    public override func didAddSubviews(superV: UIView) {
        self.mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(superV);
            make?.size.mas_equalTo()(self.containSize);
        }
    }
    
    
}


