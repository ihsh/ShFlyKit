//
//  SecurityCheck.swift
//  SHKit
//
//  Created by hsh on 2018/10/23.
//  Copyright © 2018 hsh. All rights reserved.
//


import UIKit
import LocalAuthentication


///检查的结果
public protocol SecurityDelegate {
    func securityCheckResult(result:Bool,msg:String?)
}


//检查类型
public enum CheckType{
    case Biometry,              //生物识别-面容/指纹
         Pattern,               //图案解锁
         PatternSet             //设置图形锁
}



//安全验证类
public class SecurityCheck: NSObject {
    // MARK: - Variable
    public var holdVC:UIViewController?                     //承载的控制器
    public var biometryTip:String = "需要验证您的身份"
    private var lockVC:LockScreenVC!                        //图形锁的控制器
    
    
    // MARK: - Interface
    //开始检查
    public func checkWithType(type:CheckType,delegate:AnyObject){
        switch type {
        case .Biometry:
            self.biometryCheck(delegate: delegate)
        case .Pattern:
            self.patternCheck(delegate: delegate)
        case .PatternSet:
            self.patternSet(delegate: delegate)
        }
    }
    
    
    //检查的结果反馈
    public func checkResult(type:CheckType,suc:Bool){
        if type == .Pattern {
            if suc {
                holdVC?.navigationController?.popViewController(animated: false);
            }else{
                lockVC.lockResult(suc);
            }
        }
    }
    
    
    //视图消失
    public func dismiss(type:CheckType){
        DispatchQueue.main.async {
            switch type {
            case .Pattern:
                self.holdVC?.navigationController?.popViewController(animated: false);
            default:break;
            }
        }
    }
    
    
    // MARK: - Private Method
    //生物识别
    private func biometryCheck(delegate:AnyObject)->Void{
        //子方法
        func checkWithContext(_ authContext:LAContext){
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: biometryTip) {success, error in
                if (error != nil){
                    let authError:LAError = error as! LAError
                    let msg = SecurityCheck.errorMsg(error: authError)
                    (delegate as? SecurityDelegate)?.securityCheckResult(result: success,msg: msg)
                }else{
                    (delegate as? SecurityDelegate)?.securityCheckResult(result: success,msg: nil)
                }
            }
        }
        //生物解锁
        let authContext = LAContext()
        var authError:NSError?
        let isAvailable = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
        if (authError != nil){
            (delegate as? SecurityDelegate)?.securityCheckResult(result: false, msg: SecurityCheck.errorMsg(error: authError as! LAError));
        }else{
            if isAvailable{
                if #available(iOS 11.0, *){
                    switch (authContext.biometryType){
                    case LABiometryType.none:
                        (delegate as? SecurityDelegate)?.securityCheckResult(result: false, msg: "设备不支持");
                    case LABiometryType.touchID,LABiometryType.faceID:
                        checkWithContext(authContext);
                    }
                }else{
                     checkWithContext(authContext);
                }
            }else{
                (delegate as? SecurityDelegate)?.securityCheckResult(result: false, msg: "当前不可用")
            }
        }
    }
    

    //图案验证
    private func patternCheck(delegate:AnyObject)->Void{
        lockVC = LockScreenVC()
        lockVC.viewType = .Unlock;
        lockVC.lockDelegate = delegate as? LockScreenDelegate;
        holdVC?.navigationController?.pushViewController(lockVC, animated: true);
    }
    
    
    //机器检查
    private func patternSet(delegate:AnyObject)->Void{
        lockVC = LockScreenVC()
        lockVC.viewType = .Setting;
        lockVC.lockDelegate = delegate as? LockScreenDelegate;
        holdVC?.navigationController?.pushViewController(lockVC, animated: true);
    }
    
    
    //错误码对应的信息
    class private func errorMsg(error:LAError)->String{
        var msg = ""
        switch error.code {
        case .authenticationFailed:
            msg = "验证失败"
        case .userCancel:
            msg = "用户取消了"
        case .userFallback:
            msg = "用户选择输入密码"
        case .systemCancel:
            msg = "系统取消操作" //例如app进入前台
        case .passcodeNotSet:
            msg = "密码未设置"
        case .touchIDLockout:
            msg = "指纹已锁定"
        case .touchIDNotEnrolled:
            msg = "指纹未设置"
        case .touchIDNotAvailable:
            msg = "指纹识别不可用"
        case .appCancel:
            msg = "应用取消验证"
        case .invalidContext:
            msg = "上下文不可用"
        case .notInteractive:
            msg = "交互不可用"
        default:
            msg = "未知"
        }
        return msg
    }
    
    
}
