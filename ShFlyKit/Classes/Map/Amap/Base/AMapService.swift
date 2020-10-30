//
//  AMapService.swift
//  SHKit
//
//  Created by hsh on 2018/12/21.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapFoundationKit
import AMapSearchKit
import AMapNaviKit


//添加依赖库说明https://lbs.amap.com/api/ios-sdk/guide/create-project/manual-configuration
//提交appStore必读-IDFA https://lbs.amap.com/api/ios-sdk/guide/create-project/idfa-guide


///导航类型
public enum RoutePlanType {
    case Drive,Transit,Walk   //开车，公交，走路
}


///调用高德地图服务类
public class AMapService: NSObject,AMapSearchDelegate {
    /// MARK: - Variable
    public var searchAPI = AMapSearchAPI()
    //!!!请自行设置search的代理，在该类里面写返回结果的处理
    //["住宅","学校","楼宇","地铁","公交","医院","宾馆","风景","小区","政府",
    //"公司","餐饮","汽车","生活","交通","金融","停车场","购物","体育","道路"]
    
   
    ///MARK-Interface
    //打开高德地图AppStore页面
    class public func openAmapApp()->Void{
        AMapURLSearch.getLatestAMapApp()
    }
    
    
    //轨迹平滑处理
    class public func smoonTrace(tool:MASmoothPathTool,origins:[CLLocationCoordinate2D])->[CLLocationCoordinate2D]{
        //转换成初始数组
        var tmpOrigin = [MALonLatPoint]()
        for location in origins {
            let maPoint = MALonLatPoint()
            maPoint.lat = location.latitude;
            maPoint.lon = location.longitude;
            tmpOrigin.append(maPoint);
        }
        //转换成的MALonLatPoint数组
        let resultMa = tool.pathOptimize(tmpOrigin);
        var tmpResult = [CLLocationCoordinate2D]()
        for result in resultMa! {
            let location = CLLocationCoordinate2D(latitude: result.lat, longitude: result.lon);
            tmpResult.append(location);
        }
        return tmpResult;
    }
    
    
    /// MARK: - Interface
    //路径规划
    class public func RoutePlan(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D,routeType:RoutePlanType,
                          driveStrategy:AMapDrivingStrategy = .fastest,
                          transitStrategy:AMapTransitStrategy = .fastest)->Void{
        var finalStrategy:AMapRouteSearchType = .driving;
        switch routeType {
        case .Drive:
            finalStrategy = .driving;
        case .Walk:
            finalStrategy = .walking;
        case .Transit:
            finalStrategy = .transit;
        //创建跳转参数
        let config:AMapRouteConfig = AMapRouteConfig()
        config.startCoordinate = start;
        config.destinationCoordinate = end;
        config.routeType = finalStrategy;
        config.drivingStrategy = driveStrategy;
        config.transitStrategy = transitStrategy;
        AMapURLSearch.openAMapRouteSearch(config);
        }
    }

    
    //清空缓存
    class func cleanCache(_ map:MAMapView)->Void{
        map.clearDisk();
        map.clearIndoorMapCache();
    }
    
    
    //根据中心点坐标系来搜周边的POI
    public func searchPoiWithCenterCoordinate(coord:CLLocationCoordinate2D,type:String,page:NSInteger,radius:NSInteger = 1000)->Void{
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coord.latitude), longitude: CGFloat(coord.longitude));
        request.radius = radius; //搜索半径
        request.sortrule = 0;
        request.types = type;
        request.page = page;
        self.searchAPI?.aMapPOIAroundSearch(request);
    }
    
    
    //逆地理编码,请求
    public func searchReGeoCodeWithCoordinate(coordinate:CLLocationCoordinate2D)->Void{
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.longitude), longitude: CGFloat(coordinate.longitude));
        regeo.requireExtension = true;
        self.searchAPI?.aMapReGoecodeSearch(regeo);
    }
    
    
}
