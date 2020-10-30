//
//  NetCommonObj.swift
//  SHKit
//
//  Created by hsh on 2019/1/28.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import CoreTelephony
import SystemConfiguration
import AVFoundation


///设备信息 -- 不变
public class DeviceInfo:NSObject{
    //设备名称
    public let deviceName = SystemInfo.deviceName()
    //手机系统版本
    public let iosVersion = UIDevice.current.systemVersion
    //UUID
    public let uuid = (UIDevice.current.identifierForVendor?.uuidString)!
}


///应用的信息 -- 不变
public class AppInfo:NSObject{
    //当前应用版本
    public let version = SystemInfo.appVersion()
    //当前应用名称
    public let name = SystemInfo.appDisplayName()
    //build版本
    public let build = SystemInfo.appBuild()
    //bundleIdentifier
    public let bundleIdentifier = SystemInfo.appBundleID()
}


///设备UI信息
public class UIInfo:NSObject{
    //屏幕宽
    public let screenWidth = UIScreen.main.bounds.size.width
    //屏幕高
    public let screenHeight = UIScreen.main.bounds.size.height
}


///权限信息
public class PermissionInfo:NSObject{
    //定位许可
    public var locationAccess:Bool = false
    //通讯录许可
    public var addressBookAccess:Bool = false
    //日历
    public var calendarAccess:Bool = false
    //照片
    public var phoneAssetAccess:Bool = false
    //蓝牙
    public var bluetoothAccess:Bool = false
    //麦克风
    public var microAccess:Bool = false
    //照相机
    public var cameraAccess:Bool = false
    //健康
    public var healthDataAccess:Bool = false
    //applePay许可
    public var applePayPermit:Bool = false
    //备忘录许可
    public var memoPermit:Bool = false
    //TouchID/FaceID
    public var touchFaceID:Bool = false
    //应用的通知是否打开
    public var appAllowNotife:Bool = false
    
    //权限检查
    public func checkPrioritys()->Void{
        //定位权限
        locationAccess = AuthorityInfo.checkLocationPermissions()
        //通讯录许可
        addressBookAccess = AuthorityInfo.checkContactsPermissions()
        //日历
        calendarAccess = AuthorityInfo.checkEventServicePermissions(EKEntityType.event);
        //照片
        phoneAssetAccess = AuthorityInfo.checkPhotoLibraryPermissions()
        //蓝牙
        bluetoothAccess = AuthorityInfo.checkBluetoothPermissions()
        //麦克风
        microAccess = AuthorityInfo.checkMicroPermissions()
        //照相机
        cameraAccess = AuthorityInfo.checkCameraPermissions()
        //健康
        healthDataAccess = AuthorityInfo.checkHealthPermission()
        //applePay许可
        applePayPermit = AuthorityInfo.checkApplePayPermission()
        //备忘录许可
        memoPermit = AuthorityInfo.checkEventServicePermissions(EKEntityType.reminder)
        //TouchID/FaceID
        touchFaceID = AuthorityInfo.checkTouchOrFaceIDPermission()
    }
}



///设备动态的信息
public class DynamicInfo:NSObject{//从不变到变化越快的
    //手机总内存
    public var memoryTotal:Double = 0.0
    //运营商
    public var carrierName:String = ""
    //系统语言
    public var sysLanguage = ""
    //ip地址
    public var ipAddress:String = ""
    //wifi名称
    public var wifiName:String = ""
    //电池电量
    public var battery:Double = 0.0
    //充电状态
    public var batteryState:UIDeviceBatteryState = UIDeviceBatteryState.unknown
    //移动的ip地址
    public var deviceCellularIP:String = ""
    //剩余可用磁盘容量比例
    public var leftDiskRate = 0.0
    //系统音量
    public var sysVolume: Double = 0.0
    //屏幕亮度
    public var sysLight: Double = 0.0
    //手机内存剩余
    public var memoryLeft:Double = 0.0
    
    
    //手机动态信息
    public func checkDynamicInfo()->Void{
        //系统音量
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance();
        sysVolume = Double(audioSession.outputVolume);
        //系统亮度
        sysLight = Double(UIScreen.main.brightness)
        //当前设备可用内存
        
        //电池状态
        batteryState = SystemInfo.stateOfBattery()
        //总内存大小
        memoryTotal = SystemInfo.totalMemorySize()
        //剩余可用磁盘容量
//        leftDiskRate = SystemInfo.leftDiskSizeRate()
        //IP地址
        ipAddress = SystemInfo.deviceIPAdress()
        //wifi名称
        
        //系统语言
        let defs = UserDefaults.standard;
        let languages:NSArray = defs.object(forKey: "AppleLanguages") as! NSArray;
        sysLanguage = languages.object(at: 0) as! String//集合第一个元素为当前语言
        //电池电量
        battery = SystemInfo.getBatteryQuantity()
        //运营商
        let info:CTTelephonyNetworkInfo = CTTelephonyNetworkInfo();
        var carrier:CTCarrier?
        if #available(iOS 12.0, *) {
            carrier = info.serviceSubscriberCellularProviders?.values.first
        } else {
            // Fallback on earlier versions
        };
        let mobileCarrier:String?
        if (carrier != nil) {
            if (!(carrier?.isoCountryCode != nil)) {
                mobileCarrier = "无运营商";
            }else{
                mobileCarrier = carrier?.carrierName;
            }
            carrierName = mobileCarrier!;
        }
        deviceCellularIP = SystemInfo.deviceCellularIP();
    }
    
}



///网络质量
public enum NetQuality:String {
   case best = "好",            //网络快，响应快                       <0.2
        good = "不错",          //网络良好，偶尔延时高                  0.2-1
        poor = "缓慢",          //网络缓慢                            1-2
        unavailable = "不可用"  //没法连接或非常差                      > 2
}



///ping信息
public class PingInfo:NSObject{
    //网络状况-默认网络状况好
    public var quality:NetQuality = NetQuality.good
    ///ping的次数
    public var pingCountNumber:Int = 0
    //上次ping时间
    public var lastPingInterval:Double = 0.0
    //平均ping时间
    public var averagePingTime:Double = 0.0
    
    //比较的结果不同的次数
    private var diffTimes:Int = 0
    
    
    //更新ping值
    public func updatePingTime()->Void{
        let time:Double = SystemInfo.pingSecForRemote();
        //没有响应到ping
        if time >= 100{
            quality = NetQuality.unavailable;
            return;
        }
        //计算网络状况
        func assessment(_ value:Double)->NetQuality{
            var tmpQuality = NetQuality.unavailable;
            //网络状态
            if value < 0.2 {
                tmpQuality = NetQuality.best
            }else if (value < 1){
                tmpQuality = NetQuality.good
            }else if (value < 2){
                tmpQuality = NetQuality.poor
            }else{
                tmpQuality = NetQuality.unavailable
            }
            return tmpQuality
        }
        //最近的ping值
        self.lastPingInterval = time;
        //更新平均值
        var pingSum:Double = self.averagePingTime * Double(self.pingCountNumber);
        pingSum += time;
        //增加一次ping计数
        self.pingCountNumber += 1;
        self.averagePingTime = pingSum / Double(self.pingCountNumber);
        //上一个值和平均值的中间-让变化快一些
        let value = (self.averagePingTime + self.lastPingInterval) / 2.0;
        //当前的ping值评估
        quality = assessment(value);
        let timeQuality = assessment(time);
        if timeQuality != quality {//与之前的比较，2次不同会重置
            diffTimes += 1;
            if diffTimes > 1 {
                reset()
                quality = timeQuality;
            }
        }
    }
    
    
    
    //重置计数
    private func reset()->Void{
        self.pingCountNumber = 0;
        self.lastPingInterval = 0;
        self.averagePingTime = 0;
        self.diffTimes = 0;
    }
    
    
}
