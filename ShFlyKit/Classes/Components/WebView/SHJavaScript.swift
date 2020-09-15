//
//  SHJavaScript.swift
//  SHKit
//
//  Created by hsh on 2019/6/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import WebKit

//全局搜索#web#,与web相关的点

//JS调用OC
typealias jsHandler = ((_ jsObj:NSDictionary)->Void)


//消息处理中心
class SHJavaScript: NSObject , WKScriptMessageHandler{
    //Variable
    public var scriptHandleName:String = "app"          //WKScriptMessageHandler中ABC位置的字符串，网页端需要对应#web#
    private var jsHandler:jsHandler?                    //JS的d回调
    
    
    //设置JS的回调
    public func setJSHandler(_ handler:@escaping jsHandler){
        jsHandler = handler;
    }
    
    
    //WKScriptMessageHandler -- window.webkit.messageHandlers.ABC.postMessage("xxx");#web#
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == scriptHandleName) {
            callApp(message: message.body as AnyObject);
        }
    }
    
    
    //处理数据
    private func callApp(message:AnyObject){
        var json:NSDictionary = NSDictionary();
        if (message.isKind(of: NSDictionary.self)) {
            json = message as! NSDictionary;
        }else{
            let str:String? = message as? String;
            let data:Data? = str?.data(using: .utf8);
            if data != nil{
                do {
                    try json = JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary;
                } catch {}
            }
        }
        jsHandler?(json);   //数据传回block中
    }
    
    
}
