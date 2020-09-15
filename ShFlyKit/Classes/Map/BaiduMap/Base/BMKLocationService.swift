//
//  BaiduLocationManager.swift
//  SHKit
//
//  Created by hsh on 2019/1/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///定位类代理方法
@objc protocol BMKLocationDelegate:NSObjectProtocol {
    //失败
    @objc optional func locationDidFailWithError(_ error:Error?);
    //修改了定位权限
    func locationChangeStatus(_ status:CLAuthorizationStatus);
    //网络状况改变
    @objc optional func locationNetworkStateChange(_ status:BMKLocationNetworkState);
}


///定位适配类
class BMKLocationService: NSObject,BMKLocationManagerDelegate {
    ///MARK-Variable
    private var mapView:BMKMapView!
    
    public weak var delegate:BMKLocationDelegate?
    public var userLocation:BMKUserLocation!        //用户当前的位置
    public var locationManager:BMKLocationManager!  //位置管理类
    
    
    ///Load
    override init() {
        super.init()
        locationManager = BMKLocationManager()
        locationManager.delegate = self;
        //设置返回位置的坐标系类型
        locationManager.coordinateType = BMKLocationCoordinateType.BMK09LL;
        //设置距离过滤参数
        locationManager.distanceFilter = kCLDistanceFilterNone;
        //设置应用位置类型
        locationManager.activityType = CLActivityType.automotiveNavigation;
        //设置是否自动停止位置更新
        locationManager.pausesLocationUpdatesAutomatically = false;
        //设置是否允许后台定位
        locationManager.allowsBackgroundLocationUpdates = true;
    
        //设置预期精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //设置位置获取超时时间
        locationManager.locationTimeout = 10;
        //设置获取地址信息超时时间
        locationManager.reGeocodeTimeout = 10;
    }
   
    
    ///MARK-Interface
    //设置需要定位的地图-嵌入
    public func setAdaptMap(_ map:BMKMapView?)->Void{
        if map != nil{
            mapView = map;
        }
    }
    
    
    //开始定位
    public func startLocation()->Void{
        locationManager.requestLocation(withReGeocode: true, withNetworkState: true) { (location, networkStatus, error) in
            if location != nil {
                if self.userLocation == nil{
                    self.userLocation = BMKUserLocation()
                }
                self.userLocation.location = location?.location;
                self.mapView.updateLocationData(self.userLocation);
                self.locateToUserLocation();
            }
        }
    }

    
    //开始连续定位
    public func startUpdatingLocation(_ head:Bool)->Void{
        locationManager.startUpdatingLocation()
        if head == true {
            locationManager.startUpdatingHeading()
        }
    }
    
    
    //停止连续定位
    public func stopUpdatingLocation(_ head:Bool)->Void{
        locationManager.stopUpdatingLocation()
        if head == true {
            locationManager.stopUpdatingHeading()
        }
    }
    
    
    //请求网络状态
    public func requestNetWorkStatus()->Void{
        locationManager.requestNetworkState();
    }
    
    
    //显示定位精度圈
    public func updateLocationDisplay(fillColor:UIColor,strokeColor:UIColor)->Void{
        let param = BMKLocationViewDisplayParam()
        param.accuracyCircleFillColor = fillColor;
        param.accuracyCircleStrokeColor = strokeColor;
        self.mapView.updateLocationView(with: param);
    }
    
    
    //定位到当前地址
    private func locateToUserLocation()->Void{
        if self.userLocation.location != nil {
            self.mapView.setCenter(self.userLocation.location.coordinate, animated: true);
        }
    }
    
    
    ///MARK-BMKLocationManagerDelegate
    //定位发生错误时
    func bmkLocationManager(_ manager: BMKLocationManager, didFailWithError error: Error?) {
        delegate?.locationDidFailWithError?(error);
    }
    
    
    //连续定位回调函数
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        if location != nil {
            if self.userLocation == nil{
                self.userLocation = BMKUserLocation()
            }
            self.userLocation.location = location?.location;
            self.mapView.updateLocationData(self.userLocation);
        }
    }
    
    
    //该方法为BMKLocationManager提供设备朝向的回调方法
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate heading: CLHeading?) {
        if heading == nil {
            return;
        }
        if self.userLocation == nil {
            self.userLocation = BMKUserLocation()
        }
        self.userLocation.heading = heading;
        self.mapView.updateLocationData(self.userLocation);
    }
    
    
    //定位权限状态改变时回调函数
    func bmkLocationManager(_ manager: BMKLocationManager, didChange status: CLAuthorizationStatus) {
        delegate?.locationChangeStatus(status);
    }
    
    
    //该方法为BMKLocationManager所在App系统网络状态改变的回调事件。
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate state: BMKLocationNetworkState, orError error: Error?) {
        if error == nil {
            delegate?.locationNetworkStateChange?(state);
        }
    }
    
   
}
