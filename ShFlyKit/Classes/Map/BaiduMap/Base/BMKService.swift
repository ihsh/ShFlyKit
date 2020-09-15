//
//  BaiduService.swift
//  SHKit
//
//  Created by hsh on 2019/1/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///路线类型
enum RouteType{
    case Drive,Walk,Transit
}


///百度建议搜索结果返回
@objc protocol BMKServiceDelegate:NSObjectProtocol {
    //提示搜索返回结果
    @objc optional func sugSearchResult(_ result:BMKSuggestionSearchResult,error:BMKSearchErrorCode)
}


///百度地图公共服务类
class BMKService: NSObject ,BMKSuggestionSearchDelegate {
    ///MARK - Variable
    static let shareInstance = BMKService.init()
    public weak var delegate:BMKServiceDelegate?
    private var bmkManager:BMKMapManager!               //百度地图注册
    private var sugSearch = BMKSuggestionSearch()       //建议搜索
    
    
    ///MARK-Interface
    //注册百度地图，鉴权
    public func registerBaidu(key:String)->Void{
        bmkManager = BMKMapManager()
        //百度地图服务
        bmkManager.start(key, generalDelegate: self as? BMKGeneralDelegate);
        //鉴权-定位
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: key, authDelegate: self as? BMKLocationAuthDelegate);
    }
    
    
    //设置自定义地图
    class public func customMapStyle(fileName:String?)->Void{
        //仅设置资源
        if fileName != nil{
            let path:String? = Bundle.main.path(forResource: fileName!, ofType: "json");
            BMKMapView.customMapStyle(path);
        }
        //要开启还需调用BMKMapUIService.enableCustomMap方法
    }
    
    
    //计算两点之间的距离
    class public func calcalDistanceBetween(pointA:CLLocationCoordinate2D,pointB:CLLocationCoordinate2D)->CLLocationDistance{
        return BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(pointA), BMKMapPointForCoordinate(pointB))
    }
    
    
    //调用起公交路线规划
    class func routePlan(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D,appscheme:String,type:RouteType)->Void{
        var opt = BMKOpenRouteOption()
        switch type {
        case .Drive:
            opt = BMKOpenDrivingRouteOption()
        case .Walk:
            opt = BMKOpenWalkingRouteOption()
        case .Transit:
            opt = BMKOpenTransitRouteOption()
        }
        opt.appScheme = appscheme;
        //起点，终点
        let begin = BMKPlanNode()
        begin.pt = start;
        let endNode = BMKPlanNode()
        endNode.pt = end;
        opt.startPoint = begin;
        opt.endPoint = endNode;
        //发起
        switch type {
        case .Drive:
            BMKOpenRoute.openBaiduMapDrivingRoute(opt as? BMKOpenDrivingRouteOption);
        case .Walk:
            BMKOpenRoute.openBaiduMapWalkingRoute(opt as? BMKOpenWalkingRouteOption);
        case .Transit:
            BMKOpenRoute.openBaiduMapTransitRoute(opt as? BMKOpenTransitRouteOption);
        }
    }
    
    
    //调起客户端的AR导航
    class func openARwalkRoutePlan(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D)->Void{
        let para = BMKNaviPara()
        let beigin = BMKPlanNode()
        beigin.pt = start;
        let endNode = BMKPlanNode()
        endNode.pt = end;
        para.endPoint = beigin;
        para.endPoint = endNode;
        BMKNavigation.openBaiduMapwalkARNavigation(para);
    }
    
    
    //提示检索功能
    public func sugSearch(city:String?,keywords:String)->Void{
        self.sugSearch.delegate = self;
        let option:BMKSuggestionSearchOption = BMKSuggestionSearchOption()
        option.cityLimit = city != nil ? true : false;
        option.cityname = city != nil ? city : "全国";
        option.keyword = keywords;
        self.sugSearch.suggestionSearch(option);
    }
    
    
    
    ///MARK -BMKSuggestionSearchDelegate
    //返回搜索结果--Sug检索结果的第一条可能存在没有经纬度信息的情况，该条结果为文字联想出来的关键词结果，并不对应任何确切POI点。如肯德基
    func onGetSuggestionResult(_ searcher: BMKSuggestionSearch!, result: BMKSuggestionSearchResult!, errorCode error: BMKSearchErrorCode) {
        delegate?.sugSearchResult?(result,error: error);
    }
    
    
}
