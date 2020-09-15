//
//  BuglyReporter.swift
//  SwiftFrameWork
//
//  Created by 黄少辉 on 2018/2/26.
//  Copyright © 2018年 黄少辉. All rights reserved.
//


import UIKit
/*
 添加依赖库
 SystemConfiguration.framework
 Security.framework
 libz.dylib 或 libz.tbd
 libc++.dylib 或 libc++.tbd
 */

class BuglyReporter: NSObject {

    
    //注册bugly
    class func initBugLyWithAppkey(appKey:String,crashHandle:Bool = true) -> Void {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"];
        let currentDevice:UIDevice = UIDevice.current;
        let deviceID:NSMutableString = NSMutableString.init(string: (currentDevice.identifierForVendor?.uuidString)!);
        
        let config:BuglyConfig = BuglyConfig.init();
        config.version = appVersion as! String;                //自定义版本
        config.channel = "AppStore";                           //自定义渠道名
        config.blockMonitorEnable = true;                      //卡顿监控开关,默认关闭
        config.blockMonitorTimeout = 10;                       //卡顿监控判断间隔，单位秒
        config.crashAbortTimeout = 10;
        config.deviceIdentifier = deviceID as String;          //自定义唯一设备表示
        config.reportLogLevel = .warn;
        Bugly.start(withAppId: appKey, config: config);
        
        //启用崩溃处理类
        if crashHandle == true {
            BuglyReporter.bugCrashHandleEnale()
        }
    }
    
    
    
    //初始化崩溃处理类
    class func bugCrashHandleEnale()->Void{
        //DEBUG下要关掉，可以发现问题
//        CrashHandler.makeEffective()
    }
    
    
}
