//
//  PayCheckV.swift
//  SHKit
//
//  Created by hsh on 2019/8/5.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///支付结果页查询代理
@objc protocol PayCheckDelegate:NSObjectProtocol {
    //支付回调
    @objc func checkResult(suc:Bool);
    //重新唤起支付
    @objc func repayCalled();
    //调起一次支付结果查询请求
    @objc func requestOrderPayResult(orderNo:String,first:Bool)
}


///支付结果确认页
class PayCheckV: UIView , HeatBeatTimerDelegate{
    //Variable
    static let shared = PayCheckV(frame: CGRect.zero)//单例
    public var payView:UIView?                      //支付的视图
    public weak var delegate:PayCheckDelegate?      //代理对象
    
    public var payCalled:Bool = false               //是否支付调用
    public var checkTimes:Int = 3                   //检查的次数
    //只读信息
    public private(set) var orderNo:String!         //订单号
    public private(set) var checking:Bool = false   //是否正在查询
    public private(set) var lastPayTime:TimeInterval!//最后一次的调用时间
    //界面
    private var markV:UIView!                       //遮罩
    private var containV:UIView!                    //内容视图
    private var animateV:QueryCircleAnimateV!       //动画视图
    private var errorImagV:UIImageView!             //中间的图标-异常
    private var statusL:UILabel!                    //状态文字
    private var leftBtn:UIButton!                   //左侧按钮
    private var rightBtn:UIButton!                  //右侧按钮
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //添加通知
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: .UIApplicationWillEnterForeground, object: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///Interface
    //设置订单号和代理--发起支付的时候
    public func configOrder(orderNo:String,delegate:PayCheckDelegate){
        self.orderNo = orderNo;
        self.delegate = delegate;
    }
    
    
    //开始检查订单状况--注册后，支付的回调和后台到前台的通知都会调用
    public func checkPayResult(suc:Bool,fromSDK:Bool){
        //SDK返回结果是失败的
        if fromSDK == true && suc == false {
            self.dismissFromSuper();
            return;
        }
        //必须先设置订单号和代理!!!
        if orderNo == nil || delegate == nil{
            return;
        }
        //防止未支付就进行请求--后台进前台拦截
        if payCalled == false{
            return;
        }
        //去除SDK回调等的重复调用
        if checking == true {
            return;
        }
        let window:UIWindow? = UIApplication.shared.delegate!.window ?? nil;
        if window != nil {
            //构建UI
            buildSubViews();
            //移除支付视图
            payView?.removeFromSuperview();
            //先添加遮罩，遮罩一开始是隐藏的
            window!.addSubview(markV);
            markV.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(window!);
            }
            markV.isHidden = true;
            //数据设置
            checking = true;
            payCalled = true;
            //调起第一次的支付查询请求
            delegate?.requestOrderPayResult(orderNo: orderNo,first: true);
        }
    }
    
    
    //移除显示
    @objc public func dismissFromSuper(){
        //取消定时器的检查，如果有
        HeatBeatTimer.shared.cancelTaskForKey(taskKey: "PayCheckV");
        //重置数据
        checking = false;
        payCalled = false;
        orderNo = nil;
        
        UIView.animate(withDuration: 0.3, animations: {
            self.containV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: ScreenSize().height);
            self.containV.alpha = 0;
        }) { (_) in
            self.markV?.removeFromSuperview();
            //动画停止
            self.animateV.stopAnimate();
            self.animateV.stopLoadingAnimate();
            self.animateV.isHidden = true;
        }
    }
    
    
    //请求的结果，传入内部
    public func requestResult(success:Bool,first:Bool){
        if success {
            //成功后结束定时器
            HeatBeatTimer.shared.cancelTaskForKey(taskKey: "PayCheckV");
            //短震
            let impact = UIImpactFeedbackGenerator.init(style: .heavy);
            impact.impactOccurred();
            
            DispatchQueue.main.async {
                if first == false{
                    //界面是可见的，打钩
                    self.animateV.isHidden = false;
                    self.animateV.showSuccessAnimate();
                    self.statusL.text = nil;
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.delegate?.checkResult(suc: true);
                        self.dismissFromSuper();
                    })
                }else{
                    //第一次究成功，界面只是加载并隐藏，看不见
                    self.delegate?.checkResult(suc: true);
                    self.dismissFromSuper();
                }
            }
        }else{
            if first{
                //第一次查询没有成功，就展示出界面
                DispatchQueue.main.async {
                    self.payView?.removeFromSuperview()
                    self.payView = nil;
                    self.markV.isHidden = false;
                }
            }
        }
    }
    
    
    
    
    //Private
    //进入前台
    @objc private func enterForGround(){
        self.checkPayResult(suc: false, fromSDK: false);
    }
    
    
    //左按钮点击
    @objc private func leftBtnClick(){
        if leftBtn.titleLabel?.text! == "未支付" {
            delegate?.repayCalled();
        }else{
            delegate?.checkResult(suc: false);
        }
        dismissFromSuper();
    }
    
    
    //继续查询状态
    @objc private func containueQuery(){
        animateV.isHidden = false;
        animateV.startLoadingAnimate();
        leftBtn.isHidden = true;
        rightBtn.isHidden = true;
        statusL.text = "支付结果查询中";
        //添加的时候会立即执行第一次的调用，然后再间隔
        HeatBeatTimer.shared.addTimerTask(identifier: "PayCheckV", span: 3, repeatCount: checkTimes, delegate: self, executeRightNow: false);
    }
    
    
    //定时器调用
    func timeTaskCalled(identifier: String) {
        if orderNo != nil {
            delegate?.requestOrderPayResult(orderNo: orderNo, first: false);
        }
    }
    
    
    //定时器调用次数调用
    func timeCallTimes(times: Int, identifier: String) {
        if times >= checkTimes {
            leftBtn.isHidden = false;
            rightBtn.isHidden = false;
            animateV.stopLoadingAnimate()
            animateV.isHidden = true;
            statusL.text = "没有查询到结果，若已支付，支付金额将原路返回给您";
            leftBtn.setTitle("取消", for: .normal);
            rightBtn.setTitle("刷新", for: .normal);
        }
    }
    
    
    //构建界面
    private func buildSubViews(){
        self.backgroundColor = UIColor.clear;
        if markV == nil {
           
            markV = UIView()
            markV.backgroundColor = UIColor.colorHexValue("000000", alpha: 0.5);
            //容器视图
            containV = UIView()
            containV.backgroundColor = UIColor.white;
            markV.addSubview(containV);
            //关闭按钮
            let closeBtn = UIButton()
            closeBtn.setImage(UIImage.name("navi_close_ex"), for: .normal);
            closeBtn.addTarget(self, action: #selector(dismissFromSuper), for: .touchUpInside);
            containV.addSubview(closeBtn);
            //中间图片，没有结果的时候显示
            errorImagV = UIImageView()
            errorImagV.image = UIImage.name("icon_attention");
            containV.addSubview(errorImagV);
            //状态文字
            statusL = UILabel()
            statusL.font = kFont(16);
            statusL.textColor = UIColor.colorHexValue("000000", alpha: 0.87);
            statusL.text = "您是否已完成支付";
            statusL.numberOfLines = 2;
            statusL.textAlignment = .center;
            containV.addSubview(statusL);
            //左按钮
            leftBtn = UIButton()
            leftBtn.setTitle("未支付", for: .normal);
            leftBtn.titleLabel?.font = kFont(16);
            leftBtn.setTitleColor(UIColor.colorHexValue("000000", alpha: 0.87), for: .normal);
            leftBtn.layer.cornerRadius = 3;
            leftBtn.layer.borderWidth = 0.5;
            leftBtn.layer.borderColor = UIColor.colorHexValue("000000", alpha: 0.38).cgColor;
            leftBtn.layer.masksToBounds = true;
            leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside);
            containV.addSubview(leftBtn);
            //右按钮
            rightBtn = UIButton()
            rightBtn.setTitle("已支付", for: .normal);
            rightBtn.titleLabel?.font = kFont(16);
            rightBtn.setTitleColor(UIColor.colorHexValue("000000", alpha: 0.87), for: .normal);
            rightBtn.layer.cornerRadius = 3;
            rightBtn.layer.borderWidth = 0.5;
            rightBtn.layer.borderColor = UIColor.colorHexValue("000000", alpha: 0.38).cgColor;
            rightBtn.layer.masksToBounds = true;
            rightBtn.addTarget(self, action: #selector(containueQuery), for: .touchUpInside);
            containV.addSubview(rightBtn);
            //动画
            animateV = QueryCircleAnimateV()
            containV.addSubview(animateV);
            animateV.isHidden = true;
            animateV.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.containV);
                maker?.top.mas_equalTo()(self.containV)?.offset()(92);
                maker?.width.height()?.mas_equalTo()(60);
            }
            containV.mas_makeConstraints { (maker) in
                maker?.left.bottom().right().mas_equalTo()(self.markV);
                maker?.height.mas_equalTo()(440);
            }
            closeBtn.mas_makeConstraints { (maker) in
                maker?.top.right().mas_equalTo()(self.containV);
                maker?.width.height()?.mas_equalTo()(40);
            }
            errorImagV.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.containV);
                maker?.top.mas_equalTo()(self.containV)?.offset()(92);
                maker?.width.height()?.mas_equalTo()(60);
            }
            statusL.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.containV);
                maker?.top.mas_equalTo()(self.errorImagV.mas_bottom)?.offset()(30);
                maker?.width.mas_equalTo()(255);
            }
            
            let center = UIView()
            center.backgroundColor = containV.backgroundColor;
            containV.addSubview(center);
            center.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.containV);
                maker?.height.mas_equalTo()(40);
                maker?.width.mas_equalTo()(1);
                maker?.top.mas_equalTo()(self.statusL.mas_bottom)?.offset()(30);
            }
            leftBtn.mas_makeConstraints { (maker) in
                maker?.top.mas_equalTo()(center);
                maker?.right.mas_equalTo()(center)?.offset()(-10);
                maker?.width.mas_equalTo()(104);
                maker?.height.mas_equalTo()(center);
            }
            rightBtn.mas_makeConstraints { (maker) in
                maker?.top.width()?.height()?.mas_equalTo()(self.leftBtn);
                maker?.left.mas_equalTo()(center)?.offset()(10);
            }
        }else{
            //恢复状态
            errorImagV.isHidden = false;
            statusL.text = "您是否已完成支付";
            leftBtn.isHidden = false;
            leftBtn.setTitle("未支付", for: .normal);
            rightBtn.isHidden = false;
            rightBtn.setTitle("已支付", for: .normal);
            self.containV.alpha = 1;
            containV.mas_makeConstraints { (maker) in
                maker?.left.bottom().right().mas_equalTo()(self.markV);
                maker?.height.mas_equalTo()(440);
            }
        }
    }
    

}
