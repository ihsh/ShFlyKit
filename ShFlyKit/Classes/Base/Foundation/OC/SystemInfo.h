//
//  SystemInfo.h
//  SHKit
//
//  Created by 黄少辉 on 2018/3/21.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>


@interface SystemInfo : NSObject

//流量统计
+(NSDictionary*)netDataCounters;

//总内存大小
+(double)totalMemorySize;
//当前使用容量
+(double)taskUsedMemory;

//cpu使用率
+(double)cpuUsedPersentage;

//电池电量
+(double)getBatteryQuantity;
//充电状态
+(UIDeviceBatteryState)stateOfBattery;
//是否低电量模式
+(BOOL)lowPowerModeEnable;

//剩余可用磁盘容量
+(NSDictionary*)diskInfo;
//系统启动时间
+(NSDate *)systemStartTime;
//系统运行时间
+(NSString*)runningTime;

//运营商名称
+(NSDictionary*)carrierInfo;
//移动网络类型
+(NSString *)getNetType;
//获取IP地址
+(NSString *)deviceIPAdress;
//获取移动网络IP
+(NSString*)deviceCellularIP;
//网络是否可达,获取ping值
+(double)pingSecForRemote;
//全局的网速
+(long long)getInterfaceBytes;


//app显示名称
+(NSString*)appDisplayName;
//设备名称
+(NSString*)deviceName;
//当前所在地语言
+(NSString*)localLanguage;
//当前所在地信息
+(NSString*)localDisplayName;
//系统语言
+(NSString*)systemLanguage;
//系统版本
+(NSString*)systemVersion;
//bundleIdentifier
+(NSString*)appBundleID;
//版本号 example: 1.0.2
+(NSString*)appVersion;
//构建号 example: 1002
+(NSString*)appBuild;

@end








///权限检测
@interface AuthorityInfo : NSObject
///网络权限
+(BOOL)networkAuthorised;
///检测定位权限
+(BOOL)checkLocationPermissions;
///检测麦克风权限
+(BOOL)checkMicroPermissions;
///检测照相机权限
+(BOOL)checkCameraPermissions;
///检测相册权限
+(BOOL)checkPhotoLibraryPermissions;
///检测联系人权限
+(BOOL)checkContactsPermissions;
///检测蓝牙权限
+(BOOL)checkBluetoothPermissions;
///检测日历/备忘录权限
+(BOOL)checkEventServicePermissions:(EKEntityType)entityType;
///检测健康权限
+(BOOL)checkHealthPermission;
///检测touch/faceID权限
+(BOOL)checkTouchOrFaceIDPermission;
///检测applePay权限
+(BOOL)checkApplePayPermission;
///推送权限
+(BOOL)pushNotifactionAuthorised;
///通讯录权限
+(BOOL)addressBookAuthorised;

@end



