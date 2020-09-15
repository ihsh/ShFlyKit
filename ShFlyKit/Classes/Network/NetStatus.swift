//
//  SHNetStatus.swift
//  SHLibrary
//
//  Created by 黄少辉 on 2018/3/20.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit
import AFNetworking


///联网方式
enum ConnectMethod {
    case Wifi,        //WIFI
         HotPoint,    //热点-要省流量
         Via4G,       //蜂窝移动网络4G
         Lower4G,     //4G之前的模式 3G,2G
         UnKnow       //网络未知
}


///网络状况收集类
class NetStatus: NSObject,HeatBeatTimerDelegate{
    ///MARK
    static let shareInstance = NetStatus.init()                           //单例，缓存数据
    private var afNetManager = AFNetworkReachabilityManager.shared()        //AFNetworking
    //当前连接方式
    public var method:ConnectMethod = ConnectMethod.UnKnow                  //默认未知
    public var span:TimeInterval = 0                                        //调用间隔
    
    //当前系统信息
    public var deviceInfo = DeviceInfo()                                    //只需要初始化
    //当前app信息
    public var appInfo = AppInfo()                                          //只需要初始化
    //权限信息
    public var permissionInfo = PermissionInfo()                            //需要收集时收集一下
    //网络状况模型
    public var pingInfo = PingInfo()                                        //策略间隔收集
    //动态信息
    public var dynamicInfo = DynamicInfo()                                  //固定收集
    
    
    
    ///MARK-Interface
    //开始监控
    public func startMonitor()->Void{
        HeatBeatTimer.shared.addTimerTask(identifier: "checkNetQuantity", span: 10,repeatCount: 0, delegate: self);
        HeatBeatTimer.shared.addTimerTask(identifier: "dynamic", span: 60, repeatCount: 0, delegate: self);
        //添加网络监控
        afNetManager.startMonitoring()
        //网络状况发生变化
        afNetManager .setReachabilityStatusChange { (status) in
            switch status{
            case AFNetworkReachabilityStatus.notReachable, AFNetworkReachabilityStatus.unknown:
                self.method = ConnectMethod.UnKnow
                break
            case AFNetworkReachabilityStatus.reachableViaWiFi:
                self.method = ConnectMethod.Wifi
                break
            case AFNetworkReachabilityStatus.reachableViaWWAN:
//                let type = SystemInfo.getCellularType();
//                self.method = (type >= 10) ? ConnectMethod.Via4G : ConnectMethod.Lower4G
                break;
            }
            self.dynamicInfo.checkDynamicInfo();
        }
    }
    
    
    
    //停止监控
    public func stopMonitor()->Void{
        HeatBeatTimer.shared.cancelTaskForKey(taskKey: "checkNetQuantity");
        HeatBeatTimer.shared.cancelTaskForKey(taskKey: "dynamic");
        afNetManager.stopMonitoring();
    }
    

    
    ///MARK-HeatBeatTimerDelegate
    func timeTaskCalled(identifier: String) {
        //获取新的ping值，查看网络状况
        if identifier == "checkNetQuantity" {
            pingInfo.updatePingTime();
        }else if identifier == "dynamic"{
            dynamicInfo.checkDynamicInfo();
        }
    }
    

    
    //收集网络信息
    public func generateNetInfo()->String{
        let mulDict = NSMutableDictionary()
        mulDict.setValue(pingInfo.averagePingTime, forKey: "averagePingTime");
        mulDict.setValue(pingInfo.lastPingInterval, forKey: "lastPingInterval");
        mulDict.setValue(pingInfo.quality.rawValue, forKey: "quality");
        return dictToJsonString(dict: mulDict);
    }
    

    class public func nameOfWindowViewController()->String{
        var name = "";
        let window = UIApplication.shared.delegate?.window;
        let root = window!?.rootViewController
        if root is UINavigationController {
            let nav:UINavigationController = root as! UINavigationController
            let vc = nav.viewControllers.last;
            if vc != nil{
                name = type(of: vc!).description();
            }
        }else if root is UITabBarController{
            let tab:UITabBarController = root as! UITabBarController
            let vcs:[UIViewController] = tab.viewControllers!;
            let vc:UIViewController = vcs[tab.selectedIndex];
            name = type(of: vc).description();
        }
        return name;
    }
    

    //字典转json字符串
    private func dictToJsonString(dict:NSDictionary)->String{
        let data:Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        var param:String = "";
        if data != nil {
            param = String.init(data: data! , encoding: String.Encoding.utf8)!
        }
        return param
    }

    
}

