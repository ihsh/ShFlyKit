//
//  DiaLog.swift
//  SHKit
//
//  Created by hsh on 2020/1/10.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


///弹框
class DiaLog: UIView,HeatBeatTimerDelegate {

    
    ///Interface
    class public func showAlert(_ config:DiaLogConfig){
        
        switch config.type {
        case .Toust,.Custom:
            
            if config.delegate != nil {
                let window:UIWindow = (UIApplication.shared.delegate?.window!!)!;
                //代理视图
                config.delegate?.initWithConfig(config);
                let view:UIView = config.delegate as! UIView;
                window.addSubview(view);
                //添加到视图事件
                config.delegate?.didAddSubviews(superV: window);
            }
        case .System:
            systemAlert(title: config.title, msg: config.msg, actionSheet: false,
                        comfirm: config.comfirmAction, cancel: config.cancelAction, others: config.otherActions);
        case .ActionSheet:
            systemAlert(title: config.title, msg: config.msg, actionSheet: true,
                         comfirm: config.comfirmAction, cancel: config.cancelAction, others: config.otherActions);
        }
    }
    

    
    //系统样式弹框/ActionSheet
    class public func systemAlert(title:String?,msg:String?,actionSheet:Bool,
                            comfirm:DiaLogAction,cancel:DiaLogAction,others:[DiaLogAction] = []){
        
        let alertVC = UIAlertController.init(title: title, message: msg, preferredStyle: actionSheet ? .actionSheet : .alert);
        let comAction = UIAlertAction.init(title: comfirm.title, style: comfirm.destructive ? .destructive : .default) { (action) in
            comfirm.action?(comfirm.title)
        }
        let noAction = UIAlertAction.init(title: cancel.title, style: .cancel, handler: nil);
        alertVC.addAction(comAction);
        alertVC.addAction(noAction);
        //其他的操作
        for item in others{
            let action = UIAlertAction.init(title: item.title, style: item.destructive ? .destructive : .default) { (action) in
                item.action?(item.title);
            }
            alertVC.addAction(action);
        }
        let vc:UIViewController = (UIApplication.shared.delegate?.window?!.rootViewController)!;
        vc.present(alertVC, animated: true, completion: nil);
    }
  
    
    
}





