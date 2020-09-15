//
//  DiaLogConfig.swift
//  SHKit
//
//  Created by hsh on 2020/1/11.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//代理实现协议-自定义的UIView
protocol DiaLogConfigDelegate:NSObjectProtocol {
    //实现自定义视图的初始化
    func initWithConfig(_ config:DiaLogConfig)
    //已经添加到视图上
    func didAddSubviews(superV:UIView)
    
}


//弹窗处理回调
typealias DialogActionHandler = ((_ action:String)->Void)


//类型
enum DiaLogType {
    case System,ActionSheet,Toust,Custom
}


//弹框的配置
class DiaLogConfig:NSObject{
    //Variable
    public var type:DiaLogType = .System                //弹窗类型
    public var delegate:DiaLogConfigDelegate?           //自定义视图作为代理，实现视图的初始化方法
    public var title:String?                            //标题
    public var msg:String?                              //内容
    public var backColor:UIColor = UIColor.colorHexValue("000000", alpha: 0.3)  //背景颜色
    public var containColor:UIColor = .white            //内容视图颜色
    public var viewCorneradius:CGFloat = 5              //视图的圆角值
    public var btnsCorneradius:CGFloat = 5              //按钮的圆角值
    //点击
    public var comfirmAction:DiaLogAction!              //确认点击
    public var cancelAction:DiaLogAction!               //取消点击
    public var otherActions:[DiaLogAction] = []         //其他操作配置
    //其他信息
    public var touchDismiss:Bool = false                //点击背景是否消失
    public var extras:[String:Any] = [:]                //其余额外信息
    
    
    class func initConfig(title:String?,msg:String?,type:DiaLogType,delegateView:DiaLogConfigDelegate?,
                          comfirm:DiaLogAction,cancel:DiaLogAction)->DiaLogConfig{
        let config = DiaLogConfig()
        config.title = title;
        config.msg = msg;
        config.type = type;
        
        if type == .Toust && delegateView == nil{
            config.delegate = DiaLogToustView()
        }else{
            config.delegate = delegateView;
        }
        config.comfirmAction = comfirm;
        config.cancelAction = cancel;
        return config;
    }
    
}


//弹框Action
class DiaLogAction: NSObject {
    public var action:DialogActionHandler?      //处理回调
    public var title:String!                    //按钮的标题
    public var destructive:Bool = false         //是否是破坏性的
    public var textColor:UIColor!               //文本颜色
    public var backColor:UIColor!               //背景颜色
    public var font:UIFont = kFont(14)
    
    
    class func initAction(_ title:String,action:@escaping DialogActionHandler,
                          destructive:Bool = false)->DiaLogAction{
        let act = DiaLogAction()
        act.action = action;
        act.title = title;
        act.destructive = destructive;
        //默认配色
        if title == "取消" {
            act.textColor = .black;
            act.backColor = .white;
        }else{
            act.textColor = .white;
            act.backColor = UIColor.colorRGB(red: 57, green: 153, blue: 154);
        }
        return act;
    }
    
    
}



