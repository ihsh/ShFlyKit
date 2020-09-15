//
//  BaiduGeoFence.swift
//  SHKit
//
//  Created by hsh on 2019/1/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///地理围栏代理
@objc protocol BMKGeoFenceDelegate : NSObjectProtocol {
    //地理围栏添加成功
    @objc optional func fenceAddSuccess(_ customID:String);
    //地理围栏添加失败
    @objc optional func fenceAddFailed(_ customID:String);
    //地理围栏状态发生改变
    func fenceStatusChange(_ status:BMKGeoFenceRegionStatus);
}


///地理围栏类
class BMKGeoFence: NSObject,BMKGeoFenceManagerDelegate {
    ///MARK-Variable
    public var geoFenceManager:BMKGeoFenceManager!
    public var fenceMap = NSMutableDictionary()             //添加好的地理围栏
    public weak var delegate:BMKGeoFenceDelegate?

    
    ///Load
    override init() {
        super.init()
        geoFenceManager = BMKGeoFenceManager()
        geoFenceManager.delegate = self;
        //设置希望侦测的围栏触发行为
        geoFenceManager.activeAction = BMKGeoFenceActiveAction(rawValue: BMKGeoFenceActiveAction.inside.rawValue | BMKGeoFenceActiveAction.outside.rawValue | BMKGeoFenceActiveAction.stayed.rawValue)
        geoFenceManager.allowsBackgroundLocationUpdates = true;
    }
    
    
    ///MARK-Interface
    //添加多边形地理围栏
    public func addGenFenceForRegion(coordinates:[CLLocationCoordinate2D],customID:String?)->Void{
        let size:Int = coordinates.count;
        let coorArr:UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer.allocate(capacity: size);
        for i in 0..<size {
            coorArr[i] = coordinates[i];
        }
        geoFenceManager.addPolygonRegionForMonitoring(withCoordinates: coorArr, count: size, coorType: BMKLocationCoordinateType.BMK09LL, customID: customID ?? "polygon");
    }
    
    
    //添加圆形围栏
    public func addCircelFence(center:CLLocationCoordinate2D,radius:CLLocationDistance,customID:String?)->Void{
         geoFenceManager.addCircleRegionForMonitoring(withCenter: center, radius: radius, coorType: BMKLocationCoordinateType.BMK09LL, customID: customID ?? "circle")
    }
    
    
    //移除所有的地理围栏
    public func removeAllFence()->Void{
        self.geoFenceManager.removeAllGeoFenceRegions();
    }
    
    
    //移除围栏
    public func removeFence(_ fenceID:String)->Void{
        self.geoFenceManager.removeGeoFenceRegions(withCustomID: fenceID);
    }
    
    
    ///MARK-BMKGeoFenceManagerDelegate
    ///创建成功围栏的回调
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, didAddRegionForMonitoringFinished regions: [BMKGeoFenceRegion]?, customID: String?, error: Error?) {
        if error != nil {
            delegate?.fenceAddFailed?(customID ?? "");
        }else{
            let value = fenceMap.value(forKey: customID ?? "");
            if value != nil {
                //移除旧的围栏
                self.removeFence(value as! String);
            }
            fenceMap.setValue(customID, forKey: customID ?? "");
            delegate?.fenceAddSuccess?(customID ?? "");
        }
    }
    
    
    ///当区域变化后
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, didGeoFencesStatusChangedFor region: BMKGeoFenceRegion?, customID: String?, error: Error?) {
        if error == nil && region != nil{
            let status = region!.fenceStatus;
            delegate?.fenceStatusChange(status);
        }
    }
    
    
}
