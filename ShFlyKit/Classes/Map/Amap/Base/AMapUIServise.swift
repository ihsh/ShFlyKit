//
//  AMapUIServise.swift
//  SHKit
//
//  Created by hsh on 2019/1/15.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


///高德UI设置类
class AMapUIServise: NSObject {
    ///MARK
    static let shareInstance = AMapUIServise.init()
    //单例的地图
    public var mapView = MAMapView()
    
    
    ///MARK-Interface
    //获取地图单例
    class public func getInitialMap()->MAMapView{
        let map = AMapUIServise.shareInstance.mapView;
        map.delegate = nil;
        map.removeOverlays(map.overlays);
        map.removeAnnotations(map.annotations);
        return map;
    }
    
    
    //显示用户位置
    class public func showUserLocation(show:Bool = true,trackMode:MAUserTrackingMode = .follow)->Void{
        AMapUIServise.shareInstance.mapView.showsUserLocation = show;
        AMapUIServise.shareInstance.mapView.userTrackingMode = trackMode;
    }
    
    
    //显示室内地图
    class public func enableIndoorMap(enable:Bool)->Void{
        AMapUIServise.shareInstance.mapView.isShowsIndoorMap = enable;
    }
    
    
    //改变地图图层
    class public func changeMapType(type:MAMapType)->Void{
        AMapUIServise.shareInstance.mapView.mapType = type;
    }
    
    
    //开关交通状况
    class public func enableTraffic(enable:Bool)->Void{
        AMapUIServise.shareInstance.mapView.isShowTraffic = enable;
    }
    
    
    //显示英文地图
    class public func showMapForEnglish(show:Bool)->Void{
        AMapUIServise.shareInstance.mapView.perform(NSSelectorFromString("setMapLanguage:"),
                                                    with: NSNumber.init(value: show ? 1 : 0))
    }
    
    
    //设置路况颜色
    class public func setTrafficColor(dict:[NSNumber:UIColor])->Void{
        AMapUIServise.shareInstance.mapView.trafficStatus = dict;
    }
    
    
    //设置自定义地图样式
    class public func setCustomMapStyle(pathStr:String?,styleID:String?)->Void{
        //创建加载选项
        let options:MAMapCustomStyleOptions = MAMapCustomStyleOptions()
        if styleID != nil{
            //需要购买专业版本才能生效
            options.styleId = styleID;
            AMapUIServise.shareInstance.mapView.setCustomMapStyleOptions(options);
            AMapUIServise.shareInstance.mapView.customMapStyleEnabled = true;
        }else if pathStr != nil {
            //加载离线地图
            var path =  Bundle.main.bundlePath;
            path.append("/");
            path.append(pathStr!);
            let jsonData = NSData.init(contentsOfFile: path)
            if jsonData != nil{
                options.styleData = jsonData! as Data;
                AMapUIServise.shareInstance.mapView.customMapStyleEnabled = true;
                AMapUIServise.shareInstance.mapView.setCustomMapStyleOptions(options);
            }
        }else{
            //都没有，不显示自定义地图
            AMapUIServise.shareInstance.mapView.customMapStyleEnabled = false;
        }
    }
    
    
}
