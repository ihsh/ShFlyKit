//
//  BMKMapUIService.swift
//  SHKit
//
//  Created by hsh on 2019/1/18.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///百度地图UI设置类
class BMKMapUIService: NSObject {
    ///MARK-Varibale
    static let shareInstance = BMKMapUIService.init()
    //单例的地图
    public var mapView = BMKMapView()
    
    
    ///MARK-Interface
    //获取地图单例
    class public func getInitialMap()->BMKMapView{
        let map = BMKMapUIService.shareInstance.mapView;
        map.delegate = nil;
        map.removeAnnotations(map.annotations);
        map.removeOverlays(map.overlays);
        map.removeHeatMap();
        return map;
    }
    
    
    //设置地图类型-卫星，标准，空白
    class public func setMapType(_ type:BMKMapType)->Void{
        BMKMapUIService.shareInstance.mapView.mapType = type;
    }
    
    
    //实时路况打开
    class public func trafficShow(_ show:Bool)->Void{
        BMKMapUIService.shareInstance.mapView.isTrafficEnabled = show;
    }
    
    
    //热力图
    class public func heatMapShow(_ show:Bool)->Void{
        BMKMapUIService.shareInstance.mapView.isBaiduHeatMapEnabled = show;
    }
    
    
    //显示用户位置
    class public func showUserLocation(_ show:Bool)->Void{
        BMKMapUIService.shareInstance.mapView.showsUserLocation = show;
    }
    
    
    //设置自定义的路线颜色
    class public func setCustomTrafficeColor(smooth:UIColor,slow:UIColor,congestion:UIColor,seriousCongestion:UIColor)->Void{
        BMKMapUIService.shareInstance.mapView.setCustomTrafficColorForSmooth(smooth, slow: slow, congestion: congestion, severeCongestion: seriousCongestion);
    }
    
    
    //使用自定义地图-开关
    class public func enableCustomMap(_ enable:Bool)->Void{
        BMKMapView.enableCustomMapStyle(enable);
    }
    
    
}
