//
//  JiYanBaseVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/15.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import GT3Captcha


//使用极验的基础控制器
open class JiYanBaseVC: UIViewController,GT3CaptchaManagerDelegate,GT3CaptchaButtonDelegate {
    //Variable
    public var manager:GT3CaptchaManager?
    public var captchBtn:GT3CaptchaButton!              //极验的按钮
    
    
    open override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white;
    }
    
    
    //极验的初始化
    public func configInit(api1:String,api2:String,timeOut:TimeInterval,maskColor:UIColor){
        manager = GT3CaptchaManager.init(api1: api1, api2: api2, timeout: timeOut);
        manager?.delegate = self;
        manager?.maskColor = maskColor;
        //需要的话自行添加设置位置
        captchBtn = GT3CaptchaButton.init(frame: CGRect.zero, captchaManager: manager);
        captchBtn.startCaptcha();
    }
    
    
    //开始检验
    public func startCaptcha(){
        manager?.startGTCaptchaWith(animated: true);
    }

    
    ///Delegate
    public func gtCaptcha(_ manager: GT3CaptchaManager!, errorHandler error: GT3Error!) {
        if (error.code == -999) {
            // 请求被意外中断, 一般由用户进行取消操作导致, 可忽略错误
        }else if (error.code == -10) {
            // 预判断时被封禁, 不会再进行图形验证
        }else if (error.code == -20) {
            // 尝试过多
        }else {
            // 网络问题或解析失败, 更多错误码参考开发文档
        }
    }

    
    public func gtCaptcha(_ manager: GT3CaptchaManager!, didReceiveSecondaryCaptchaData data: Data!, response: URLResponse!, error: GT3Error!, decisionHandler: ((GT3SecondaryCaptchaPolicy) -> Void)!) {
        decisionHandler(.allow)
    }
    
    
    func captchaButtonShouldBeginTapAction(_ button: GT3CaptchaButton!) -> Bool {
        return true;
    }
   

}
