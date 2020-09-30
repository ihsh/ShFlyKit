//
//  AMapGeoFence.swift
//  SHKit
//
//  Created by hsh on 2019/1/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapLocationKit
import AMapSearchKit
import AMapNaviKit
import AMapFoundationKit

///地理围栏代理
@objc protocol AMapGeoFenceDelegate : NSObjectProtocol {
    //地理围栏添加成功
    @objc optional func fenceAddSuccess(_ customID:String);
    //地理围栏添加失败
    @objc optional func fenceAddFailed(_ customID:String);
    //地理围栏状态发生改变
    func fenceStatusChange(_ status:AMapGeoFenceRegionStatus);
}


///地理围栏类
class AMapGeoFence: NSObject,AMapGeoFenceManagerDelegate{
    ///MARK
    private var geoFenceManager:AMapGeoFenceManager!
    public  weak var delegate:AMapGeoFenceDelegate?
    public  var fenceMap = NSMutableDictionary()         //地理围栏记录
    
    
    ///Load
    override init() {
        super.init();
        self.geoFenceManager = AMapGeoFenceManager()
        self.geoFenceManager.delegate = self;
        self.geoFenceManager.activeAction = AMapGeoFenceActiveAction(rawValue: AMapGeoFenceActiveAction.inside.rawValue |  AMapGeoFenceActiveAction.outside.rawValue | AMapGeoFenceActiveAction.stayed.rawValue);
        //允许后台定位
        self.geoFenceManager.allowsBackgroundLocationUpdates = true;
    }
    
    
    ///Interface
    //添加根据关键字创建围栏---type例如高等院校，customID-与围栏关联的自有业务ID(随便取)
    public func addFenceForKeywords(_ keyword:String,type:String,city:String)->Void{
        self.geoFenceManager.addKeywordPOIRegionForMonitoring(withKeyword: keyword, poiType: type, city: city, size: 20,
                                                              customID: "\(keyword)\(city)\(type)");
    }
    
    
    //添加行政区域
    public func addFenceForDistrictRegion(_ district:String)->Void{
        self.geoFenceManager.addDistrictRegionForMonitoring(withDistrictName: district, customID: "\(district)");
    }
    
    
    //添加自定义圆形围栏
    public func addCircleFence(_ center:CLLocationCoordinate2D,radius:CLLocationDistance,custumID:String?)->Void{
        self.geoFenceManager.addCircleRegionForMonitoring(withCenter: center, radius: radius, customID: custumID != nil ? custumID : "circle");
    }
    
    
    //添加自定义多边形围栏
    public func addPolygonRegion(_ coordinates:[CLLocationCoordinate2D],customID:String?)->Void{
        let count = coordinates.count;
        let coorArr:UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer.allocate(capacity: count);
        var index = 0;
        for coordinate in coordinates {
            coorArr[index] = coordinate;
            index += 1;
        }
        self.geoFenceManager.addPolygonRegionForMonitoring(withCoordinates: coorArr, count: count, customID: customID != nil ? customID : "polygon\(count)");
    }
    
    
    //移除所有的地理围栏
    public func removeAllFence()->Void{
        self.geoFenceManager.removeAllGeoFenceRegions();
    }
    
    
    //移除指定ID的地理围栏
    public func removeFence(_ customID:String)->Void{
        self.geoFenceManager.removeGeoFenceRegions(withCustomID: customID);
    }
    
    
    ///MARK-AMapGeoFenceManagerDelegate
    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didAddRegionForMonitoringFinished regions: [AMapGeoFenceRegion]!, customID: String!, error: Error!) {
        if error != nil {
            delegate?.fenceAddFailed?(customID);
        }else{
            let value = fenceMap.value(forKey: customID);
            if value != nil {
                self.removeFence(value as! String);
            }
            fenceMap.setValue(customID, forKey: customID);
            delegate?.fenceAddSuccess?(customID);
        }
    }
    
    
    //地理围栏状态改变
    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didGeoFencesStatusChangedFor region: AMapGeoFenceRegion!, customID: String!, error: Error!) {
        if error == nil {
            let status = region.fenceStatus;
            delegate?.fenceStatusChange(status);
        }
    }
    

}
