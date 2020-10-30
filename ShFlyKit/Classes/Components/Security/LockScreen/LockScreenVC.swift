//
//  LockScreenV.swift
//  SHKit
//
//  Created by hsh on 2019/8/12.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//当前类型--设置或解锁
public enum LockScreenType{
    case Setting,Unlock
}


//代理
public protocol LockScreenDelegate:NSObjectProtocol{
    ///设置密码
    func lockScreenDidFinishSetPassword(pwd:String)
    func lockScreenCancelSetting()
    ///解锁密码
    func unlockScreenResult(pwd:String)     //绘制好的密码文传出
    func failUnlockWithMaxTry()             //最大次数错误
    func forgotPassWord()                   //忘记密码
    func useBiometry()                      //使用指纹识别
    func userHeadp()->UIImage?              //返回用户的头像
}


//图案解锁类
public class LockScreenVC: UIViewController , PassWordDeleagate {
    // MARK: - Variale
    public weak var lockDelegate:LockScreenDelegate?
    public var viewType:LockScreenType = .Unlock
    public var maxRetryCount:Int = 5                            //最大允许解锁重试次数
    //颜色
    public var backColor = UIColor.white                        //整体的背景色
    public var textColor:UIColor!                               //文字的颜色
    public var normalColor = UIColor.colorRGB(red: 135, green: 136, blue: 138)      //正常的颜色
    public var highlightColor = UIColor.colorRGB(red: 76, green: 143, blue: 223)    //高亮的颜色
    public var errorColor = UIColor.colorRGB(red: 236, green: 52, blue: 52)         //错误的颜色
    //通用
    private var titleL:UILabel!                                 //标题
    private var tipsL:UILabel!                                  //提示语
    private var passWordView:LockPasswordView!                  //密码设置图
    private var isHiddenBar:Bool = false                        //导航栏是否隐藏
    //仅设置
    private var setPwd:String?                                  //设置密码的第一遍密码
    private var thumbV:LockDotThumbV?                           //实时路径小图
    private var resetBtn:UIButton!                              //重置按钮
    private var jumpToBtn:UIButton!                             //跳过按钮
    //仅解锁
    private var retryCount:Int = 0                              //解锁重试次数
    private var headerImageView:UIImageView!                    //头像
    private var forgtBtn:UIButton!                              //忘记密码
    private var useBiometryBtn:UIButton!                        //使用指纹，面容解锁
    
    
    
    ///Mark
    public override func viewDidLoad() {
        //背景色
        self.view.backgroundColor = backColor;
        //密码设置图
        passWordView = LockPasswordView()
        passWordView.normalColor = normalColor;
        passWordView.highlightedColor = highlightColor;
        passWordView.errorColor = errorColor;
        passWordView.delegate = self;
        self.view.addSubview(passWordView);
        passWordView.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.view);
            maker?.centerY.mas_equalTo()(self.view)?.offset()(viewType == .Setting ? 60 : 20);
            maker?.width.mas_equalTo()(ScreenSize().width);
            maker?.height.mas_equalTo()(290);
        }
        if textColor == nil {
            textColor = backColor == UIColor.white ? UIColor.colorHexValue("4A4A4A") : UIColor.white;
        }
        //提示label
        tipsL = UILabel.initText(nil, font: kFont(14), textColor:textColor, alignment: .center, super: self.view);
        tipsL.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(passWordView.mas_top)?.offset()(-30);
            maker?.centerX.mas_equalTo()(self.view);
        }
        titleL = UILabel.initText("设置手势密码", font: kMediumFont(14), textColor: textColor, alignment: .center, super: self.view);
        titleL.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(self.view)?.offset()(StatusBarHeight() + 20);
        }
        if viewType == .Unlock {
            tipsL.text = "绘制图案解锁";
            titleL.text = "手势密码";
            
            let line = UIView()
            line.backgroundColor = textColor;
            self.view.addSubview(line);
            line.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.view);
                maker?.height.mas_equalTo()(20);
                maker?.width.mas_equalTo()(0.5);
                maker?.top.mas_equalTo()(passWordView.mas_bottom)?.offset()(40);
            }
            forgtBtn = UIButton.initTitle("忘记密码", textColor: textColor, back: backColor, font: kFont(12), super: self.view);
            forgtBtn.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside);
            forgtBtn.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(line);
                maker?.left.mas_equalTo()(line)?.offset()(6);
                maker?.width.mas_equalTo()(60);
                maker?.height.mas_equalTo()(40);
            }
            useBiometryBtn = UIButton.initTitle("指纹识别", textColor: textColor, back: backColor, font: kFont(12), super: self.view);
            useBiometryBtn.addTarget(self, action: #selector(useBiometry), for: .touchUpInside);
            useBiometryBtn.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(line);
                maker?.right.mas_equalTo()(line)?.offset()(-6);
                maker?.width.height().mas_equalTo()(forgtBtn);
            }
            //头像
            headerImageView = UIImageView()
            self.view.addSubview(headerImageView);
            headerImageView.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.view);
                maker?.width.height()?.mas_equalTo()(70);
                maker?.bottom.mas_equalTo()(passWordView.mas_top)?.offset()(-60);
            }
            headerImageView.layer.cornerRadius = 35;
            headerImageView.layer.masksToBounds = true;
            headerImageView.image = lockDelegate?.userHeadp();
        }else{
            //设置密码的UI
            resetBtn = UIButton.initTitle("重置", textColor: textColor, back: backColor, font: kFont(14), super: self.view);
            resetBtn.addTarget(self, action: #selector(resetSetPwd), for: .touchUpInside);
            resetBtn.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(titleL);
                maker?.left.mas_equalTo()(self.view)?.offset()(16);
                maker?.height.mas_equalTo()(35);
                maker?.width.mas_equalTo()(60);
            }
            jumpToBtn = UIButton.initTitle("跳过", textColor: textColor, back: backColor, font: kFont(14), super: self.view);
            jumpToBtn.addTarget(self, action: #selector(cancelSetting), for: .touchUpInside);
            jumpToBtn.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(titleL);
                maker?.right.mas_equalTo()(self.view)?.offset()(-16);
                maker?.width.height()?.mas_equalTo()(resetBtn);
            }
            thumbV = LockDotThumbV()
            thumbV?.backgroundColor = backColor;
            self.view.addSubview(thumbV!);
            thumbV?.norColor = normalColor;
            thumbV?.hightColor = highlightColor;
            thumbV?.mas_makeConstraints { (maker) in
                maker?.centerX.mas_equalTo()(self.view);
                maker?.width.height()?.mas_equalTo()(70);
                maker?.bottom.mas_equalTo()(passWordView.mas_top)?.offset()(-60);
            }
        }
        
    }
    
    
    //解锁的结果
    public func lockResult(_ suc:Bool){
        passWordView.checkResult(isError: suc == false)
        //解锁模式
        if suc == false || viewType == .Unlock{
            retryCount += 1;
            if maxRetryCount - retryCount > 0 {
                tipsL.text = String(format: "密码错误,还有%ld次重试机会", maxRetryCount - retryCount);
            }else{
                tipsL.text = nil;
            }
            if retryCount >= maxRetryCount{
                passWordView.forbid = true;
                passWordView.resetTrackingState();
            }
        }
    }
    
    
    
    ///PassWordDeleagate
    public func passWordDidEndInput(pwd: String) {
        if viewType == .Unlock{
            lockDelegate?.unlockScreenResult(pwd: pwd);
        }else{
            //第一次设置密码，保存第一次的结果
            if setPwd == nil{
                setPwd = pwd;
                tipsL.text = "再次绘制图案";
                passWordView.resetTrackingState();
            }else{
                //两次相同，设置成功，传出保存
                if setPwd == pwd{
                    tipsL.text = nil;
                    lockDelegate?.lockScreenDidFinishSetPassword(pwd: pwd);
                }else{
                    //两次密码不用，下一次操作室重新设置
                    tipsL.text = "两次绘制的密码不同"
                    passWordView.checkResult(isError: true);
                    let impact = UIImpactFeedbackGenerator.init(style: .heavy);
                    impact.impactOccurred();
                    setPwd = nil;
                }
            }
        }
    }
    
    
    //设置中，字符在变化
    public func passWordDidChange(pwd: String) {
        tipsL.text = nil;
        if pwd.count == 1 && viewType == .Setting{
            thumbV?.resetIndex();
        }
        if viewType == .Setting{
            if setPwd != nil{
                //两次密码设置不同
                if (setPwd?.contains(pwd))! == false{
                    tipsL.text = "两次绘制的密码不同"
                    passWordView.checkResult(isError: true)
                }
            }
        }
    }
    
    
    public func passWordDidChangeIndex(index: Int, select: Bool) {
        thumbV?.setIndexes(index: index, select: select);
    }
    
    
    ///Private
    //重新设置密码
    @objc private func resetSetPwd(){
        setPwd = nil;
        passWordView.resetTrackingState();
        thumbV?.resetIndex();
        tipsL.text = nil;
    }
    
    
    //跳过设置
    @objc private func cancelSetting(){
        lockDelegate?.lockScreenCancelSetting();
    }
    
    
    //忘记密码
    @objc private func forgotPassword(){
        lockDelegate?.forgotPassWord();
    }
    
    
    //指纹识别
    @objc private func useBiometry(){
        lockDelegate?.useBiometry();
    }
    
    
    ///进来隐藏导航条，出去再显示
    public override func viewWillAppear(_ animated: Bool) {
        isHiddenBar = self.navigationController!.isNavigationBarHidden;
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }
    
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(isHiddenBar, animated: true);
    }
    
    
}
