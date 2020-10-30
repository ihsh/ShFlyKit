//
//  QueryAnimateVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/5.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class QueryAnimateVC: UIViewController,PayCheckDelegate,PayFuncDelegate {
    
    private var animaView = QueryCircleAnimateV()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        animaView.center = self.view.center;
        animaView.bounds = CGRect(x: 0, y: 0, width: 70, height: 70);
        self.view.addSubview(animaView);
        
        let btn = UIButton()
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside);
        btn .setTitle("开始", for: .normal);
        self.view.addSubview(btn);
        btn.backgroundColor = UIColor.colorRGB(red: 99, green: 174, blue: 248);
        btn.setTitleColor(UIColor.white, for: .normal);
        btn.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(self.view)?.offset()(-20);
            maker?.centerX.mas_equalTo()(self.view);
            maker?.width.mas_equalTo()(100);
            maker?.height.mas_equalTo()(60);
        }
        
        let checkBtn = UIButton()
        checkBtn.setTitle("支付结果", for: .normal);
        checkBtn.backgroundColor = UIColor.colorRGB(red: 99, green: 174, blue: 248);
        checkBtn.addTarget(self, action: #selector(payCheck), for: .touchUpInside);
        self.view.addSubview(checkBtn);
        checkBtn.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(btn.mas_top)?.offset()(-10);
            maker?.centerX.with()?.height()?.mas_equalTo()(btn);
            maker?.width.height()?.mas_equalTo()(btn);
        }
        
        let payBtn = UIButton()
        payBtn.setTitle("发起支付", for: .normal);
        payBtn.backgroundColor = UIColor.colorRGB(red: 99, green: 174, blue: 248);
        payBtn.addTarget(self, action: #selector(payClick), for: .touchUpInside);
        self.view.addSubview(payBtn);
        payBtn.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(checkBtn.mas_top)?.offset()(-10);
            maker?.centerX.with()?.height()?.mas_equalTo()(btn);
            maker?.width.height()?.mas_equalTo()(btn);
        }
    }
    
    
    //发起支付
    @objc private func payClick(){
        let payV = PayFuncView()
        payV.foldRow = 3;
        PayCheckV.shared.payView = payV;
        payV.callPay(money: 100, orderNo: "12343", delegate: self);
    }
    
    
    
    //仅调起支付结果
    @objc private func payCheck(){
        PayCheckV.shared.payCalled = true;
        PayCheckV.shared.configOrder(orderNo: "12343", delegate: self);
        PayCheckV.shared.checkPayResult(suc: false,fromSDK: false);
    }
    
    
    
    //PayFuncDelegate
    func refreshPage(msg: String) {
        
    }
    
    
    func callPay(type: PayType, orderNo: String) {
        //获取支付参数，
        PayCheckV.shared.payCalled = true;
        PayCheckV.shared.configOrder(orderNo: "12343", delegate: self);
        (PayCheckV.shared.payView as! PayFuncView).dismissFromSuper();
    }
    
    
    //自定义文案
    func editPayTypeDatas(data: [PayTypeData]) -> [PayTypeData]? {
        for it in data {
            if it.type == PayType.ZhiFubao{
                it.content = "使用花呗有优惠";
            }else if it.type == PayType.WeChat{
                it.content = "8.8你刷我买单";
            }else if it.type == PayType.ApplePay{
                it.content = "Apply返现1%";
            }else if it.type == PayType.Union{
                it.content = "银联支付立减5元"
            }
        }
        return data;
    }
    
    
    func payResult(suc: Bool, fromSDk: Bool) {
        PayCheckV.shared.checkPayResult(suc: suc,fromSDK: fromSDk);
    }
    
    
    
    //PayCheckDelegate
    func requestOrderPayResult(orderNo: String, first: Bool) {
        if first == false{
            PayCheckV.shared.requestResult(success: false, first: first);
        }else{
            PayCheckV.shared.requestResult(success: false, first: first);
        } 
    }
    
    
    func checkResult(suc: Bool) {
        
    }
    
    
    func repayCalled() {
        payClick()
    }

    
    
    //动画状态轮转
    @objc private func btnClick(sender:UIButton){
        let title:String = (sender.titleLabel?.text!)!;
        if title == "开始"{
            animaView.startLoadingAnimate();
            sender .setTitle("成功", for: .normal);
        }else if title == "成功"{
            animaView.showSuccessAnimate();
            sender .setTitle("继续", for: .normal);
        }else if title == "继续"{
            animaView.startLoadingAnimate();
            sender .setTitle("失败", for: .normal);
        }else if title == "失败"{
            animaView.showFailAnimate();
            sender .setTitle("结束", for: .normal);
        }else if title == "结束"{
            animaView.stopAnimate();
            sender .setTitle("开始", for: .normal);
        }
    }

   

}
